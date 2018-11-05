module dedicatedslave.data.data;

import DedicatedSlave = dedicatedslave;
import dedicatedslave.loader;

import core.thread;
import std.process;

import dedicatedslave.data.models;


class DataSystem {
	this(Loader loader)
	{
		_loader = loader;
	}

public:

	void init(string data){

	}

	bool addInstance(string name, int game)
	{
		_loader.changeLogState("Adding a new instance: "~name~" ("~"game"~")");
		GameInstance g;
		switch( game )
		{
			case 0:
				g = new RustGameInstance(name);
				break;
			case 1:
				g = new CsgoGameInstance(name);
				break;
			default:
				g = new RustGameInstance(name);
			break;
		}
		_gameInstances ~=g;
		return false;
	}

	bool removeInstance(string name)
	{
		import std.algorithm : remove;
		foreach(i, GameInstance g; _gameInstances)
		{
			if(g.getName() == name)
			{
				remove(_gameInstances, i);
			}
		}
		return false;
	}

	string getBinFile(string name)
	{
		foreach(i, GameInstance g; _gameInstances)
		{
			if(g.getName() == name)
			{
				return _gameInstances[i].getBinFile();
			}
		}
		return "";
	}

	GameInstance[] getInstances(){
		return _gameInstances;
	}

private:
	GameInstance[] _gameInstances;
	Loader _loader;

}