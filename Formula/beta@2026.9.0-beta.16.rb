class BetaAT202690Beta16 < Formula
  desc "Workstation CLI for KatlOS"
  homepage "https://github.com/katl-dev/katl"
  version "2026.9.0-beta.16"
  license "MIT"
  conflicts_with "katl-dev/katlctl/stable", "katl-dev/katlctl/beta", because: "both install katlctl"

  depends_on :linux

  on_linux do
    depends_on arch: :x86_64
    url "https://github.com/katl-dev/katl/releases/download/v2026.9.0-beta.16/katlctl-2026.9.0-beta.16-linux-amd64"
    sha256 "a7773d2e3e7ef78ec3f6fb2838eb895e58002a6c192ad001f3a4479fffa0e1ca"
  end

  def install
    bin.install Dir["katlctl-*"].fetch(0) => "katlctl"
    generate_completions_from_executable(bin/"katlctl", "completion")
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/katlctl version")
  end
end
