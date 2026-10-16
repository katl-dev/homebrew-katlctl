class BetaAT2026101 < Formula
  desc "Workstation CLI for KatlOS"
  homepage "https://github.com/katl-dev/katl"
  version "2026.10.1"
  license "MIT"
  conflicts_with "katl-dev/katlctl/stable", "katl-dev/katlctl/beta", because: "both install katlctl"

  on_linux do
    depends_on arch: :x86_64
    url "https://github.com/katl-dev/katl/releases/download/v2026.10.1/katlctl-2026.10.1-linux-amd64"
    sha256 "809a5d6d2d29af82caa4f991bd5fe0997ff05fa07483f278489d4123666bb206"
  end

  on_macos do
    depends_on arch: :arm64
    url "https://github.com/katl-dev/katl/releases/download/v2026.10.1/katlctl-2026.10.1-darwin-arm64"
    sha256 "69106d5ea39832165cf10bf69b0928c3881680b4b23f2971096965742b10a28b"
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
