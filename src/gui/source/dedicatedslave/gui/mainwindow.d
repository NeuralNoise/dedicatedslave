module dedicatedslave.gui.mainwindow;


private import std.container;
private import gtk.ApplicationWindow;
private import gtk.Application;
private import gtk.Label;
private import gtk.Box;
import gtk.Window;
private import gtk.Main;
private import gtk.Entry;
private import gtk.Image;
private import gtk.HandleBox;
private import gtk.MessageDialog;
private import gtk.AboutDialog;
private import gtk.Widget;
private import gtk.MenuItem;
import gtk.ComboBoxText;
private import gtk.MenuBar;
private import gtk.Menu;
private import gtk.HBox;
private import gtk.Button;
import stdlib = core.stdc.stdlib : exit;
private import gobject.Signals;
private import gtk.AccelGroup;
private import gtk.TextView;
import gtk.VBox;
import gtk.SeparatorToolItem;
import gtk.Toolbar;
private import gtk.Dialog;
private import gtk.ToolButton;
private import gtk.Statusbar;
private import gtk.Notebook;
private import gtk.ScrolledWindow;
private import gdk.Event;
private import dedicatedslave.gui.loader;
private import dedicatedslave.gui.containers.list;
private import dedicatedslave.gui.containers.notebook;
private import dedicatedslave.gui.containers.console;
import dedicatedslave.data.models;
import dedicatedslave.api;

class MainWindow : ApplicationWindow
{

	private GameListStore gameListStore;
	private SteamAPI steamapi_instance;
	private GUILoader* _loader; // NOT

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
		setup(loader);
		showAll();
	}

	public void addInstance(string name, string type){
		_loader.addInstance(name, 0);
		gameListStore.addInstance(name, type);
	}

	void setup(ref GUILoader loader)
	{
		Box box = new Box(Orientation.VERTICAL, 10);

		AccelGroup accelGroup = new AccelGroup();
        addAccelGroup(accelGroup);

		Box hbox = new Box(Orientation.HORIZONTAL, 10);
		hbox.setBorderWidth(8);

		MainConsole console = new MainConsole(loader);
		gameListStore = new GameListStore();
		gameListStore.addInstance("inst1 (HARDCODED)", "CSGO");
		Box left_vbox = new Box(Orientation.VERTICAL, 10);
		left_vbox.packStart(new ScrolledWindow(console), true, true, 0);
		left_vbox.packStart(new GameTreeView(gameListStore), true, true, 0);
		hbox.packStart(left_vbox, true, true, 0);

		Box right_vbox = new Box(Orientation.VERTICAL, 10);
		right_vbox.packStart(new MainNotebook(), true, true, 0);
		hbox.packStart(right_vbox, true, true, 0);

		box.packStart(new MainMenu(accelGroup), false, false, 0);
		box.packStart(new MainToolbar(this, loader), false, false, 0);
		
		box.packStart(hbox, true, true, 0);
		box.packStart(new MainStatusbar(), false, false, 0);

		add(box);
		loader.changeLogState("GUI Initialization Completed!");
	}

	class MainMenu : MenuBar
	{
		this(AccelGroup accelGroup)
		{
			super();
			
			this.append(new FileMenuItem());
			this.append(new EditMenuItem());
			this.append(new ViewMenuItem());
			this.append(new ToolsMenuItem());
			this.append(new HelpMenuItem(accelGroup));
		}

		class FileMenuItem : MenuItem
		{
			this()
			{
				super("File");
				_menu = new Menu();

				_menuItem = new MenuItem("Exit");
				_menuItem.addOnButtonRelease(&exit);
				_menu.append(_menuItem);

				setSubmenu(_menu);
			}
			bool exit(Event event, Widget widget)
			{
				Main.quit();
				return true;
			}
		private:
			Menu _menu;
			MenuItem _menuItem;
		}

		class EditMenuItem : MenuItem
		{
			this()
			{
				super("Edit");
				_menu = new Menu();
				setSubmenu(_menu);
			}
		private:
			Menu _menu;
			MenuItem _menuItem;
		}

		class ViewMenuItem : MenuItem
		{
			this()
			{
				super("View");
				_menu = new Menu();
				setSubmenu(_menu);
			}
		private:
			Menu _menu;
			MenuItem _menuItem;
		}

		class ToolsMenuItem : MenuItem
		{
			this()
			{
				super("Tools");
				_menu = new Menu();
				setSubmenu(_menu);
			}
		private:
			Menu _menu;
			MenuItem _menuItem;
		}

		class HelpMenuItem : MenuItem
		{
			this(AccelGroup accelGroup)
			{
				super("Help");
				_menu = new Menu();
				_menuItem = new MenuItem(&MainWindow.onMenuActivate,"_About","help.about", true, accelGroup, 'a',GdkModifierType.CONTROL_MASK|GdkModifierType.SHIFT_MASK);
				_menu.append(_menuItem);
				setSubmenu(_menu);
			}
		private:
			Menu _menu;
			MenuItem _menuItem;
		}

	}

	void onMenuActivate(MenuItem menuItem)
	{
		string action = menuItem.getActionName();
		switch( action )
		{
			case "help.about":
				GtkDAbout dlg = new GtkDAbout();
				dlg.addOnResponse(&onDialogResponse);
				dlg.showAll();
				break;
			case "toolbar.add":
				GtkDAbout dlg = new GtkDAbout();
				dlg.addOnResponse(&onDialogResponse);
				dlg.showAll();
				break;
			default:
				MessageDialog d = new MessageDialog(
					this,
					GtkDialogFlags.MODAL,
					MessageType.INFO,
					ButtonsType.OK,
					"You pressed menu item "~action);
				d.run();
				d.destroy();
			break;
		}
	}

	void onDialogResponse(int response, Dialog dlg)
	{
		if(response == GtkResponseType.CANCEL)
			dlg.destroy();
	}

	class GtkDAbout : AboutDialog
	{
		this()
		{
			string[] names;
			names ~= "Alexandre Ferreira (github.com/alex1a)";
			names ~= "Luís Ferreira (github.com/ljmf00)";
			names ~= "EnthDev (enthdev.github.io)";

			setAuthors( names );
			setDocumenters( names );
			setArtists( names );
			setLicense("License is MIT");
			setWebsite("https://dedicatedslave.readthedocs.io");
		}
	}

	class MainStatusbar : Statusbar
	{
		this()
		{
			super();
		}

	}
	
	class MainToolbar : Toolbar
	{
		import std.container;
		import std.algorithm.comparison : equal;
		import std.stdio : writefln;

		this(MainWindow parent, ref GUILoader loader)
		{
			super();
			_parent = parent;
			// Initializing the array
			_toolbuttons = [];

			auto arr = make!(Array!int)([4, 2, 3, 1]);
			assert(equal(arr[], [4, 2, 3, 1]));
			
			ToolButton toolbtn_add = new ToolButton(new Image("list-add", IconSize.BUTTON), "toolbar.add");
			toolbtn_add.addOnClicked(&add);
			_toolbuttons ~= toolbtn_add;
			this.insert(toolbtn_add);
			this.insert(new ToolButton(new Image("list-remove", IconSize.BUTTON), "toolbar.remove"));
			this.insert(new SeparatorToolItem());
			this.insert(new ToolButton(new Image("system-software-update", IconSize.BUTTON), "toolbar.update"));
			ToolButton toolbtn_start = new ToolButton(new Image("media-playback-start", IconSize.BUTTON), "toolbar.start");
			toolbtn_start.addOnClicked(&start);
			this.insert(toolbtn_start);
			this.insert(new ToolButton(new Image("media-playback-stop", IconSize.BUTTON), "toolbar.stop"));
		}

	private:;

		MainWindow _parent;
		ToolButton[] _toolbuttons;
		string _instancename;
		string _type;
		Entry e;
		ComboBoxText c;
		Window w;

		void add(ToolButton a)
		{
			w = new Window("Add");

			VBox box = new VBox(false, 5);
			
			Box hbox1 = new Box(Orientation.HORIZONTAL, 10);
			hbox1.setBorderWidth(8);
			hbox1.packStart(new Label("Instance Name:"), false, false, 0);
			e = new Entry("", 15);
			hbox1.packStart(e, false, false, 0);

			Box hbox2 = new Box(Orientation.HORIZONTAL, 10);
			hbox2.setBorderWidth(8);
			hbox2.packStart(new Label("Instance Type:"), false, false, 0);
			c = new ComboBoxText();
			c.appendText("CSGO");
			c.appendText("Rust");
			c.setActive(-1);
			c.addOnChanged(&onGameChanged);
			hbox2.packStart(c, false, false, 0);

			Box hbox3 = new Box(Orientation.HORIZONTAL, 10);
			hbox3.setBorderWidth(8);
			hbox3.packStart(new Button("OK", &showSimpleCombo), false, false, 0);

			box.packStart(hbox1, false, false, 0);
			box.packStart(hbox2, false, false, 0);
			box.packStart(hbox3, false, false, 0);

			w.add(box);
			w.showAll();
		}

		void start(ToolButton a)
		{
			// TODO
			//steamapi_instance.runInst();
			//_loader.startInstance("RustServer");
		}

		void showSimpleCombo(Button button)
		{
			_parent.addInstance(e.getText(), _type);
			w.destroy();
		}

		void onGameChanged(ComboBoxText comboBoxText)
		{
			debug(trace) writefln("Combo _type = %s", comboBoxText.getActiveText());
			switch ( comboBoxText.getActiveText() )
			{
				case "CSGO":           _type = GameType.CSGO;           break;
				case "Rust":           _type = GameType.Rust;           break;
				default:               _type = GameType.Invalid;        break;
			}
		}

		enum GameType : string
		{
			CSGO = "CSGO",
			Rust = "Rust",
			Invalid = "Invalid"
		}

		enum GameType2
		{
			CSGO,
			Rust,
			Invalid
		}

		void confirm(ToolButton a)
		{
			MessageDialog d = new MessageDialog(
											_parent,
											GtkDialogFlags.MODAL,
											MessageType.INFO,
											ButtonsType.OK,
											"You pressed menu item ");
			int responce = d.run();
			if ( responce == ResponseType.YES)
			{
				stdlib.exit(0);
			}
			d.destroy();
		}
	}
}