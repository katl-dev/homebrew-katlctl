class Beta < Formula
  desc "Workstation CLI for KatlOS"
  homepage "https://github.com/katl-dev/katl"
  version "2026.11.1"
  license "MIT"
  conflicts_with "katl-dev/katlctl/stable", because: "both install katlctl"

  on_linux do
    depends_on arch: :x86_64
    url "https://github.com/katl-dev/katl/releases/download/v2026.11.1/katlctl-2026.11.1-linux-amd64"
    sha256 "33043696ab85bc0c8e223718926d34efa6762f13d11c3a3f5e4f8236231f84cb"
  end

  on_macos do
    depends_on arch: :arm64
    url "https://github.com/katl-dev/katl/releases/download/v2026.11.1/katlctl-2026.11.1-darwin-arm64"
    sha256 "327a1cfd3931341807928df8739d55d7706c3cbee1b23ccf00f2ef61bbaa1f2b"
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
