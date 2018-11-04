module dedicatedslave.loader;
import std.path;
import std.file;
import DedicatedSlave = dedicatedslave;
import dedicatedslave.data.data;
import dedicatedslave.data.models;
import dedicatedslave.config;
import dedicatedslave.processmngr;
import dedicatedslave.data.database;
import dedicatedslave.logger;

class Loader {
	this()
	{
		instances_path = "D:\\ProgramFiles\\ProgramFiles\\DSInstances\\";
		exe_path = thisExePath.dirName ~ "\\";
		
		// First Run
		if(!exists(exe_path~DedicatedSlave.realPath))
		{
			installEnvironment();
		}

		_processMngr = new ProcessManager(this);
		_dataSystem = new DataSystem(this);
		if(!exists("config.json")){
			changeLogState("Trying to create a config.json file");
			std.file.write("config.json", _configMngr.getInitConfig());
		}
		_configMngr = new ConfigManager(this);

		// Serialize Data
		_configMngr.serialize();

		// Init SQLite Database
		if(!exists("database.db")){
			_database = new DatabaseSystem(this);
			_database.init();
		}else{
			_database = new DatabaseSystem(this);
		}
		_dataSystem.init(_database.dumpData());
	}

private:

	DataSystem _dataSystem;
	DatabaseSystem _database;
	ProcessManager _processMngr;
	ConfigManager _configMngr;

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

public:

	string exe_path;
	string instances_path;

	public string getInstanceName(){
		return instances_path;
	}

	public void changeLogState(immutable string msg)
	{
		import std.experimental.logger : info;
		info(msg);
	}

	bool addInstance(string name, int game)
	{
		_database.addInstance(name, game);
		return _dataSystem.addInstance(name, game);
	}

	bool addInstance2(string name, int game)
	{
		return _dataSystem.addInstance(name, game);
	}

	GameInstance[] fetchInstances(){
		return _dataSystem.getInstances();
	};

	bool removeInstance(string name)
	{
		return _dataSystem.removeInstance(name);
	}

	bool startInstance(string name)
	{
		string runcmd = instances_path~name~"\\"~_dataSystem.getBinFile(name)~" -batchmode +server.port 28015 +server.level \"Procedural Map\" +server.seed 1234 +server.worldsize 4000 +server.maxplayers 10  +server.hostname \"alex1a's Rust Server\" +server.description \"This is my dev server.\" +server.url \"http://alexjorge.me\" +server.headerimage \"http://yourwebsite.com/serverimage.jpg\" +server.identity \"server1\" +rcon.port 28016 +rcon.password letmein +rcon.web 1";

		changeLogState("CMD: "~runcmd);
		_processMngr.runCmdThread(runcmd);
		return false;
	}

}
