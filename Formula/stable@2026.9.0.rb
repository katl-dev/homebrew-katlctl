class StableAT202690 < Formula
  desc "Workstation CLI for KatlOS"
  homepage "https://github.com/katl-dev/katl"
  version "2026.9.0"
  license "MIT"
  conflicts_with "katl-dev/katlctl/stable", "katl-dev/katlctl/beta", because: "both install katlctl"

  on_linux do
    depends_on arch: :x86_64
    url "https://github.com/katl-dev/katl/releases/download/v2026.9.0/katlctl-2026.9.0-linux-amd64"
    sha256 "6e905be4f4513bc043da6dfdefb45c3ca4281faeac16e7e7b5abcb520a7d7f5b"
  end

  on_macos do
    depends_on arch: :arm64
    url "https://github.com/katl-dev/katl/releases/download/v2026.9.0/katlctl-2026.9.0-darwin-arm64"
    sha256 "3aee6a0270aa5963d69729626e4d350350caa879effe34a588cddcae9b882b60"
  end

  def install
    bin.install Dir["katlctl-*"].fetch(0) => "katlctl"
    chmod 0755, bin/"katlctl"
    generate_completions_from_executable(bin/"katlctl", "completion")
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/katlctl version")
  end
end
