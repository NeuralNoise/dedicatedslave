module dedicatedslave.gui.instance.insttoolbar;

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

import dedicatedslave.gui.prefs.settingswindow;
import dedicatedslave.gui.appwindow;
import dedicatedslave.gui.instance.instwindow;
import dedicatedslave.gui.loader;

class InstanceToolbar : Toolbar
	{
		import std.container;
		import std.algorithm.comparison : equal;
		import std.stdio : writefln;

		private GUILoader* _loader;
		private InstanceWindow _parent;
		private ToolButton[] _toolbuttons;
		private string _instancename;
		private int _type;
		private Entry e;
		private TextView t;
		private Window w;
		private ComboBoxText c;

		// MainToolbar Constructor
		this(InstanceWindow parent, GUILoader* loader)
		{
			super();
			_parent = parent;
			_loader = loader;
			// Initializing the array
			_toolbuttons = [];

			auto arr = make!(Array!int)([4, 2, 3, 1]);
			assert(equal(arr[], [4, 2, 3, 1]));
			
			this.insert(new SeparatorToolItem());

			ToolButton toolbtn_update = new ToolButton(new Image("system-software-update", IconSize.BUTTON), "toolbar.update");
			toolbtn_update.addOnClicked(&onClickedUpdate);
			this.insert(toolbtn_update);

			ToolButton toolbtn_start = new ToolButton(new Image("media-playback-start", IconSize.BUTTON), "toolbar.start");
			toolbtn_start.addOnClicked(&onClickedStart);
			this.insert(toolbtn_start);

			this.insert(new ToolButton(new Image("media-playback-stop", IconSize.BUTTON), "toolbar.stop"));

			this.insert(new SeparatorToolItem());

		}

	private:

		// onClickedStart Event
		void onClickedStart(ToolButton a)
		{
			_parent.startInstance();
		}

		// onClickedUpdate Event
		void onClickedUpdate(ToolButton a)
		{
			_parent.updateInstance();
		}

	}