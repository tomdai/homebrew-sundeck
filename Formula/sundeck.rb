class Sundeck < Formula
  desc "Converge isolated Daydream development environments"
  homepage "https://github.com/tomdai/homebrew-sundeck"
  url "https://github.com/tomdai/homebrew-sundeck/releases/download/v0.8.9/sundeck-macos-arm64.tar.gz"
  version "0.8.9"
  sha256 "d2857da736de0d14fd27a3cfd05d55b03984f52e1fc39f90c03387af606f7c2a"

  depends_on arch: :arm64
  depends_on macos: :tahoe

  def install
    bin.install "sundeck"
  end

  test do
    assert_equal version.to_s, shell_output("#{bin}/sundeck --version").strip
    assert_match "USAGE:", shell_output("#{bin}/sundeck --help")
  end
end
