class Sundeck < Formula
  desc "Converge isolated Daydream development environments"
  homepage "https://github.com/tomdai/homebrew-sundeck"
  url "https://github.com/tomdai/homebrew-sundeck/releases/download/v0.9.2/sundeck-macos-arm64.tar.gz"
  version "0.9.2"
  sha256 "fd88a469bd1854db340e89d45ee7e8bf6f98a6800af10e12b21517a965de8f6d"

  depends_on arch: :arm64
  depends_on macos: :tahoe

  def install
    bin.install "sundeck"
  end

  def caveats
    <<~EOS
      An update to ~/.sundeck may be required.
      Migration reference for your coding agent:
        https://github.com/tomdai/homebrew-sundeck/releases/tag/v0.9.2
    EOS
  end

  test do
    assert_equal version.to_s, shell_output("#{bin}/sundeck --version").strip
    assert_match "USAGE:", shell_output("#{bin}/sundeck --help")
  end
end
