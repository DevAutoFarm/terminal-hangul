cask "terminal-hangul" do
  version "1.0.0"
  sha256 :no_check

  url "https://github.com/USERNAME/terminal-hangul/releases/download/v#{version}/terminalHangul.app.zip"
  name "terminalHangul"
  desc "Menu bar utility for Korean character composition in Terminal"
  homepage "https://github.com/USERNAME/terminal-hangul"

  livecheck do
    url :url
    strategy :github_latest
  end

  depends_on macos: ">= :monterey"

  app "terminalHangul.app"

  postflight do
    system_command "/usr/bin/defaults",
                   args: ["write", "com.yourcompany.terminalHangul", "SUEnableAutomaticChecks", "-bool", "true"]
  end

  zap trash: [
    "~/Library/Application Support/terminalHangul",
    "~/Library/Caches/com.yourcompany.terminalHangul",
    "~/Library/Preferences/com.yourcompany.terminalHangul.plist",
  ]

  caveats <<~EOS
    terminalHangul is a menu bar application.

    To use terminalHangul:
    1. Launch the application from your Applications folder
    2. Grant Accessibility permissions when prompted
    3. The app will appear in your menu bar

    For more information, visit:
    https://github.com/USERNAME/terminal-hangul
  EOS
end
