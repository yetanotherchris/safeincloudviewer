class Safeincloudviewer < Formula
  desc "A command line tool for viewing SafeInCloud password database files"
  homepage "https://github.com/yetanotherchris/safeincloudviewer"
  version "1.0.1"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/yetanotherchris/safeincloudviewer/releases/download/v1.0.1/safeincloudviewer-v1.0.1-osx-arm64"
      sha256 "04c096faeaa17b5073eb205875341ebc82a5c9eeeac0e3765c108408b4bf5af2"
    else
      url "https://github.com/yetanotherchris/safeincloudviewer/releases/download/v1.0.1/safeincloudviewer-v1.0.1-osx-x64"
      sha256 "b147888fc19880e49f06736d3a951a9855e680e7b3dfd1c9dd477c22dcd33233"
    end
  end

  on_linux do
    url "https://github.com/yetanotherchris/safeincloudviewer/releases/download/v1.0.1/safeincloudviewer-v1.0.1-linux-x64"
    sha256 "e56e6917278056875416703c5d7d3c9bcee22b6d4363162e804d4b53e7f9fa4f"
  end

  def install
    if OS.mac?
      if Hardware::CPU.arm?
        bin.install "safeincloudviewer-v1.0.1-osx-arm64" => "safeincloudviewer"
      else
        bin.install "safeincloudviewer-v1.0.1-osx-x64" => "safeincloudviewer"
      end
    else
      bin.install "safeincloudviewer-v1.0.1-linux-x64" => "safeincloudviewer"
    end
  end

  test do
    assert_match "SafeInCloud.db", shell_output("#{bin}/safeincloudviewer 2>&1", 1)
  end
end

