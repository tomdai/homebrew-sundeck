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
      Upgrading from Sundeck 0.9.1 or earlier:
        Add mcpOauth to the shared Daydream.ClientApi configuration in
        ~/.sundeck/workspace and supply development signing/encryption
        certificates. Preserve existing credentials; generate only missing ones.
        Run `sundeck device inputs check`, then `sundeck up` in each affected
        Daydream worktree. Restart alone does not republish shared inputs.

      Upgrading from Sundeck 0.9.0 or earlier:
        In configuration.development.json for Daydream.ClientApi,
        Daydream.GrowthLeadAgent, and Daydream.McpModuleHost under
        ~/.sundeck/workspace, rename frontendBaseUrl to frontendBaseUrls
        and wrap its existing string value in an array.
        Then run `sundeck up` in each affected Daydream worktree.

      Agent-ready migration instructions:
        https://github.com/tomdai/homebrew-sundeck/releases/tag/v0.9.2
    EOS
  end

  test do
    assert_equal version.to_s, shell_output("#{bin}/sundeck --version").strip
    assert_match "USAGE:", shell_output("#{bin}/sundeck --help")
  end
end
