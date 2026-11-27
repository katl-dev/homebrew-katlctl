class Beta < Formula
  desc "Workstation CLI for KatlOS"
  homepage "https://github.com/katl-dev/katl"
  version "2026.11.6"
  license "MIT"
  conflicts_with "katl-dev/katlctl/stable", because: "both install katlctl"

  on_linux do
    depends_on arch: :x86_64
    url "https://github.com/katl-dev/katl/releases/download/v2026.11.6/katlctl-2026.11.6-linux-amd64"
    sha256 "f266fc418a4bc058130c63f61f1bc208ec58e106d78a2b3d27cdfd758f85ff07"
  end

  on_macos do
    depends_on arch: :arm64
    url "https://github.com/katl-dev/katl/releases/download/v2026.11.6/katlctl-2026.11.6-darwin-arm64"
    sha256 "af0cc835c536549b73d4c0df49d92aede821e1ff06149e6aaa57d13c1b6ab25d"
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
