module dedicatedslave;

enum {
	tmpPath = "._dedicatedslave\\",
	realPath = ".dedicatedslave\\"
}

version(linux) enum {
		execPathPlatform = "linux32/",
		execFilePlatform = "steamcmd",
		urlPlatform = "https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz"
	}
else version(Windows) enum {
		execPathPlatform = "\\",
		execFilePlatform = "steamcmd.exe",
		urlPlatform = "https://steamcdn-a.akamaihd.net/client/installer/steamcmd.zip"
	}
else version(OSX) enum {
		execPathPlatform = "osx/",
		execFilePlatform = "steamcmd",
		urlPlatform = "https://steamcdn-a.akamaihd.net/client/installer/steamcmd_osx.tar.gz"
	}
