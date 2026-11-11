class BetaAT2026110 < Formula
  desc "Workstation CLI for KatlOS"
  homepage "https://github.com/katl-dev/katl"
  version "2026.11.0"
  license "MIT"
  conflicts_with "katl-dev/katlctl/stable", "katl-dev/katlctl/beta", because: "both install katlctl"

  on_linux do
    depends_on arch: :x86_64
    url "https://github.com/katl-dev/katl/releases/download/v2026.11.0/katlctl-2026.11.0-linux-amd64"
    sha256 "1dfdeb1801265b025c5f77228beafe048df75f5a8fd35128d5fbb417c7ec1f6d"
  end

  on_macos do
    depends_on arch: :arm64
    url "https://github.com/katl-dev/katl/releases/download/v2026.11.0/katlctl-2026.11.0-darwin-arm64"
    sha256 "94c29553919625a32eef6e87d055c16b110e62b4e6eaf8b194f595416994ed84"
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
