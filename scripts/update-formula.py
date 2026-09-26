#!/usr/bin/env python3
"""Update stable and beta katlctl formulas from published Katl releases."""

import hashlib
import json
import re
import subprocess
import tempfile
from pathlib import Path


REPOSITORY = "katl-dev/katl"
TAP = "katl-dev/katlctl"
FORMULAS = Path(__file__).resolve().parents[1] / "Formula"
PLATFORMS = ("linux-amd64", "darwin-arm64")
VERSION = re.compile(r"v([0-9]{4})\.([0-9]+)\.([0-9]+)(?:-beta\.([0-9]+))?")


def gh(*args):
    return subprocess.check_output(("gh", *args), text=True).strip()


def release_channels():
    pages = json.loads(gh("api", f"repos/{REPOSITORY}/releases?per_page=100",
                          "--paginate", "--slurp"))
    return select_channels(release for page in pages for release in page)


def select_channels(releases):
    eligible = []
    for published in releases:
        match = VERSION.fullmatch(published["tag_name"])
        if published["draft"] or not match:
            continue
        if published["prerelease"] != (match.group(4) is not None):
            raise ValueError(f"release channel disagrees with tag: {published['tag_name']}")
        key = tuple(map(int, match.group(1, 2, 3))) + (
            0 if match.group(4) is not None else 1,
            int(match.group(4)) if match.group(4) is not None else 0,
        )
        eligible.append((key, published))

    if not eligible:
        raise ValueError("no published stable or beta Katl release found")
    beta = max(eligible, key=lambda item: item[0])[1]
    stable = max((item for item in eligible if not item[1]["prerelease"]),
                 key=lambda item: item[0], default=None)
    return stable[1] if stable else None, beta


def checksums(published):
    tag = published["tag_name"]
    if not re.fullmatch(r"v[0-9]{4}\.[0-9]+\.[0-9]+(?:-[0-9A-Za-z.]+)?", tag):
        raise ValueError(f"unexpected release tag: {tag}")

    version = tag[1:]
    assets = {asset["name"] for asset in published["assets"]}
    result = {}
    with tempfile.TemporaryDirectory() as directory:
        for platform in PLATFORMS:
            name = f"katlctl-{version}-{platform}"
            if name not in assets and f"{name}.sha256" not in assets:
                continue
            if name not in assets or f"{name}.sha256" not in assets:
                raise ValueError(f"release has an incomplete {platform} katlctl pair")

            # Verify the published checksum against the release binary before trusting it.
            gh("release", "download", tag, "--repo", REPOSITORY,
               "--pattern", name, "--pattern", f"{name}.sha256", "--dir", directory)
            match = re.fullmatch(r"([0-9a-f]{64})  " + re.escape(name) + r"\n?",
                                 (Path(directory) / f"{name}.sha256").read_text())
            if not match:
                raise ValueError(f"invalid checksum file for {name}")
            digest = hashlib.sha256((Path(directory) / name).read_bytes()).hexdigest()
            if digest != match.group(1):
                raise ValueError(f"published binary does not match checksum: {name}")
            result[platform] = digest

    if "linux-amd64" not in result:
        raise ValueError("newest release has no Linux amd64 katlctl binary")
    return version, result


def render(formula, version, digests):
    class_name = formula.capitalize()
    other = "beta" if formula == "stable" else "stable"
    lines = [
        f'class {class_name} < Formula',
        '  desc "Workstation CLI for KatlOS"',
        '  homepage "https://github.com/katl-dev/katl"',
        f'  version "{version}"',
        '  license "MIT"',
        f'  conflicts_with "{TAP}/{other}", because: "both install katlctl"',
        '',
    ]
    if "darwin-arm64" not in digests:
        lines += ['  depends_on :linux', '']

    for platform, os_name, arch in (
        ("linux-amd64", "linux", "x86_64"),
        ("darwin-arm64", "macos", "arm64"),
    ):
        if platform not in digests:
            continue
        name = f"katlctl-{version}-{platform}"
        lines += [
            f'  on_{os_name} do',
            f'    depends_on arch: :{arch}',
            f'    url "https://github.com/{REPOSITORY}/releases/download/v{version}/{name}"',
            f'    sha256 "{digests[platform]}"',
            '  end',
            '',
        ]

    lines += [
        '  def install',
        '    bin.install Dir["katlctl-*"].fetch(0) => "katlctl"',
        '  end',
        '',
        '  test do',
        '    assert_match version.to_s, shell_output("#{bin}/katlctl version")',
        '  end',
        'end',
        '',
    ]
    return "\n".join(lines)


def main():
    stable, beta = release_channels()
    FORMULAS.mkdir(exist_ok=True)
    for formula, published in (("stable", stable), ("beta", beta)):
        if published is None:
            if (FORMULAS / f"{formula}.rb").exists():
                raise ValueError("stable formula exists but no stable release was found")
            print("No stable release yet; stable formula remains unpublished")
            continue
        version, digests = checksums(published)
        (FORMULAS / f"{formula}.rb").write_text(render(formula, version, digests))
        print(f"Updated {formula} formula to {version} ({', '.join(digests)})")


if __name__ == "__main__":
    main()
