class StableAT202691 < Formula
  desc "Workstation CLI for KatlOS"
  homepage "https://github.com/katl-dev/katl"
  version "2026.9.1"
  license "MIT"
  conflicts_with "katl-dev/katlctl/stable", "katl-dev/katlctl/beta", because: "both install katlctl"

  on_linux do
    depends_on arch: :x86_64
    url "https://github.com/katl-dev/katl/releases/download/v2026.9.1/katlctl-2026.9.1-linux-amd64"
    sha256 "b24c22d2bd67536b1cdf05f51f7e5534d7d4d18fe2dbe115bf33ba8cffe67880"
  end

  on_macos do
    depends_on arch: :arm64
    url "https://github.com/katl-dev/katl/releases/download/v2026.9.1/katlctl-2026.9.1-darwin-arm64"
    sha256 "c31a68a193241bdea5fa3c2327e5d19c2a32c8e35be9ea71e38521c2cfb6ec1f"
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
