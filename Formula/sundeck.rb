class Sundeck < Formula
  desc "Converge isolated Daydream development environments"
  homepage "https://github.com/tomdai/homebrew-sundeck"
  url "https://github.com/tomdai/homebrew-sundeck/releases/download/v0.15.0/sundeck-macos-arm64.tar.gz"
  version "0.15.0"
  sha256 "655dd9e95cd8de329c48d996f8dd1057799543d601554451adfaa62ec677a99d"

  depends_on arch: :arm64
  depends_on macos: :sequoia

  def install
    bin.install "sundeck"
  end

  def caveats
    <<~EOS
      An update to ~/.sundeck may be required.
      Release and migration notes:
        https://github.com/tomdai/homebrew-sundeck/releases/tag/v0.15.0
    EOS
  end

  test do
    assert_equal version.to_s, shell_output("#{bin}/sundeck --version").strip
    assert_match "USAGE:", shell_output("#{bin}/sundeck --help")
  end
end
