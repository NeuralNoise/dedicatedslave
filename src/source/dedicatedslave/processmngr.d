module dedicatedslave.processmngr;

import DedicatedSlave = dedicatedslave;
import dedicatedslave.loader;
import dedicatedslave.logger;

import core.thread;
import std.process;

import std.outbuffer;

class ProcessManager {

private:

	ProcessPipes pipeproc_handler;
	Thread _thread_handler;
	Loader _loader;
    string _cmd;
	OutBuffer buf;

	void createNewProcess(){

		string a = "";
		a ~= _loader.exe_path;
		a ~= DedicatedSlave.realPath;
		a ~= "steamcmd\\";
		a ~= DedicatedSlave.execPathPlatform;
		
		string b = "";
		b ~= _loader.exe_path;
		b ~= DedicatedSlave.realPath;
		b ~= "steamcmd\\";
		b ~= DedicatedSlave.execPathPlatform;

		string[string] c = ["LD_LIBRARY_PATH":b];

		pipeproc_handler = pipeShell(a, Redirect.all, c);
		scope(exit) wait(pipeproc_handler.pid);

		foreach (line; pipeproc_handler.stdout.byLine){
			_loader.changeLogState(line.idup, 1);
			buf.write(line.idup);
		}
		foreach (line; pipeproc_handler.stderr.byLine){
			_loader.changeLogState(line.idup, 1);
			buf.write(line.idup);
		}
	}

    void runCmd(){

		string b = "";
		b ~= _loader.exe_path;
		b ~= DedicatedSlave.realPath;
		b ~= "steamcmd\\";
		b ~= DedicatedSlave.execPathPlatform;

		string[string] c = ["LD_LIBRARY_PATH":b];

		// Starts a new process, creating pipes to redirect its standard input, output and/or error streams. 
        pipeproc_handler = pipeShell(_cmd, Redirect.all, c);
		// makes the parent process wait for a child process to terminate.
		scope(exit) wait(pipeproc_handler.pid);
		foreach (line; pipeproc_handler.stdout.byLine){
			_loader.changeLogState(line.idup, 1);
		}
		foreach (line; pipeproc_handler.stderr.byLine){
			_loader.changeLogState(line.idup, 1);
		}
    }
	
public:

	this(Loader loader){
		_loader = loader;
		_thread_handler = new Thread(&createNewProcess).start();
		buf = new OutBuffer();
	}

    // TODO: Pass arguments throw threads (runCmd function should have a cmd string argument)
    void runCmdThread(string runcmd){
        _cmd = runcmd;
		_thread_handler = new Thread(&runCmd).start();
	}

	string getBufferString(){
		import std.string : cmp;
		
		string s = buf.toString();
		buf.clear();
		return s;
	}

	void runCmd(string cmd){
		pipeproc_handler.stdin.writeln(cmd);
	}

}