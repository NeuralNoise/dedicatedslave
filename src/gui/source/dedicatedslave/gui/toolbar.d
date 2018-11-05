module dedicatedslave.gui.toolbar;

import gtk.Menu;
import gtk.MenuItem;
import gtk.MenuBar;
import gtk.AccelGroup;
import gdk.Event;
import gtk.ToolButton;
import gtk.Widget;
import gtk.Main;
import gtk.Toolbar;
import gtk.Entry;
import gtk.Dialog;
import gtk.Image;
import gtk.Window;
import gtk.Button;
import gtk.SeparatorToolItem;
import gtk.AboutDialog;
import gtk.MessageDialog;
import gtk.Label;
import gtk.ComboBoxText;
import gtk.VBox;
import gtk.Box;
import gtk.HBox;
import gtk.SeparatorMenuItem;

import dedicatedslave.gui.settings;
import dedicatedslave.gui.mainwindow;
import dedicatedslave.gui.loader;

class MainToolbar : Toolbar
	{
		import std.container;
		import std.algorithm.comparison : equal;
		import std.stdio : writefln;

		this(MainAppWindow parent, ref GUILoader loader)
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
			ToolButton toolbtn_remove = new ToolButton(new Image("list-remove", IconSize.BUTTON), "toolbar.remove");
			toolbtn_remove.addOnClicked(&remove);
			_toolbuttons ~= toolbtn_remove;
			this.insert(toolbtn_remove);
			this.insert(new SeparatorToolItem());
			this.insert(new ToolButton(new Image("system-software-update", IconSize.BUTTON), "toolbar.update"));
			ToolButton toolbtn_start = new ToolButton(new Image("media-playback-start", IconSize.BUTTON), "toolbar.start");
			toolbtn_start.addOnClicked(&start);
			this.insert(toolbtn_start);
			this.insert(new ToolButton(new Image("media-playback-stop", IconSize.BUTTON), "toolbar.stop"));
		}

	private:

		MainAppWindow _parent;
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

		void remove(ToolButton a)
		{
			MessageDialog dlg = new MessageDialog(
					_parent,
					GtkDialogFlags.MODAL,
					MessageType.QUESTION,
					ButtonsType.YES_NO,
					"Are you sure you to remove selected game instance?");
			dlg.addOnResponse(&onDialogResponse);
			dlg.showAll();
			dlg.run();
			dlg.destroy();
		}

		void onDialogResponse(int response, Dialog dlg)
		{
			import std.stdio;
			writeln(response);
			if(response == GtkResponseType.CANCEL){
				dlg.destroy();
			}else if(response == GtkResponseType.YES){
				
			}else if(response == GtkResponseType.NO){
				
			}
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