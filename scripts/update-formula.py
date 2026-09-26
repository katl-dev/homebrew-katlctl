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
# Keep exact-version formulas from the first release pinned by this tap onward.
PIN_FROM = (2026, 9, 0, 0, 16)


def gh(*args):
    return subprocess.check_output(("gh", *args), text=True).strip()


def published_releases():
    pages = json.loads(gh("api", f"repos/{REPOSITORY}/releases?per_page=100",
                          "--paginate", "--slurp"))
    return [release for page in pages for release in page]


def eligible_releases(releases):
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
        yield key, published


def select_channels(releases):
    eligible = list(eligible_releases(releases))

    if not eligible:
        raise ValueError("no published stable or beta Katl release found")
    beta = max(eligible, key=lambda item: item[0])[1]
    stable = max((item for item in eligible if not item[1]["prerelease"]),
                 key=lambda item: item[0], default=None)
    return stable[1] if stable else None, beta


def pinned_formulas(releases):
    for key, published in eligible_releases(releases):
        if key < PIN_FROM:
            continue
        version = published["tag_name"][1:]
        channels = ("beta",) if published["prerelease"] else ("stable", "beta")
        for channel in channels:
            yield f"{channel}@{version}", published


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
    class_name = re.sub(r"[-_.]([A-Za-z0-9])", lambda match: match[1].upper(), class_name)
    class_name = re.sub(r"([A-Za-z])@([0-9])", r"\1AT\2", class_name)
    channel = formula.split("@", 1)[0]
    conflicts = ("stable", "beta") if "@" in formula else (
        "beta" if channel == "stable" else "stable",
    )
    lines = [
        f'class {class_name} < Formula',
        '  desc "Workstation CLI for KatlOS"',
        '  homepage "https://github.com/katl-dev/katl"',
        f'  version "{version}"',
        '  license "MIT"',
        '  conflicts_with ' + ', '.join(f'"{TAP}/{other}"' for other in conflicts) +
        ', because: "both install katlctl"',
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
    releases = published_releases()
    stable, beta = select_channels(releases)
    FORMULAS.mkdir(exist_ok=True)
    verified = {}

    def verify(published):
        tag = published["tag_name"]
        if tag not in verified:
            verified[tag] = checksums(published)
        return verified[tag]

    for formula, published in (("stable", stable), ("beta", beta)):
        if published is None:
            if (FORMULAS / f"{formula}.rb").exists():
                raise ValueError("stable formula exists but no stable release was found")
            print("No stable release yet; stable formula remains unpublished")
            continue
        version, digests = verify(published)
        (FORMULAS / f"{formula}.rb").write_text(render(formula, version, digests))
        print(f"Updated {formula} formula to {version} ({', '.join(digests)})")

    for formula, published in pinned_formulas(releases):
        path = FORMULAS / f"{formula}.rb"
        if path.exists() and published not in (stable, beta):
            continue
        version, digests = verify(published)
        path.write_text(render(formula, version, digests))
        print(f"Updated {formula} formula ({', '.join(digests)})")


if __name__ == "__main__":
    main()
