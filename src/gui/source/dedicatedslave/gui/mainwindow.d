module dedicatedslave.gui.mainwindow;

private import gtk.ApplicationWindow;
private import gtk.Application;
private import gtk.Label;
private import gtk.Box;
private import gtk.Main;
private import gtk.Image;
private import gtk.HandleBox;
private import gtk.MessageDialog;
private import gtk.AboutDialog;
private import gtk.Widget;
private import gtk.MenuItem;
private import gtk.MenuBar;
private import gtk.Menu;
private import gtk.Button;
private import gobject.Signals;
private import gtk.AccelGroup;
private import gtk.TextView;
private import gtk.SeparatorToolItem;
private import gtk.Toolbar;
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
private import dedicatedslave.gui.helper;
import dedicatedslave.models.gameinstances;

class MainWindow : ApplicationWindow
{
	
	this(Application application, ref GUILoader loader)
	{
		super(application);

		setTitle("DedicatedSlave");
		setDefaultSize(800, 600);
		setup(loader);

		import dedicatedslave.steamapi;
		SteamAPI steamapi_instance = new SteamAPI(loader);

		//immutable string s = steamapi_instance.ss();
		GameInstance g = steamapi_instance.ss();
		immutable string a = g.getName();
		loader.changeLogState(a);
		
		showAll();
	}

	void setup(ref GUILoader loader)
	{
		Box box = new Box(Orientation.VERTICAL, 10);

		AccelGroup accelGroup = new AccelGroup();
        addAccelGroup(accelGroup);

		Box hbox = new Box(Orientation.HORIZONTAL, 10);
		hbox.setBorderWidth(8);

		MainConsole console = new MainConsole(loader);
		auto countryListStore = new CountryListStore();
		countryListStore.addCountry("Denmark", "Copenhagen");
    	countryListStore.addCountry("Norway", "Olso");
    	countryListStore.addCountry("Sweden", "Stockholm");
		Box left_vbox = new Box(Orientation.VERTICAL, 10);
		left_vbox.packStart(new ScrolledWindow(console), true, true, 0);
		left_vbox.packStart(new CountryTreeView(countryListStore), true, true, 0);
		hbox.packStart(left_vbox, true, true, 0);

		Box right_vbox = new Box(Orientation.VERTICAL, 10);
		right_vbox.packStart(new MainNotebook(), true, true, 0);
		hbox.packStart(right_vbox, true, true, 0);

		box.packStart(new MainMenu(accelGroup), false, false, 0);
		box.packStart(new MainToolbar(), false, false, 0);
		box.packStart(new MainStatusbar(), false, false, 0);
		box.packStart(hbox, true, true, 0);

		add(box);
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
		this()
		{
			super();
			auto csig = new CustomSignals;
			
			ToolButton a = new ToolButton(new Image("list-add", IconSize.BUTTON), "toolbar.add");
			csig.connect(a, "clicked", (Event e, Widget w) { 
				return true;
			 });
			this.insert(a);
			//_toolbuttons[0] = a;
			this.insert(new ToolButton(new Image("list-remove", IconSize.BUTTON), "toolbar.remove"));
			this.insert(new SeparatorToolItem());
			this.insert(new ToolButton(new Image("system-software-update", IconSize.BUTTON), "toolbar.update"));
			this.insert(new ToolButton(new Image("media-playback-start", IconSize.BUTTON), "toolbar.start"));
			this.insert(new ToolButton(new Image("media-playback-stop", IconSize.BUTTON), "toolbar.stop"));
		}
	private:
		ToolButton[] _toolbuttons;
	}
}