module dedicatedslave.gui.instance.instwindow;

import gtk.Window;
import gtk.VBox;
import gtk.AccelGroup;
import gtk.Label;
import gtk.Box;
import gtk.ComboBoxText;
import gtk.ScrolledWindow;
import gtk.Entry;
import gtk.TextView;
import gtk.Button;

import std.algorithm;
import std.json;
import std.stdio;
import std.file;
import std.file;
import std.utf : byChar;

import dedicatedslave.gui.instance.instnotebook;
import dedicatedslave.gui.instance.insttoolbar;
import dedicatedslave.gui.instance.instmenubar;
import dedicatedslave.gui.instance.inststatusbar;
import dedicatedslave.gui.apptoolbar;
import dedicatedslave.gui.loader;
import dedicatedslave.data.models;

class InstanceWindow : Window {
    
private:

    MainToolbar _parent;
    GUILoader* _loader;
    GameInstance _gi;
    Entry _entryCmd;

    void setupWindow(GUILoader* loader){

        Box box = new Box(Orientation.VERTICAL, 10);

		AccelGroup accelGroup = new AccelGroup();
        addAccelGroup(accelGroup);

		Box hbox = new Box(Orientation.HORIZONTAL, 10);
		hbox.setBorderWidth(8);

        TextView t = new TextView();
        t.setEditable(false);
        t.setMonospace(true);
        t.setWrapMode(GtkWrapMode.WORD_CHAR);

        // _loader.changeLogCallback(delegate(immutable string msg) {
        //     import glib.Idle;
        //         new Idle({
        //             t.appendText(msg~"\n");
        //             return false;
        //         }, GPriority.DEFAULT_IDLE, true);
        //     }
        // , 1);

        // Left Box
		Box left_vbox = new Box(Orientation.VERTICAL, 10);
		left_vbox.packStart(new ScrolledWindow(t), true, true, 0);
		Box cmd = new Box(Orientation.HORIZONTAL, 10);
        _entryCmd = new Entry("version", 15);
        cmd.packStart(_entryCmd, true, true, 0);
        cmd.packStart(new Button("GO", &onClickedOk), false, true, 0);
        left_vbox.packStart(cmd, false, true, 0);
		hbox.packStart(left_vbox, true, true, 0);

        // Right Box
		Box right_vbox = new Box(Orientation.VERTICAL, 10);
		right_vbox.packStart(new InstanceNotebook(this, loader), true, true, 0);
		hbox.packStart(right_vbox, true, true, 0);

        // Box
		box.packStart(new InstanceMenuBar(this, accelGroup, loader), false, false, 0);
		box.packStart(new InstanceToolbar(this, loader), false, false, 0);
		box.packStart(hbox, true, true, 0);
		box.packStart(new InstanceStatusbar(), false, false, 0);

        // Add Box
		add(box);
        this.showAll();

    }

    void loadConfig(GUILoader* loader){
        string instanceName = _parent.getSelectedInstanceName();
        _gi = loader.getInstance(instanceName);
        string fileName = loader.instances_path ~ instanceName ~ "\\instance.json";

        string instDescription = "";
        if(exists(fileName)){
            loader.changeLogState("Reading config for instance "~instanceName~" ("~fileName~")", 0);
            string configFile = std.file.readText(fileName);
            JSONValue j = parseJSON(configFile);
            instDescription = j["description"].str;
            loader.changeLogState("Sucessfull read config for instance "~instanceName, 0);
		}

        _gi.setDescription(instDescription);
    }

	// onClickedOk Event
	void onClickedOk(Button button){
		_loader.runCmd(_entryCmd.getText());
	}

public:

    this(MainToolbar parent, GUILoader* loader, GameInstance gameInstance){
        super(parent.getSelectedInstanceName());
        
        _parent = parent;
        _loader = loader;

        loadConfig(loader);
        setupWindow(loader);
        
        maximize();

    }

    GameInstance getInstance(){
        return _gi;
    }

    // startInstance
    void startInstance(){
        _parent.startInstance();
    }

    // updateInstance
    void updateInstance(){
        _parent.updateInstance();
    }
}