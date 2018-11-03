module dedicatedslave.data.database;

import d2sqlite3; // http://biozic.github.io/d2sqlite3/d2sqlite3.html

import dedicatedslave.loader;

class DatabaseSystem {
	this()
	{
		//db = Database(":memory:");
		db = Database("database.db");
	}

public:
	void addInstance(string name, int gameId){
		Statement statement = db.prepare(
			"INSERT INTO `instances` (name, gameId)
			VALUES (:name, :gameId)"
		);
		statement.bind(":name", name); // Bind values one by one (by parameter name or index)
		statement.bind(2, gameId); // Bind values one by one (by parameter name or index)
		statement.execute();
		statement.reset(); // Need to reset the statement after execution.
		//statement.inject(name, gameId); // Bind, execute and reset in one call
	}

	void init(){
		db.run("CREATE TABLE `instances` ( `id` INTEGER, `name` TEXT NOT NULL, `gameId` INTEGER NOT NULL, PRIMARY KEY(`id`) )");
	}

	string dumpData(){
		return "WIP";
	}

private:
	Database db;
}