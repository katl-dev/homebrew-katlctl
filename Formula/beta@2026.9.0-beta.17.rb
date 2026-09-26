class BetaAT202690Beta17 < Formula
  desc "Workstation CLI for KatlOS"
  homepage "https://github.com/katl-dev/katl"
  version "2026.9.0-beta.17"
  license "MIT"
  conflicts_with "katl-dev/katlctl/stable", "katl-dev/katlctl/beta", because: "both install katlctl"

  on_linux do
    depends_on arch: :x86_64
    url "https://github.com/katl-dev/katl/releases/download/v2026.9.0-beta.17/katlctl-2026.9.0-beta.17-linux-amd64"
    sha256 "73dbeae4adc4ed0efd1fc28cb65cac75bafc0e95610ffa9f54c10faa9d73d01f"
  end

  on_macos do
    depends_on arch: :arm64
    url "https://github.com/katl-dev/katl/releases/download/v2026.9.0-beta.17/katlctl-2026.9.0-beta.17-darwin-arm64"
    sha256 "f16fc2b6b26d03b2226053f0528c728b38bd88ecfdb0e1b7f745e75a3450bf0d"
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
