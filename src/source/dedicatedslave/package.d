module dedicatedslave;

enum {
	tmpPath = "._dedicatedslave/",
	realPath = ".dedicatedslave/"
}

version(linux) enum {
		execPathPlatform = "linux32/",
		execFilePlatform = "steamcmd",
		urlPlatform = "https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz"
	}
else version(windows) enum {
		urlPlatform = "https://steamcdn-a.akamaihd.net/client/installer/steamcmd.zip"
	}
else version(OSX) enum {
		urlPlatform = "https://steamcdn-a.akamaihd.net/client/installer/steamcmd_osx.tar.gz"
	}
