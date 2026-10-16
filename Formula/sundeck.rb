class Sundeck < Formula
  desc "Converge isolated Daydream development environments"
  homepage "https://github.com/tomdai/homebrew-sundeck"
  url "https://github.com/tomdai/homebrew-sundeck/releases/download/v0.15.1/sundeck-macos-arm64.tar.gz"
  version "0.15.1"
  sha256 "ea6f03654261b2f67a3236c9bac7fd96d907c87c48eb03662050d25af88dd962"

  depends_on arch: :arm64
  depends_on macos: :sequoia

  def install
    bin.install "sundeck"
  end

  def caveats
    <<~EOS
      An update to ~/.sundeck may be required.
      Release and migration notes:
        https://github.com/tomdai/homebrew-sundeck/releases/tag/v0.15.1
    EOS
  end

  test do
    assert_equal version.to_s, shell_output("#{bin}/sundeck --version").strip
    assert_match "USAGE:", shell_output("#{bin}/sundeck --help")
  end
end
