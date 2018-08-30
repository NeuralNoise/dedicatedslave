module dedicatedslave.loader;

import std.file;
import dedicatedslave.steamapi;
import DedicatedSlave = dedicatedslave;

class Loader {
	this() {
		{
			version(Windows) {
				import std.c.windows.windows;
			} else version(OSX) {
				extern(C) int _NSGetExecutablePath(char* buf, uint* bufsize);
			} else version(linux) {
				 import core.sys.posix.unistd : readlink;
			} else {
				static assert(0);
			}
			import std.conv;
			import std.string;
			import std.path;

			static string cachedExecutablePath;
			if (!cachedExecutablePath) {
				char[4096] buf;
				long filePathLength;
		
				version(Windows) {
					filePathLength = GetModuleFileNameA(null, buf.ptr, buf.length - 1);
					assert(filePathLength != 0);
				}
				else version(OSX) {
					filePathLength = cast(long) (buf.length - 1);
					int res = _NSGetExecutablePath(buf.ptr, &filePathLength);
					assert(res == 0);
				}
				else version(linux) {
					filePathLength = readlink(toStringz("/proc/self/exe"), buf.ptr, buf.length - 1);
				}
				else {
					static assert(0);
				}
				cachedExecutablePath = to!string(buf[0 .. filePathLength]);
			}
			exe_path = cachedExecutablePath.dirName ~ "/";
		}
		if(!exists(exe_path~DedicatedSlave.realPath))
			installEnvironment();

		steamapi_instance = new SteamAPI(this);
	}

	void installEnvironment()
	{
		_changeLogState("Installing the environment...");

		if(exists(exe_path~DedicatedSlave.tmpPath))
			rmdirRecurse(exe_path~DedicatedSlave.tmpPath);
		mkdir(exe_path~DedicatedSlave.tmpPath);

		_changeLogState("Downloading " ~ DedicatedSlave.urlPlatform ~ "...");
		import std.net.curl : download;
		import std.path : extension;
		immutable string steamcmd_extension = extension(DedicatedSlave.urlPlatform);
		immutable string steamcmd_filename = exe_path~DedicatedSlave.tmpPath~"steamcmd"~extension(DedicatedSlave.urlPlatform);
		download(DedicatedSlave.urlPlatform, steamcmd_filename);
		
		_changeLogState("Extracting " ~ steamcmd_filename ~ "...");
		if(steamcmd_extension == ".gz")
		{
			import archive.targz;
			import std.stdio: writeln;

			auto archive_file = new TarGzArchive(read(steamcmd_filename));
			mkdir(exe_path~DedicatedSlave.tmpPath~"steamcmd/");

			foreach (memberFile; archive_file.directories)
			{
				_changeLogState("Create directory " ~ memberFile.path ~ "...");
				mkdir(exe_path~DedicatedSlave.tmpPath~"steamcmd/"~memberFile.path);
				_changeLogState("Set attributes for " ~ memberFile.path ~ "...");
				setAttributes(exe_path~DedicatedSlave.tmpPath~"steamcmd/"~memberFile.path, memberFile.permissions);
			}

			foreach (memberFile; archive_file.files)
			{
				_changeLogState("Extracting " ~ memberFile.path ~ "...");
				write(exe_path~DedicatedSlave.tmpPath~"steamcmd/"~memberFile.path, memberFile.data);
				_changeLogState("Set attributes for " ~ memberFile.path ~ "...");
				setAttributes(exe_path~DedicatedSlave.tmpPath~"steamcmd/"~memberFile.path, memberFile.permissions);
			}
		}
		_changeLogState("Delete "~steamcmd_filename~"...");
		remove(steamcmd_filename);

		_changeLogState("Finishing setup...");
		rename(exe_path~DedicatedSlave.tmpPath, exe_path~DedicatedSlave.realPath);
	}

	SteamAPI steamapi_instance;
	string exe_path;

protected:
	void _internalLogger(immutable string msg) {}

private:
	package final void _changeLogState(immutable string msg)
	{
		import std.experimental.logger : info;
		info(msg);
		_internalLogger(msg);
	}
}
