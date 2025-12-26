class Safeincloudviewer < Formula
  desc "A command line tool for viewing SafeInCloud password database files"
  homepage "https://github.com/yetanotherchris/safeincloudviewer"
  version "1.0.2"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/yetanotherchris/safeincloudviewer/releases/download/v1.0.2/safeincloudviewer-v1.0.2-osx-arm64"
      sha256 "4c70b76d6f4cebe7674bfd2e1a43293ca02cf1384cd2f657f69a20ab7b91870e"
    else
      url "https://github.com/yetanotherchris/safeincloudviewer/releases/download/v1.0.2/safeincloudviewer-v1.0.2-osx-x64"
      sha256 "bbf7360ec4020baaed4fc63ef481f1b59d720a25a1829944ad4c4174c3429e1c"
    end
  end

  on_linux do
    url "https://github.com/yetanotherchris/safeincloudviewer/releases/download/v1.0.2/safeincloudviewer-v1.0.2-linux-x64"
    sha256 "49b9f7176051d4cfe50b1f13f706442f75970e1ad26a57fe8662c0994192a403"
  end

  def install
    if OS.mac?
      if Hardware::CPU.arm?
        bin.install "safeincloudviewer-v1.0.2-osx-arm64" => "safeincloudviewer"
      else
        bin.install "safeincloudviewer-v1.0.2-osx-x64" => "safeincloudviewer"
      end
    else
      bin.install "safeincloudviewer-v1.0.2-linux-x64" => "safeincloudviewer"
    end
  end

  test do
    assert_match "SafeInCloud.db", shell_output("#{bin}/safeincloudviewer 2>&1", 1)
  end
end


