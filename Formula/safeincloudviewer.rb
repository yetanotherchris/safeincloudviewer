class Safeincloudviewer < Formula
  desc "A command line tool for viewing SafeInCloud password database files"
  homepage "https://github.com/yetanotherchris/safeincloudviewer"
  version "0.1.0"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/yetanotherchris/safeincloudviewer/releases/download/v0.1.0/safeincloudviewer-v0.1.0-osx-arm64"
      sha256 ""
    else
      url "https://github.com/yetanotherchris/safeincloudviewer/releases/download/v0.1.0/safeincloudviewer-v0.1.0-osx-x64"
      sha256 ""
    end
  end

  on_linux do
    url "https://github.com/yetanotherchris/safeincloudviewer/releases/download/v0.1.0/safeincloudviewer-v0.1.0-linux-x64"
    sha256 ""
  end

  def install
    if OS.mac?
      if Hardware::CPU.arm?
        bin.install "safeincloudviewer-v0.1.0-osx-arm64" => "safeincloudviewer"
      else
        bin.install "safeincloudviewer-v0.1.0-osx-x64" => "safeincloudviewer"
      end
    else
      bin.install "safeincloudviewer-v0.1.0-linux-x64" => "safeincloudviewer"
    end
  end

  test do
    assert_match "SafeInCloud.db", shell_output("#{bin}/safeincloudviewer 2>&1", 1)
  end
end
