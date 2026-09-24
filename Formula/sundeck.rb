class Sundeck < Formula
  desc "Converge isolated Daydream development environments"
  homepage "https://github.com/tomdai/homebrew-sundeck"
  url "https://github.com/tomdai/homebrew-sundeck/releases/download/v0.10.0/sundeck-macos-arm64.tar.gz"
  version "0.10.0"
  sha256 "10cd41de9b31c52a8df7193eabc0bee73a1bebc66ee8ed460c326cad80ca99fe"

  depends_on arch: :arm64
  depends_on macos: :tahoe

  def install
    bin.install "sundeck"
  end

  def caveats
    <<~EOS
      An update to ~/.sundeck may be required.
      Release and migration notes:
        https://github.com/tomdai/homebrew-sundeck/releases/tag/v0.10.0
    EOS
  end

  test do
    assert_equal version.to_s, shell_output("#{bin}/sundeck --version").strip
    assert_match "USAGE:", shell_output("#{bin}/sundeck --help")
  end
end
