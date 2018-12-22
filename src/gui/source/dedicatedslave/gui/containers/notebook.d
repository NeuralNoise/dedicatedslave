module dedicatedslave.gui.containers.notebook;

import gtk.TreeView;
import gtk.TreeViewColumn;
import gtk.Label;
import gtk.CellRendererText;
import gtk.Notebook;
import gtk.ListStore;
import gtk.Box;
import gtk.Entry;
import gtkc.gobjecttypes;

import dedicatedslave.gui.instance.instwindow;
import dedicatedslave.gui.loader;

class NotebookContainer : Notebook {

private:


public:

    this(){
        super();

        setupWindow();
    }

    /**
     * Setup Window.
     */
	void setupWindow(){
        Box tester1 = new Box(Orientation.VERTICAL, 1);  

		Box hbox1 = new Box(Orientation.HORIZONTAL, 10);
		hbox1.setBorderWidth(8);
		hbox1.packStart(new Label("Instance Name:"), false, false, 0);
		Entry e = new Entry("", 15);
		hbox1.packStart(e, false, false, 0);

        tester1.packStart(hbox1, false, false, 0);

		Box tester2 = new Box(Orientation.VERTICAL, 1);

        this.appendPage(tester1, new Label("Settings"));
		this.appendPage(tester2, new Label("Addons"));

	}

}