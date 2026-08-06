class Sundeck < Formula
  desc "Converge isolated Daydream development environments"
  homepage "https://github.com/tomdai/homebrew-sundeck"
  url "https://github.com/tomdai/homebrew-sundeck/releases/download/v0.8.6/sundeck-macos-arm64.tar.gz"
  version "0.8.6"
  sha256 "4e8e039f56e7599e3eb20e75b889e257041bee30d53ed256ee69495d51def4d9"

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
