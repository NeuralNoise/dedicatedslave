module dedicatedslave.loader;

import std.file;
import std.path;
import dedicatedslave.steamapi;
import DedicatedSlave = dedicatedslave;

class Loader {
	this()
	{
		exe_path = thisExePath.dirName ~ "/";
		if(!exists(exe_path~DedicatedSlave.realPath))
			installEnvironment();

		steamapi_instance = new SteamAPI(this);
	}

	void installEnvironment()
	{
		changeLogState("Installing the environment...");

		if(exists(exe_path~DedicatedSlave.tmpPath))
			rmdirRecurse(exe_path~DedicatedSlave.tmpPath);
		mkdir(exe_path~DedicatedSlave.tmpPath);

		changeLogState("Downloading " ~ DedicatedSlave.urlPlatform ~ "...");
		import std.net.curl : download;
		import std.path : extension;
		immutable string steamcmd_extension = extension(DedicatedSlave.urlPlatform);
		immutable string steamcmd_filename = exe_path~DedicatedSlave.tmpPath~"steamcmd"~extension(DedicatedSlave.urlPlatform);
		download(DedicatedSlave.urlPlatform, steamcmd_filename);
		
		changeLogState("Extracting " ~ steamcmd_filename ~ "...");
		if(steamcmd_extension == ".gz")
		{
			import archive.targz;
			import std.stdio: writeln;

			auto archive_file = new TarGzArchive(read(steamcmd_filename));
			mkdir(exe_path~DedicatedSlave.tmpPath~"steamcmd/");

			foreach (memberFile; archive_file.directories)
			{
				changeLogState("Create directory " ~ memberFile.path ~ "...");
				mkdir(exe_path~DedicatedSlave.tmpPath~"steamcmd/"~memberFile.path);
				changeLogState("Set attributes for " ~ memberFile.path ~ "...");
				setAttributes(exe_path~DedicatedSlave.tmpPath~"steamcmd/"~memberFile.path, memberFile.permissions);
			}

			foreach (memberFile; archive_file.files)
			{
				changeLogState("Extracting " ~ memberFile.path ~ "...");
				write(exe_path~DedicatedSlave.tmpPath~"steamcmd/"~memberFile.path, memberFile.data);
				changeLogState("Set attributes for " ~ memberFile.path ~ "...");
				setAttributes(exe_path~DedicatedSlave.tmpPath~"steamcmd/"~memberFile.path, memberFile.permissions);
			}
		}
		changeLogState("Delete "~steamcmd_filename~"...");
		remove(steamcmd_filename);

		changeLogState("Finishing setup...");
		rename(exe_path~DedicatedSlave.tmpPath, exe_path~DedicatedSlave.realPath);
	}

	void changeLogState(immutable string msg)
	{
		import std.experimental.logger : info;
		info(msg);
	}

	SteamAPI steamapi_instance;
	string exe_path;
}
