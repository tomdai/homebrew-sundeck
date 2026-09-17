class Sundeck < Formula
  desc "Converge isolated Daydream development environments"
  homepage "https://github.com/tomdai/homebrew-sundeck"
  url "https://github.com/tomdai/homebrew-sundeck/releases/download/v0.9.1/sundeck-macos-arm64.tar.gz"
  version "0.9.1"
  sha256 "e8f59db847432313c77378a2e8f56a51dbe204e3ab7679c5a9f7e4697a151586"

  depends_on arch: :arm64
  depends_on macos: :tahoe

  def install
    bin.install "sundeck"
  end

  def caveats
    <<~EOS
      Upgrading from Sundeck 0.9.0 or earlier:
        In configuration.development.json for Daydream.ClientApi,
        Daydream.GrowthLeadAgent, and Daydream.McpModuleHost under
        ~/.sundeck/workspace, rename frontendBaseUrl to frontendBaseUrls
        and wrap its existing string value in an array.
        Then run `sundeck up` in each affected Daydream worktree.

      Migration details: https://github.com/tomdai/homebrew-sundeck/releases/tag/v0.9.1
    EOS
  end

  test do
    assert_equal version.to_s, shell_output("#{bin}/sundeck --version").strip
    assert_match "USAGE:", shell_output("#{bin}/sundeck --help")
  end
end
