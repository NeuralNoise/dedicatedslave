module dedicatedslave.gui.containers.notebook;

import gtk.TreeView;
import gtk.TreeViewColumn;
import gtk.Label;
import gtk.CellRendererText;
import gtk.Notebook;
import gtk.ListStore;
import gtk.Box;
import gtkc.gobjecttypes;

class MainNotebook : Notebook
{
    this()
    {
        super();

		Box tester1=new Box(Orientation.VERTICAL, 1);  
		this.appendPage(tester1, new Label("Settings"));
		Box tester2=new Box(Orientation.VERTICAL, 1);
		this.appendPage(tester2, new Label("Addons"));
    }

}