module dedicatedslave.data.models;

import std.conv;

class GameInstance {

private:

    string _name;
	string _description;
	int _type;
	string _binFile;
	int _port;
	int _maxPlayers;
	string _rconPassword;
	string _hostname;

public:

	this(string name){
		_name = name;
		_hostname = "\"alex1a\'s Rust Server\"";
		_description = "\"This is my dev server.\"";
		_rconPassword = "letmein123";
	}

	string getName(){
		return _name;
	}

	string getDescription(){
		return _description;
	}

	string getHostname(){
		return _hostname;
	}
	
	string getBinFile(){
		return _binFile;
	}

	int getType(){
		return _type;
	}

	string getRunCmd(){
		return "";
	}

	void setDescription(string description){
		_description = description;
	}

}

class RustGameInstance : GameInstance {

private:

	int _worldSize;
	int _seed;
	string _url;
	string _headerImage;
	string _identify;
	string _level;

public:

	this(string name) {
		super(name);
		// Common
		_binFile = "RustDedicated.exe";
		_type = 1;
		_port = 28015;
		_maxPlayers = 3;
		// Specific
		_worldSize = 4000;
		_seed = 1234;
		_url = "\"http://alexjorge.me\"";
		_headerImage = "\"http://yourwebsite.com/serverimage.jpg\"";
		_identify = "server1";
		_level = "\"Procedural Map\"";
	}

	override{
		string getRunCmd(){
			string cmd = "";
			cmd ~= _binFile;
			cmd ~= " -batchmode";
			cmd ~= " +server.port " ~ to!string(_port);
			cmd ~= " +server.level " ~ _level;
			cmd ~= " +server.seed " ~ to!string(_seed);
			cmd ~= " +server.worldsize " ~ to!string(_worldSize);
			cmd ~= " +server.maxplayers " ~ to!string(_maxPlayers);
			cmd ~= " +server.hostname " ~ _hostname;
			cmd ~= " +server.description " ~ _description;
			cmd ~= " +server.url " ~ _url;
			cmd ~= " +server.headerimage " ~ _headerImage;
			cmd ~= " +server.identity " ~ _identify;
			cmd ~= " +rcon.port 28016";
			cmd ~= " +rcon.password letmein";
			cmd ~= " +rcon.web 1";
			return cmd;
		}
	}
}

class CsgoGameInstance : GameInstance {

private:

	int _gameType;
	int _gameMode;
	string _mapGroup;
	string _map;
	int _tickRate;
	string _serverPassword;
	int _clientPort;

public:

	this(string name) {
		super(name);
		// Common
		_binFile = "srcds.exe";
		_type = 0;
		_port = 27016;
		_maxPlayers = 10;
		// Specific
		_gameType = 0;
		_gameMode = 0;
		_mapGroup = "mg_active";
		_map = "de_dust2";
		_tickRate = 64;
		_serverPassword = "123";
		_clientPort = 27005;
	
	}

	override{
		string getRunCmd(){
			string cmd = "";
			cmd ~= _binFile;
			cmd ~= " -game csgo";
			cmd ~= " -autoupdate";
			cmd ~= " -console";
			cmd ~= " -usercon";
			cmd ~= " -hostport " ~ to!string(_port);
			//cmd ~= " -clientport " ~ to!string(_clientPort);
			cmd ~= " -tickrate " ~ to!string(_tickRate);
			cmd ~= " -maxplayers_override " ~ to!string(_maxPlayers);
			cmd ~= " +sv_lan 0";
			cmd ~= " +hostname " ~ _hostname;
			//cmd ~= " +sv_password " ~ _serverPassword;
			cmd ~= " +rcon_password " ~ _rconPassword;
			cmd ~= " +game_type " ~ to!string(_gameType);
			cmd ~= " +game_mode " ~ to!string(_gameMode);
			cmd ~= " +mapgroup " ~ _mapGroup;
			cmd ~= " +map " ~ _map;
			return cmd;
		}
	}
}