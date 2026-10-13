class Sundeck < Formula
  desc "Converge isolated Daydream development environments"
  homepage "https://github.com/tomdai/homebrew-sundeck"
  url "https://github.com/tomdai/homebrew-sundeck/releases/download/v0.14.0/sundeck-macos-arm64.tar.gz"
  version "0.14.0"
  sha256 "bed620e5836153993d8c8455da32052aaa00e7ed6758cd8fa2b22753e6e55ba9"

  depends_on arch: :arm64
  depends_on macos: :sequoia

  def install
    bin.install "sundeck"
  end

  def caveats
    <<~EOS
      An update to ~/.sundeck may be required.
      Release and migration notes:
        https://github.com/tomdai/homebrew-sundeck/releases/tag/v0.14.0
    EOS
  end

  test do
    assert_equal version.to_s, shell_output("#{bin}/sundeck --version").strip
    assert_match "USAGE:", shell_output("#{bin}/sundeck --help")
  end
end
