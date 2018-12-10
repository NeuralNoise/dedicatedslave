module dedicatedslave.gui.appmenubar;

import gtk.Menu;
import gtk.MenuItem;
import gtk.MenuBar;
import gtk.AccelGroup;
import gdk.Event;
import gtk.Widget;
import gtk.Main;
import gtk.Dialog;
import gtk.AboutDialog;
import gtk.MessageDialog;
import gtk.SeparatorMenuItem;

import dedicatedslave.gui.prefs.settingswindow;
import dedicatedslave.gui.appwindow;
import dedicatedslave.gui.loader;

class MainMenuBar : MenuBar
{

    private GUILoader* _loader;
    private MainAppWindow _parent;

    this(MainAppWindow parent, AccelGroup accelGroup, ref GUILoader loader)
    {
        super();
        _parent = parent;
        _loader = &loader;
        this.append(new FileMenuItem(accelGroup));
        this.append(new ViewMenuItem(accelGroup));
        this.append(new HelpMenuItem(accelGroup));
    }

    void onMenuActivate(MenuItem menuItem)
	{
		string action = menuItem.getActionName();
		switch( action )
		{
			case "help.about":
				AboutDialog dlg = new AboutDialog();
                string[] names = ["Alexandre Ferreira (github.com/alex1a)", "Luís Ferreira (github.com/ljmf00)", "EnthDev (enthdev.github.io)"];
                dlg.setAuthors( names );
                dlg.setDocumenters( names );
                dlg.setArtists( names );
                dlg.setLicense("License is MIT");
                dlg.setWebsite("https://dedicatedslave.readthedocs.io");
				dlg.addOnResponse(&onDialogResponse);
				dlg.showAll();
				break;
			case "help.welcome":
				break;
			case "file.settings":
				SettingsWindow w = new SettingsWindow(_loader);
				w.showAll();
				break;
			case "toolbar.add":
				break;
			default:
				MessageDialog d = new MessageDialog(
					_parent,
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

    class FileMenuItem : MenuItem
    {
        private Menu _menu;
        private MenuItem _menuItem_settings;
        private MenuItem _menuItem_exit;

        this(AccelGroup accelGroup)
        {
            super("File");
            _menu = new Menu();

            _menuItem_settings = new MenuItem(&MainMenuBar.onMenuActivate,"_Settings","file.settings", true, accelGroup, 'a', GdkModifierType.CONTROL_MASK|GdkModifierType.SHIFT_MASK);
            _menuItem_exit = new MenuItem("Exit");
            _menuItem_exit.addOnButtonRelease(&exit);

            _menu.append(_menuItem_settings);
            _menu.append(new SeparatorMenuItem());
            _menu.append(_menuItem_exit);

            setSubmenu(_menu);
        }

        bool exit(Event event, Widget widget)
        {
            Main.quit();
            return true;
        }        

    }

    class ViewMenuItem : MenuItem
    {

        private Menu _menu;
        private MenuItem[] _menuItems;

        this(AccelGroup accelGroup)
        {
            super("View");
            _menu = new Menu();

            _menuItems ~= new MenuItem(&MainMenuBar.onMenuActivate,"_Show","help.welcome", true, accelGroup, 'a', GdkModifierType.CONTROL_MASK|GdkModifierType.SHIFT_MASK);

            foreach(menuItem; _menuItems){
                _menu.append(menuItem);
            }

            setSubmenu(_menu);
        }
    }

    class HelpMenuItem : MenuItem
    {

        private Menu _menu;
        private MenuItem[] _menuItems;

        this(AccelGroup accelGroup)
        {
            super("Help");
            _menu = new Menu();
            
            _menuItems ~= new MenuItem(&MainMenuBar.onMenuActivate,"_Welcome","help.welcome", true, accelGroup, 'a', GdkModifierType.CONTROL_MASK|GdkModifierType.SHIFT_MASK);
            _menuItems ~= new MenuItem(&MainMenuBar.onMenuActivate,"_Documentation","help.documentation", true, accelGroup, 'a', GdkModifierType.CONTROL_MASK|GdkModifierType.SHIFT_MASK);
            _menuItems ~= new MenuItem(&MainMenuBar.onMenuActivate,"_Release Notes","help.releasenotes", true, accelGroup, 'a', GdkModifierType.CONTROL_MASK|GdkModifierType.SHIFT_MASK);
            _menuItems ~= new SeparatorMenuItem();
            _menuItems ~= new MenuItem(&MainMenuBar.onMenuActivate,"_Join us on Discord","help.discord", true, accelGroup, 'a', GdkModifierType.CONTROL_MASK|GdkModifierType.SHIFT_MASK);
            _menuItems ~= new MenuItem(&MainMenuBar.onMenuActivate,"_Report Issue","help.issue", true, accelGroup, 'a', GdkModifierType.CONTROL_MASK|GdkModifierType.SHIFT_MASK);
            _menuItems ~= new SeparatorMenuItem();
            _menuItems ~= new MenuItem(&MainMenuBar.onMenuActivate,"_License","help.license", true, accelGroup, 'a', GdkModifierType.CONTROL_MASK|GdkModifierType.SHIFT_MASK);
            _menuItems ~= new SeparatorMenuItem();
            _menuItems ~= new MenuItem(&MainMenuBar.onMenuActivate,"_About","help.about", true, accelGroup, 'a', GdkModifierType.CONTROL_MASK|GdkModifierType.SHIFT_MASK);
            
            foreach(menuItem; _menuItems){
                _menu.append(menuItem);
            }
            
            setSubmenu(_menu);
        }
    }
}