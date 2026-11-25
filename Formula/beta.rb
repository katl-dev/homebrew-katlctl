class Beta < Formula
  desc "Workstation CLI for KatlOS"
  homepage "https://github.com/katl-dev/katl"
  version "2026.11.4"
  license "MIT"
  conflicts_with "katl-dev/katlctl/stable", because: "both install katlctl"

  on_linux do
    depends_on arch: :x86_64
    url "https://github.com/katl-dev/katl/releases/download/v2026.11.4/katlctl-2026.11.4-linux-amd64"
    sha256 "29d264270c90a8ce0e6c322bbb1028d8fbb809f6368234eecdb6493d2f5afe27"
  end

  on_macos do
    depends_on arch: :arm64
    url "https://github.com/katl-dev/katl/releases/download/v2026.11.4/katlctl-2026.11.4-darwin-arm64"
    sha256 "4b86e31698e4f4c297f8dff0394210fb4412f926d793f05608190295417deb26"
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
