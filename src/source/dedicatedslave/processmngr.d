module dedicatedslave.processmngr;

import DedicatedSlave = dedicatedslave;
import dedicatedslave.loader;
import dedicatedslave.logger;

import core.thread;
import std.process;

class ProcessManager {

	private ProcessPipes pipeproc_handler;
	private Thread _thread_handler;
	private Loader _loader;
    private string _cmd;

	this(Loader loader)
	{
		_loader = loader;
		_thread_handler = new Thread(&createNewProcess).start();
	}

public:

    // TODO: Pass arguments throw threads (runCmd function should have a cmd string argument)
    void runCmdThread(string runcmd)
	{
        _cmd = runcmd;
		_thread_handler = new Thread(&runCmd).start();
	}

private:

	void createNewProcess()
	{
		pipeproc_handler = pipeShell(_loader.exe_path~DedicatedSlave.realPath~"steamcmd\\"~DedicatedSlave.execPathPlatform~DedicatedSlave.execFilePlatform, Redirect.all, ["LD_LIBRARY_PATH":_loader.exe_path~DedicatedSlave.realPath~"steamcmd\\"~DedicatedSlave.execPathPlatform]);
		scope(exit) wait(pipeproc_handler.pid);

		foreach (line; pipeproc_handler.stdout.byLine) _loader.changeLogState(line.idup);
		foreach (line; pipeproc_handler.stderr.byLine) _loader.changeLogState(line.idup);
	}

    void runCmd()
    {
        pipeproc_handler = pipeShell(_cmd, Redirect.all, ["LD_LIBRARY_PATH":_loader.exe_path~DedicatedSlave.realPath~"steamcmd\\"~DedicatedSlave.execPathPlatform]);
		scope(exit) wait(pipeproc_handler.pid);
		foreach (line; pipeproc_handler.stdout.byLine) _loader.changeLogState(line.idup);
		foreach (line; pipeproc_handler.stderr.byLine) _loader.changeLogState(line.idup);
    }

}