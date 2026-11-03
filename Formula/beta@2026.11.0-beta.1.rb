class BetaAT2026110Beta1 < Formula
  desc "Workstation CLI for KatlOS"
  homepage "https://github.com/katl-dev/katl"
  version "2026.11.0-beta.1"
  license "MIT"
  conflicts_with "katl-dev/katlctl/stable", "katl-dev/katlctl/beta", because: "both install katlctl"

  on_linux do
    depends_on arch: :x86_64
    url "https://github.com/katl-dev/katl/releases/download/v2026.11.0-beta.1/katlctl-2026.11.0-beta.1-linux-amd64"
    sha256 "47e3934484b80db7fedd246db4f5649d9b1fbd3f2cc6be6fe2488682b643c307"
  end

  on_macos do
    depends_on arch: :arm64
    url "https://github.com/katl-dev/katl/releases/download/v2026.11.0-beta.1/katlctl-2026.11.0-beta.1-darwin-arm64"
    sha256 "879b855aeb5987605dfd1b69e57075b259bdf769074911242c54d61a18386abe"
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
