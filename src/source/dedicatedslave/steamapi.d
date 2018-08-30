module dedicatedslave.steamapi;

import DedicatedSlave = dedicatedslave;

import core.thread;
import std.process;

class SteamAPI {
	this(void delegate(immutable(string)) funcChangeLogState)
	{
		_changeLogState = funcChangeLogState;
		_thread_handler = new Thread(&createNewProcess).start();
	}

	ProcessPipes pipeproc_handler;

private:

	Thread _thread_handler;

	void delegate(immutable(string)) _changeLogState;

	void createNewProcess()
	{
		pipeproc_handler = pipeShell(DedicatedSlave.realPath~"steamcmd/"~DedicatedSlave.execPathPlatform~DedicatedSlave.execFilePlatform, Redirect.all, ["LD_LIBRARY_PATH":DedicatedSlave.realPath~"steamcmd/"~DedicatedSlave.execPathPlatform]);
		scope(exit) wait(pipeproc_handler.pid);

		foreach (line; pipeproc_handler.stdout.byLine) _changeLogState(line.idup);
		foreach (line; pipeproc_handler.stderr.byLine) _changeLogState(line.idup);
	}
}