module dedicatedslave.loader;

import std.file;
import dedicatedslave.steamapi;
import DedicatedSlave = dedicatedslave;

class Loader {
	this() {
		if(!exists(DedicatedSlave.realPath))
			installEnvironment();

		steamapi_instance = new SteamAPI(&_changeLogState);
	}

	void installEnvironment()
	{
		_changeLogState("Installing the environment...");

		if(exists(DedicatedSlave.tmpPath))
			rmdirRecurse(DedicatedSlave.tmpPath);
		mkdir(DedicatedSlave.tmpPath);

		_changeLogState("Downloading " ~ DedicatedSlave.urlPlatform ~ "...");
		import std.net.curl : download;
		import std.path : extension;
		immutable string steamcmd_extension = extension(DedicatedSlave.urlPlatform);
		immutable string steamcmd_filename = DedicatedSlave.tmpPath~"steamcmd"~extension(DedicatedSlave.urlPlatform);
		download(DedicatedSlave.urlPlatform, steamcmd_filename);
		
		_changeLogState("Extracting " ~ steamcmd_filename ~ "...");
		if(steamcmd_extension == ".gz")
		{
			import archive.targz;
			import std.stdio: writeln;

			auto archive_file = new TarGzArchive(read(steamcmd_filename));
			mkdir(DedicatedSlave.tmpPath~"steamcmd/");

			foreach (memberFile; archive_file.directories)
			{
				_changeLogState("Create directory " ~ memberFile.path ~ "...");
				mkdir(DedicatedSlave.tmpPath~"steamcmd/"~memberFile.path);
				_changeLogState("Set attributes for " ~ memberFile.path ~ "...");
				setAttributes(DedicatedSlave.tmpPath~"steamcmd/"~memberFile.path, memberFile.permissions);
			}

			foreach (memberFile; archive_file.files)
			{
				_changeLogState("Extracting " ~ memberFile.path ~ "...");
				write(DedicatedSlave.tmpPath~"steamcmd/"~memberFile.path, memberFile.data);
				_changeLogState("Set attributes for " ~ memberFile.path ~ "...");
				setAttributes(DedicatedSlave.tmpPath~"steamcmd/"~memberFile.path, memberFile.permissions);
			}
		}
		_changeLogState("Delete "~steamcmd_filename~"...");
		remove(steamcmd_filename);

		_changeLogState("Finishing setup...");
		rename(DedicatedSlave.tmpPath, DedicatedSlave.realPath);
	}

	SteamAPI steamapi_instance;

protected:
	void _internalLogger(immutable string msg) {}

private:
	void _changeLogState(immutable string msg)
	{
		import std.experimental.logger : info;
		info(msg);
		_internalLogger(msg);
	}
}
