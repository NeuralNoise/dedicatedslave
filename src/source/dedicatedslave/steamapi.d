module dedicatedslave.steamapi;

import DedicatedSlave = dedicatedslave;
import dedicatedslave.loader;

import core.thread;
import std.process;

import dedicatedslave.data.models;

class SteamAPI {
	this(Loader loader)
	{
		_loader = loader;
		_thread_handler = new Thread(&createNewProcess).start();
		//createNewProcess();
		a = new RustGameInstance("First");
	}
	GameInstance a;
	ProcessPipes pipeproc_handler;

public:
	GameInstance ss()
	{
		return a;
	}

	void runInst()
	{
		//_thread_handler.exit();
		_thread_handler = new Thread(&runInsts).start();
	}

private:

	Thread _thread_handler;

	Loader _loader;

	void createNewProcess()
	{
		pipeproc_handler = pipeShell(_loader.exe_path~DedicatedSlave.realPath~"steamcmd\\"~DedicatedSlave.execPathPlatform~DedicatedSlave.execFilePlatform, Redirect.all, ["LD_LIBRARY_PATH":_loader.exe_path~DedicatedSlave.realPath~"steamcmd\\"~DedicatedSlave.execPathPlatform]);
		scope(exit) wait(pipeproc_handler.pid);

		foreach (line; pipeproc_handler.stdout.byLine) _loader.changeLogState(line.idup);
		foreach (line; pipeproc_handler.stderr.byLine) _loader.changeLogState(line.idup);
	}

	void runInsts()
	{
		//string runcmd = _loader.exe_path~DedicatedSlave.realPath~"steamcmd\\"~DedicatedSlave.execPathPlatform~DedicatedSlave.execFilePlatform;
		//string runcmd = _loader.exe_path~DedicatedSlave.realPath~"steamcmd\\"~DedicatedSlave.execPathPlatform~DedicatedSlave.execFilePlatform~" +login anonymous +force_install_dir D:\\ProgramFiles\\ProgramFiles\\RustServer +app_update 258550 +quit";
		string runcmd = _loader.instances_path~"RustDedicated.exe -batchmode +server.port 28015 +server.level \"Procedural Map\" +server.seed 1234 +server.worldsize 4000 +server.maxplayers 10  +server.hostname \"alex1a's Rust Server\" +server.description \"This is my dev server.\" +server.url \"http://alexjorge.me\" +server.headerimage \"http://yourwebsite.com/serverimage.jpg\" +server.identity \"server1\" +rcon.port 28016 +rcon.password letmein +rcon.web 1";

		pipeproc_handler = pipeShell(runcmd, Redirect.all, ["LD_LIBRARY_PATH":_loader.exe_path~DedicatedSlave.realPath~"steamcmd\\"~DedicatedSlave.execPathPlatform]);
		scope(exit) wait(pipeproc_handler.pid);

		foreach (line; pipeproc_handler.stdout.byLine) _loader.changeLogState(line.idup);
		foreach (line; pipeproc_handler.stderr.byLine) _loader.changeLogState(line.idup);
	}
}