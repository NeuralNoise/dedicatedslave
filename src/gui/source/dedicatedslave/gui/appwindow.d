module dedicatedslave.gui.appwindow;

import std.container;

import stdlib = core.stdc.stdlib : exit;

import gobject.Signals;

import gdk.Event;
import gobject.ObjectG;

import gtk.ApplicationWindow;
import gtk.Application;
import gtk.Label;
import gtk.Box;
import gtk.Window;
import gtk.Main;
import gtk.Entry;
import gtk.Image;
import gtk.HandleBox;
import gtk.MessageDialog;
import gtk.AboutDialog;
import gtk.Widget;
import gtk.MenuItem;
import gtk.ComboBoxText;
import gtk.MenuBar;
import gtk.Menu;
import gtk.HBox;
import gtk.Button;
import gtk.Widget;
import gtk.AccelGroup;
import gtk.SeparatorMenuItem;
import gtk.TextView;
import gtk.VBox;
import gtk.SeparatorToolItem;
import gtk.Toolbar;
import gtk.Dialog;
import gtk.ToolButton;
import gtk.Statusbar;
import gtk.Notebook;
import gtk.TreeIter;
import gtk.ScrolledWindow;

import dedicatedslave.gui.loader;
import dedicatedslave.gui.containers.list;
import dedicatedslave.gui.containers.notebook;
import dedicatedslave.gui.containers.console;
import dedicatedslave.gui.settingswindow;
import dedicatedslave.gui.appmenubar;
import dedicatedslave.gui.apptoolbar;
import dedicatedslave.gui.appstatusbar;
import dedicatedslave.data.models;

class MainAppWindow : ApplicationWindow
{

	private GameInstanceListStore gameListStore;
	private GUILoader* _loader; // NOT
	private TreeIter _selectedIter;

	/**
	 * Executed when the user tries to close the window
	 * @return true to refuse to close the window
	 */
	int windowDelete(GdkEvent* event, Widget widget)
	{

		debug(events) writefln("TestWindow.widgetDelete : this and widget to delete %X %X",this,window);
		MessageDialog d = new MessageDialog(
			this,
			GtkDialogFlags.MODAL,
			MessageType.QUESTION,
			ButtonsType.YES_NO,
			"Are you sure you want' to exit these GtkDTests?");
		int responce = d.run();
		if ( responce == ResponseType.YES )
		{
			stdlib.exit(0);
		}
		d.destroy();
		return true;
	}
	
	this(Application application, ref GUILoader loader)
	{
		super(application);
		setTitle("DedicatedSlave");
		setDefaultSize(800, 600);
		_loader = &loader;
		loader.changeLogState("Setting up GUI...");
		setupWindow(loader);
		showAll();
		maximize();
	}

	void setupWindow(ref GUILoader loader)
	{
		Box box = new Box(Orientation.VERTICAL, 10);

		AccelGroup accelGroup = new AccelGroup();
        addAccelGroup(accelGroup);

		ConsoleContainer console = new ConsoleContainer(loader);
		gameListStore = new GameInstanceListStore(loader);
		Box left_vbox = new Box(Orientation.VERTICAL, 10);
		left_vbox.packStart(new ScrolledWindow(console), true, true, 0);
		left_vbox.packStart(new ListContainer(this, gameListStore, loader), true, true, 0);

		box.packStart(new MainMenuBar(this, accelGroup, loader), false, false, 0);
		box.packStart(new MainToolbar(this, loader), false, false, 0);
		
		box.packStart(left_vbox, true, true, 0);
		box.packStart(new MainStatusbar(), false, false, 0);

		add(box);
		loader.changeLogState("GUI Initialization Completed!");
	}

public:

	void setSelectedInstance(TreeIter selectedIter)
	{
		_selectedIter = selectedIter;
	}

	TreeIter getSelectedInstance()
	{
		return _selectedIter;
	}

	void startInstance()
	{
		_loader.startInstance(_selectedIter.getValueString(0));
	}

	void updateInstance()
	{
		_loader.updateInstance(_selectedIter.getValueString(0));
	}

	void addInstance(string name, int type){
		_loader.addInstance(name, type);
		gameListStore.addInstance(name, type);
	}

	void removeInstance(TreeIter selectedIter){
		_loader.removeInstance(selectedIter.getValueString(0));
		gameListStore.removeInstance(selectedIter);
	}

}