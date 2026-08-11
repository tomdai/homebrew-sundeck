class Sundeck < Formula
  desc "Converge isolated Daydream development environments"
  homepage "https://github.com/tomdai/homebrew-sundeck"
  url "https://github.com/tomdai/homebrew-sundeck/releases/download/v0.8.8/sundeck-macos-arm64.tar.gz"
  version "0.8.8"
  sha256 "67007e26ff4bcfc740692abf922b91a01e4145561b9cd977c4c8f31fd9f59d2d"

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
