module dedicatedslave.gui.apptoolbar;

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
import gtk.TextView;
import gtk.ComboBoxText;
import gtk.VBox;
import gtk.Box;
import gtk.HBox;
import gtk.SeparatorMenuItem;

import dedicatedslave.gui.settingswindow;
import dedicatedslave.gui.appwindow;
import dedicatedslave.gui.instance.instwindow;
import dedicatedslave.gui.loader;

class MainToolbar : Toolbar
	{
		import std.container;
		import std.algorithm.comparison : equal;
		import std.stdio : writefln;

		private GUILoader* _loader;
		private MainAppWindow _parent;
		private ToolButton[] _toolbuttons;
		private string _instancename;
		private int _type;
		private Entry e;
		private TextView t;
		private Window w;
		private ComboBoxText c;

		// MainToolbar Constructor
		this(MainAppWindow parent, ref GUILoader loader)
		{
			super();
			_parent = parent;
			_loader = &loader;
			// Initializing the array
			_toolbuttons = [];

			auto arr = make!(Array!int)([4, 2, 3, 1]);
			assert(equal(arr[], [4, 2, 3, 1]));
			
			ToolButton toolbtn_add = new ToolButton(new Image("list-add", IconSize.BUTTON), "toolbar.add");
			toolbtn_add.addOnClicked(&onClickedAdd);
			_toolbuttons ~= toolbtn_add;
			this.insert(toolbtn_add);
			ToolButton toolbtn_remove = new ToolButton(new Image("list-remove", IconSize.BUTTON), "toolbar.remove");
			toolbtn_remove.addOnClicked(&onClickedRemove);
			_toolbuttons ~= toolbtn_remove;
			this.insert(toolbtn_remove);
			ToolButton toolbtn_info = new ToolButton(new Image("dialog-warning", IconSize.BUTTON), "toolbar.info");
			toolbtn_info.addOnClicked(&onClickedInfo);
			this.insert(toolbtn_info);

		}

		// startInstance
		void startInstance()
		{
			_parent.startInstance();
		}

		// updateInstance
		void updateInstance()
		{
			_parent.updateInstance();
		}

	private:

		// onClickedAdd Event
		void onClickedAdd(ToolButton a)
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
			c.addOnChanged(&onComboChangedGame);
			hbox2.packStart(c, false, false, 0);

			Box hbox3 = new Box(Orientation.HORIZONTAL, 10);
			hbox3.setBorderWidth(8);
			hbox3.packStart(new Button("OK", &onClickedOk), false, false, 0);

			box.packStart(hbox1, false, false, 0);
			box.packStart(hbox2, false, false, 0);
			box.packStart(hbox3, false, false, 0);

			w.add(box);
			w.showAll();
		}

		// onClickedRemove Event
		void onClickedRemove(ToolButton a)
		{
			MessageDialog dlg = new MessageDialog(
				_parent,
				GtkDialogFlags.MODAL,
				MessageType.QUESTION,
				ButtonsType.YES_NO,
				"Are you sure you to remove selected game instance?");
			dlg.addOnResponse(&onRemoveDialogResponse);
			dlg.showAll();
			dlg.run();
		}

		// onRemoveDialogResponse Event
		void onRemoveDialogResponse(int response, Dialog dlg)
		{
			import std.stdio;
			writeln(response);
			if(response == GtkResponseType.CANCEL){
				dlg.destroy();
			}else if(response == GtkResponseType.YES){
				dlg.destroy();
				_parent.removeInstance(_parent.getSelectedInstance());
			}else if(response == GtkResponseType.NO){
				dlg.destroy();
			}
		}

		// onClickedAdd Event
		void onClickedInfo(ToolButton a)
		{
			InstanceWindow w = new InstanceWindow(this, _loader, "Info");
		}

		// onClickedOk Event
		void onClickedOk(Button button)
		{
			_parent.addInstance(e.getText(), _type);
			w.destroy();
		}

		// onComboChangedGame Event
		void onComboChangedGame(ComboBoxText comboBoxText)
		{
			debug(trace) writefln("Combo _type = %s", comboBoxText.getActiveText());
			switch ( comboBoxText.getActiveText() )
			{
				case "CSGO":           _type = GameType.CSGO;           break;
				case "Rust":           _type = GameType.Rust;           break;
				default:               _type = GameType.Invalid;        break;
			}
		}

		enum GameType : int
		{
			CSGO = 0,
			Rust = 1,
			Invalid = -1
		}

	}