module dedicatedslave.loader;

import std.file;
import core.thread;
import std.process;

class Loader {
	this() {
		if(!exists(_realPath))
			installEnvironment();
	}

	void installEnvironment()
	{
		_changeLogState("Installing the environment...");
		import std.json : JSONValue, parseJSON;
		immutable JSONValue envconfig = parseJSON(cast(string)read("assets/envconfig.json"));
		if(exists(_tmpPath))
			rmdirRecurse(_tmpPath);
		mkdir(_tmpPath);

		version(Windows) enum os_version = "windows";
		else version(linux) enum os_version = "linux";
		else version(OSX) enum os_version = "macos";
		immutable string url = envconfig[os_version].str;

		_changeLogState("Downloading " ~ url ~ "...");
		import std.net.curl : download;
		import std.path : extension;
		immutable string steamcmd_extension = extension(url);
		immutable string steamcmd_filename = _tmpPath~"steamcmd"~extension(url);
		download(url, steamcmd_filename);
		
		_changeLogState("Extracting " ~ steamcmd_filename ~ "...");
		if(steamcmd_extension == ".gz")
		{
			import archive.targz;
			import std.stdio: writeln;

			auto archive_file = new TarGzArchive(read(steamcmd_filename));
			archive_file.getDirectory("");
			mkdir(_tmpPath~"steamcmd/");
			foreach (memberFile; archive_file.directories)
			{
				_changeLogState("Create directory " ~ memberFile.path ~ "...");
				mkdir(_tmpPath~"steamcmd/"~memberFile.path);
				_changeLogState("Set attributes for " ~ memberFile.path ~ "...");
				setAttributes(_tmpPath~"steamcmd/"~memberFile.path, memberFile.permissions);

			}
			foreach (memberFile; archive_file.files)
			{
				_changeLogState("Extracting " ~ memberFile.path ~ "...");
				write(_tmpPath~"steamcmd/"~memberFile.path, memberFile.data);
				_changeLogState("Set attributes for " ~ memberFile.path ~ "...");
				setAttributes(_tmpPath~"steamcmd/"~memberFile.path, memberFile.permissions);
			}
		}
		_changeLogState("Delete "~steamcmd_filename~"...");
		remove(steamcmd_filename);

		_changeLogState("Finishing setup...");
		rename(_tmpPath, _realPath);

		
		_exec_thread = new Thread({
			_exec_proc = pipeShell(_realPath~"steamcmd/"~"steamcmd"~_execExtension);
			scope(exit) wait(_exec_proc.pid);

			foreach (line; _exec_proc.stdout.byLine) _changeLogState(line.idup);
			foreach (line; _exec_proc.stderr.byLine) _changeLogState(line.idup);
		}).start();
	}

protected:
	void _internalLogger(immutable string msg) {}

private:
	void _changeLogState(immutable string msg)
	{
		import std.experimental.logger : info;
		info(msg);
		_internalLogger(msg);
	}

	Thread _exec_thread;
	ProcessPipes _exec_proc;

	enum {
		_tmpPath = "._dedicatedslave/",
		_realPath = ".dedicatedslave/"
	}

	version(linux) enum _execExtension = ".sh";
}
