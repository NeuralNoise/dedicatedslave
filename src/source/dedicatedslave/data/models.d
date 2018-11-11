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

	int getType()
	{
		return _type;
	}
private:
    string _name;
	int _type;
	string _binFile;
}

class RustGameInstance : GameInstance {
	this(string name)
	{
		_binFile = "RustDedicated.exe";
		_type = 1;
		super(name);
	}
}

class CsgoGameInstance : GameInstance {
	this(string name)
	{
		_binFile = "cs.exe";
		_type = 0;
		super(name);
	}
}