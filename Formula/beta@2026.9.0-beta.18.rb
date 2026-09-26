class BetaAT202690Beta18 < Formula
  desc "Workstation CLI for KatlOS"
  homepage "https://github.com/katl-dev/katl"
  version "2026.9.0-beta.18"
  license "MIT"
  conflicts_with "katl-dev/katlctl/stable", "katl-dev/katlctl/beta", because: "both install katlctl"

  on_linux do
    depends_on arch: :x86_64
    url "https://github.com/katl-dev/katl/releases/download/v2026.9.0-beta.18/katlctl-2026.9.0-beta.18-linux-amd64"
    sha256 "4e21e6e67826a1b891b106b84fcec4bf35c219d3d98a02d53a7f3b5076dba8f7"
  end

  on_macos do
    depends_on arch: :arm64
    url "https://github.com/katl-dev/katl/releases/download/v2026.9.0-beta.18/katlctl-2026.9.0-beta.18-darwin-arm64"
    sha256 "0c807133c7c6ca6a0e42beb703178be35a34adfe39a5a2f04f613548bf8316ec"
  end

  def install
    bin.install Dir["katlctl-*"].fetch(0) => "katlctl"
    generate_completions_from_executable(bin/"katlctl", "completion")
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/katlctl version")
  end
end
