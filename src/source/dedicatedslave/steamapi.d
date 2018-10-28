module dedicatedslave.steamapi;

import DedicatedSlave = dedicatedslave;
import dedicatedslave.loader;

import core.thread;
import std.process;

import dedicatedslave.models.gameinstances;

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
}