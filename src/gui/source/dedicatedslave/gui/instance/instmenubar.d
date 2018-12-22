module dedicatedslave.gui.instance.instmenubar;

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

import dedicatedslave.gui.appwindow;
import dedicatedslave.gui.loader;
import dedicatedslave.gui.instance.instwindow;

class InstanceMenuBar : MenuBar {

private:

    GUILoader* _loader;
    InstanceWindow _parent;

    void onMenuActivate(MenuItem menuItem){
		string action = menuItem.getActionName();
		switch(action){
			case "file.wip":
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

    class FileMenuItem : MenuItem{
        private Menu _menu;
        private MenuItem _menuItem_wip;
        private MenuItem _menuItem_exit;

        this(AccelGroup accelGroup){
            super("File");
            _menu = new Menu();

            _menuItem_wip = new MenuItem("WIP");
            _menuItem_exit = new MenuItem("Exit");
            _menuItem_exit.addOnButtonRelease(&exit);

            _menu.append(_menuItem_wip);
            _menu.append(new SeparatorMenuItem());
            _menu.append(_menuItem_exit);

            setSubmenu(_menu);
        }

        bool exit(Event event, Widget widget){
            Main.quit();
            return true;
        }        

    }

public:

    this(InstanceWindow parent, AccelGroup accelGroup, GUILoader* loader){
        super();
        _parent = parent;
        _loader = loader;
        this.append(new FileMenuItem(accelGroup));
    }
}