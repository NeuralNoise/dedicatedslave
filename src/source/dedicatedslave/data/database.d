module dedicatedslave.data.database;

import d2sqlite3; // http://biozic.github.io/d2sqlite3/d2sqlite3.html
import std.typecons : Nullable;

import dedicatedslave.loader;

class DatabaseSystem {
	this(Loader loader)
	{
		//db = Database(":memory:");
		_loader = loader;
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
		db.run("CREATE TABLE `instances` ( `id` INTEGER PRIMARY KEY AUTOINCREMENT, `name` TEXT NOT NULL, `gameId` INTEGER NOT NULL, `description` TEXT )");
	}

	string dumpData(){
		_loader.changeLogState("Dumping data from database...");
		// Read the data from the table lazily
		ResultRange results = db.execute("SELECT * FROM `instances`");
		foreach (Row row; results)
		{
			// Retrieve "id", which is the column at index 0, and contains an int,
			// e.g. using the peek function (best performance).
			auto id = row.peek!long(0);

			// Retrieve "name", e.g. using opIndex(string), which returns a ColumnData.
			auto name = row["name"].as!string;
			
			auto gameId = row["gameId"].as!int;

			// Retrieve "score", which is at index 2, e.g. using the peek function,
			// using a Nullable type
			auto description = row.peek!(Nullable!string)(3);
			if (!description.isNull)
			{
				// ...
			}
			_loader.addInstance2(name, gameId);
		}
		return "WIP";
	}

private:
	Database db;
	Loader _loader;
}