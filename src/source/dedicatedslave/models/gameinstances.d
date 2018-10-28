module dedicatedslave.models.gameinstances;

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
private:
    string _name;
}

class RustGameInstance : GameInstance {
	this(string name)
	{
		super(name);
	}
}