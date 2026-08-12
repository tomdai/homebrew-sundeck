class Sundeck < Formula
  desc "Converge isolated Daydream development environments"
  homepage "https://github.com/tomdai/homebrew-sundeck"
  url "https://github.com/tomdai/homebrew-sundeck/releases/download/v0.8.10/sundeck-macos-arm64.tar.gz"
  version "0.8.10"
  sha256 "49b301bf59b760430aa64d57987bb2d5b62b96fb36380fdd39ea50a2d225dd74"

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
