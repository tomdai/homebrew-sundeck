class Sundeck < Formula
  desc "Converge isolated Daydream development environments"
  homepage "https://github.com/tomdai/homebrew-sundeck"
  url "https://github.com/tomdai/homebrew-sundeck/releases/download/v0.12.3/sundeck-macos-arm64.tar.gz"
  version "0.12.3"
  sha256 "c524849a0bc1870c00bc43993e8994489f3731a3f8a7e3151af33bf20d8488f3"

  depends_on arch: :arm64
  depends_on macos: :sequoia

  def install
    bin.install "sundeck"
  end

  def caveats
    <<~EOS
      An update to ~/.sundeck may be required.
      Release and migration notes:
        https://github.com/tomdai/homebrew-sundeck/releases/tag/v0.12.3
    EOS
  end

  test do
    assert_equal version.to_s, shell_output("#{bin}/sundeck --version").strip
    assert_match "USAGE:", shell_output("#{bin}/sundeck --help")
  end
end
