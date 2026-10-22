class StableAT2026103 < Formula
  desc "Workstation CLI for KatlOS"
  homepage "https://github.com/katl-dev/katl"
  version "2026.10.3"
  license "MIT"
  conflicts_with "katl-dev/katlctl/stable", "katl-dev/katlctl/beta", because: "both install katlctl"

  on_linux do
    depends_on arch: :x86_64
    url "https://github.com/katl-dev/katl/releases/download/v2026.10.3/katlctl-2026.10.3-linux-amd64"
    sha256 "55d43692756119c01781dba52d0c067818006add5fc127200bc2cb5dd53aac1d"
  end

  on_macos do
    depends_on arch: :arm64
    url "https://github.com/katl-dev/katl/releases/download/v2026.10.3/katlctl-2026.10.3-darwin-arm64"
    sha256 "5d2cc06b8106f351a8ea5227c256042c3f74a85b19c5e0b5ce1a7d7ac779981d"
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
