class Beta < Formula
  desc "Workstation CLI for KatlOS"
  homepage "https://github.com/katl-dev/katl"
  version "2026.11.5"
  license "MIT"
  conflicts_with "katl-dev/katlctl/stable", because: "both install katlctl"

  on_linux do
    depends_on arch: :x86_64
    url "https://github.com/katl-dev/katl/releases/download/v2026.11.5/katlctl-2026.11.5-linux-amd64"
    sha256 "ede297a5495ed5c4d3d039427cd666713eebcc6910c526deab7bcb6c143b9e09"
  end

  on_macos do
    depends_on arch: :arm64
    url "https://github.com/katl-dev/katl/releases/download/v2026.11.5/katlctl-2026.11.5-darwin-arm64"
    sha256 "3281363dc4b0a54c69a3a1e094bb8a309afc0d805caa38ee64c5d160ec238ceb"
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
