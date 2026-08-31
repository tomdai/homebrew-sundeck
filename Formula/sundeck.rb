class Sundeck < Formula
  desc "Converge isolated Daydream development environments"
  homepage "https://github.com/tomdai/homebrew-sundeck"
  url "https://github.com/tomdai/homebrew-sundeck/releases/download/v0.8.13/sundeck-macos-arm64.tar.gz"
  version "0.8.13"
  sha256 "e9a1bc4399857b60cb07fa29ca6178bd5da8f1add76ad4e93696ad0c71598f0d"

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
