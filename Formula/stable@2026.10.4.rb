class StableAT2026104 < Formula
  desc "Workstation CLI for KatlOS"
  homepage "https://github.com/katl-dev/katl"
  version "2026.10.4"
  license "MIT"
  conflicts_with "katl-dev/katlctl/stable", "katl-dev/katlctl/beta", because: "both install katlctl"

  on_linux do
    depends_on arch: :x86_64
    url "https://github.com/katl-dev/katl/releases/download/v2026.10.4/katlctl-2026.10.4-linux-amd64"
    sha256 "75c204a8915624fafc3fa5cf960e28904df360302aeaee3ab43815d93b3cfe7f"
  end

  on_macos do
    depends_on arch: :arm64
    url "https://github.com/katl-dev/katl/releases/download/v2026.10.4/katlctl-2026.10.4-darwin-arm64"
    sha256 "66710ecf3584dc37f20034e6cf0745e03f40f21ebe0898c8443dd8dcc1b92e54"
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
