// Written in the D programming language.

/**
Config manager.

Copyright: Copyright EnthDev 2017.
License:   $(HTTP dedicatedslave.readthedocs.io/en/latest/about/license, MIT License).
Authors:   $(HTTP alexjorge.me, Alexandre Ferreira),
           $(HTTP lsferreira.net, Luis Ferreira)
 */

module dedicatedslave.config;
import std.algorithm;
import std.json;
import std.stdio;
import std.file;
import std.utf : byChar;
//import asdf; // https://github.com/libmir/asdf
import dedicatedslave.loader;

// Serialization
class ConfigManager {

    /++
        Config manager constructor.

        Params:
            loader = Main class loader.
     +/
	this(Loader loader)
	{
        _loader = loader;
        _initConfig = `{ "instancesDir": "D:\\ProgramFiles\\ProgramFiles\\DSInstances" }`;
	}

public:

    void serialize(){
        string configfile = std.file.readText("config.json");
        JSONValue j = parseJSON(configfile);
        writeln(j["instancesDir"].str);
    }

    string getInitConfig(){
        return _initConfig;
    }


private:
    Loader _loader;
    string _initConfig;

}