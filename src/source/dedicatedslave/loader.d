module dedicatedslave.loader;

import std.file;
import std.path;
import DedicatedSlave = dedicatedslave;

class Loader {
	this()
	{
		exe_path = thisExePath.dirName ~ "\\";
		if(!exists(exe_path~DedicatedSlave.realPath))
			installEnvironment();
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
			changeLogState("Create directory "~exe_path~DedicatedSlave.tmpPath~"steamcmd\\");
			mkdir(exe_path~DedicatedSlave.tmpPath~"steamcmd\\");

			foreach (memberFile; archive_file.directories)
			{
				changeLogState("Create directory "~memberFile.path~"...");
				mkdir(exe_path~DedicatedSlave.tmpPath~"steamcmd\\"~memberFile.path);
				changeLogState("Set attributes for "~memberFile.path~"...");
				setAttributes(exe_path~DedicatedSlave.tmpPath~"steamcmd\\"~memberFile.path, memberFile.permissions);
			}

			foreach (memberFile; archive_file.files)
			{
				changeLogState("Extracting "~memberFile.path~"...");
				write(exe_path~DedicatedSlave.tmpPath~"steamcmd\\"~memberFile.path, memberFile.data);
				changeLogState("Set attributes for "~memberFile.path~"...");
				setAttributes(exe_path~DedicatedSlave.tmpPath~"steamcmd\\"~memberFile.path, memberFile.permissions);
			}
		}
		if(steamcmd_extension == ".zip")
		{
			import archive.zip;
			import std.stdio: writeln;

			auto archive_file = new ZipArchive(read(steamcmd_filename));
			changeLogState("Create directory "~exe_path~DedicatedSlave.tmpPath~"steamcmd\\");
			mkdir(exe_path~DedicatedSlave.tmpPath~"steamcmd\\");

			foreach (memberFile; archive_file.directories)
			{
				changeLogState("Create directory "~memberFile.path~"...");
				mkdir(exe_path~DedicatedSlave.tmpPath~"steamcmd\\"~memberFile.path);
				changeLogState("Set attributes for "~memberFile.path~"...");
			}

			foreach (memberFile; archive_file.files)
			{
				changeLogState("Extracting "~memberFile.path~"...");
				write(exe_path~DedicatedSlave.tmpPath~"steamcmd\\"~memberFile.path, memberFile.data);
				changeLogState("Set attributes for "~memberFile.path~"...");
			}
		}
		changeLogState("Delete "~steamcmd_filename~"...");
		remove(steamcmd_filename);

		changeLogState("Finishing setup...");
		changeLogState("Renaming "~exe_path~DedicatedSlave.tmpPath~" TO "~exe_path~DedicatedSlave.realPath);
		rename(exe_path~DedicatedSlave.tmpPath, exe_path~DedicatedSlave.realPath);
	}

	void changeLogState(immutable string msg)
	{
		import std.experimental.logger : info;
		info(msg);
	}

	string exe_path;
}
