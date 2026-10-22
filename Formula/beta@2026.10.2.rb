class BetaAT2026102 < Formula
  desc "Workstation CLI for KatlOS"
  homepage "https://github.com/katl-dev/katl"
  version "2026.10.2"
  license "MIT"
  conflicts_with "katl-dev/katlctl/stable", "katl-dev/katlctl/beta", because: "both install katlctl"

  on_linux do
    depends_on arch: :x86_64
    url "https://github.com/katl-dev/katl/releases/download/v2026.10.2/katlctl-2026.10.2-linux-amd64"
    sha256 "5c0a609bd1a193230ae399b8b32c2dee6e29c6e8b5efabc0fb6b1ba97ed6e4b6"
  end

  on_macos do
    depends_on arch: :arm64
    url "https://github.com/katl-dev/katl/releases/download/v2026.10.2/katlctl-2026.10.2-darwin-arm64"
    sha256 "f10e27370baf9582920c055ccf6cdcb030f1af3b04c066a0ee4b6ec53b09436b"
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
