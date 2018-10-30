module dedicatedslave.data.models;

class GameInstance {
	this(string name)
	{
		_name = name;
	}
public:
	string getName()
	{
		return _name;
	}
	
	string getBinFile()
	{
		return _binFile;
	}
private:
    string _name;
	string _binFile;
}

class RustGameInstance : GameInstance {
	this(string name)
	{
		_binFile = "RustDedicated.exe";
		super(name);
	}
}

class CsgoGameInstance : GameInstance {
	this(string name)
	{
		_binFile = "cs.exe";
		super(name);
	}
}