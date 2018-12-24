// Written in the D programming language.

/**
Loader.

Copyright: Copyright EnthDev 2017.
License:   $(HTTP dedicatedslave.readthedocs.io/en/latest/about/license, MIT License).
Authors:   $(HTTP alexjorge.me, Alexandre Ferreira),
           $(HTTP lsferreira.net, Luis Ferreira)
 */

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

	public string exe_path;
	public string instances_path;
	public string instances_path2;

	private DataSystem _dataSystem;
	private DatabaseSystem _database;
	private ProcessManager _processMngr;
	private ConfigManager _configMngr;
	private string _selectedInstance;

	this()
	{
		// TODO: Read this from config.json, not hardcoded
		instances_path = "D:\\ProgramFiles\\ProgramFiles\\DSInstances\\";
		exe_path = thisExePath.dirName ~ "\\";
		
		// First Run
		if(!exists(exe_path~DedicatedSlave.realPath)){
			installEnvironment();
		}

		_processMngr = new ProcessManager(this);
		_dataSystem = new DataSystem(this);
		if(!exists("config.json")){
			changeLogState("Trying to create a config.json file", 0);
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

	void installEnvironment()
	{
		changeLogState("Installing the environment...", 0);
		
		if(exists(exe_path~DedicatedSlave.tmpPath))
			rmdirRecurse(exe_path~DedicatedSlave.tmpPath);
		mkdir(exe_path~DedicatedSlave.tmpPath);

		changeLogState("Downloading " ~ DedicatedSlave.urlPlatform ~ "...", 0);
		import std.net.curl : download;
		import std.path : extension;
		immutable string steamcmd_extension = extension(DedicatedSlave.urlPlatform);
		immutable string steamcmd_filename = exe_path~DedicatedSlave.tmpPath~"steamcmd"~extension(DedicatedSlave.urlPlatform);
		download(DedicatedSlave.urlPlatform, steamcmd_filename);
		
		changeLogState("Extracting " ~ steamcmd_filename ~ "...", 0);

		string folder = "steamcmd/";
		if(steamcmd_extension == ".gz"){
			import archive.targz;
			import std.stdio: writeln;

			auto archive_file = new TarGzArchive(read(steamcmd_filename));

			version(windows){
				folder = "steamcmd\\";
			}
			changeLogState("Create directory "~exe_path~DedicatedSlave.tmpPath~folder, 0);
			mkdir(exe_path~DedicatedSlave.tmpPath~folder);

			foreach (memberFile; archive_file.directories){
				changeLogState("Create directory "~memberFile.path~"...",0);
				mkdir(exe_path~DedicatedSlave.tmpPath~folder~memberFile.path);
				changeLogState("Set attributes for "~memberFile.path~"...", 0);
				setAttributes(exe_path~DedicatedSlave.tmpPath~folder~memberFile.path, memberFile.permissions);
			}

			foreach (memberFile; archive_file.files){
				changeLogState("Extracting "~memberFile.path~"...", 0);
				write(exe_path~DedicatedSlave.tmpPath~folder~memberFile.path, memberFile.data);
				changeLogState("Set attributes for "~memberFile.path~"...", 0);
				setAttributes(exe_path~DedicatedSlave.tmpPath~folder~memberFile.path, memberFile.permissions);
			}
		}
		if(steamcmd_extension == ".zip"){
			import archive.zip;
			import std.stdio: writeln;

			auto archive_file = new ZipArchive(read(steamcmd_filename));
			changeLogState("Create directory "~exe_path~DedicatedSlave.tmpPath~folder, 0);
			mkdir(exe_path~DedicatedSlave.tmpPath~folder);

			foreach (memberFile; archive_file.directories){
				changeLogState("Create directory "~memberFile.path~"...", 0);
				mkdir(exe_path~DedicatedSlave.tmpPath~folder~memberFile.path);
				changeLogState("Set attributes for "~memberFile.path~"...", 0);
			}

			foreach (memberFile; archive_file.files){
				changeLogState("Extracting "~memberFile.path~"...", 0);
				write(exe_path~DedicatedSlave.tmpPath~folder~memberFile.path, memberFile.data);
				changeLogState("Set attributes for "~memberFile.path~"...", 0);
			}
		}
		changeLogState("Delete "~steamcmd_filename~"...", 0);
		remove(steamcmd_filename);

		changeLogState("Finishing setup...", 0);
		changeLogState("Renaming "~exe_path~DedicatedSlave.tmpPath~" TO "~exe_path~DedicatedSlave.realPath, 0);
		rename(exe_path~DedicatedSlave.tmpPath, exe_path~DedicatedSlave.realPath);
	}

public:

	public void setSelectedInstance(string selectedInstance){
		_selectedInstance = selectedInstance;
		changeLogState("Setting Selected to: " ~ selectedInstance, 0);
	}

	public string getInstanceName(){
		return instances_path;
	}

	public void changeLogState(immutable string msg, int index)
	{
		import std.experimental.logger : info;
		info(msg);
	}

	bool addInstance(string name, int game)
	{
		_database.addInstance(name, game);
		return _dataSystem.addInstance(name, game);
	}

	bool addInstanceData(string name, int game)
	{
		return _dataSystem.addInstance(name, game);
	}

	bool removeInstance(string name)
	{
		changeLogState("Removing instance " ~ name ~ " from database", 0);
		_database.removeInstance(name);
		changeLogState("Removing instance " ~ name ~ " from data", 0);
		return _dataSystem.removeInstance(name);
		//return false;
	}

	GameInstance[] fetchInstances(){
		return _dataSystem.getInstances();
	}

	bool startInstance(string name)
	{
		string runCmd = instances_path~name~"\\"~_dataSystem.getBinFile(name)~" -batchmode +server.port 28015 +server.level \"Procedural Map\" +server.seed 1234 +server.worldsize 4000 +server.maxplayers 10  +server.hostname \"alex1a's Rust Server\" +server.description \"This is my dev server.\" +server.url \"http://alexjorge.me\" +server.headerimage \"http://yourwebsite.com/serverimage.jpg\" +server.identity \"server1\" +rcon.port 28016 +rcon.password letmein +rcon.web 1";
		//changeLogState("CMD: "~runCmd);
		_processMngr.runCmdThread(runCmd);
		return false;
	}

	bool updateInstance(string name)
	{
		string runCmd = exe_path~DedicatedSlave.realPath~"steamcmd\\"~DedicatedSlave.execFilePlatform~" +login anonymous +force_install_dir "~instances_path~name~" +app_update 258550 +quit";
		changeLogState("CMD: "~runCmd, 0);
		_processMngr.runCmdThread(runCmd);
		return false;
	}

}
