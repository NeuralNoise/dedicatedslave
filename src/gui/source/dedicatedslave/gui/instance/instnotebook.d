module dedicatedslave.gui.instance.instnotebook;

import gtk.TreeView;
import gtk.TreeViewColumn;
import gtk.Label;
import gtk.CellRendererText;
import gtk.Notebook;
import gtk.ListStore;
import gtk.Box;
import gtk.Entry;
import gtk.SpinButton;
import gtkc.gobjecttypes;

import dedicatedslave.gui.instance.instwindow;
import dedicatedslave.gui.loader;
import dedicatedslave.data.models;

class InstanceNotebook : Notebook {

private:

	GUILoader* _loader;
	InstanceWindow _parent;

public:

    this(InstanceWindow parent, GUILoader* loader){
        super();
		
		_parent = parent;
		_loader = loader;

		GameInstance g = _parent.getInstance();

		Box tester1 = new Box(Orientation.VERTICAL, 1);  
		Box tester2 = new Box(Orientation.VERTICAL, 1);

		// Name
		Box tester1sub1 = new Box(Orientation.HORIZONTAL, 1);
		tester1sub1.setBorderWidth(8);
		tester1sub1.packStart(new Label("Name:"), false, false, 0);
		tester1sub1.packStart(new Entry(g.getName(), 15), false, false, 0);
		// Description
		Box tester1sub2 = new Box(Orientation.HORIZONTAL, 1);
		tester1sub2.setBorderWidth(8);
		tester1sub2.packStart(new Label("Description:"), false, false, 0);
		tester1sub2.packStart(new Entry(g.getDescription(), 15), false, false, 0);
		// Hostname
		Box tester1sub3 = new Box(Orientation.HORIZONTAL, 1);
		tester1sub3.setBorderWidth(8);
		tester1sub3.packStart(new Label("Hostname:"), false, false, 0);
		tester1sub3.packStart(new Entry(g.getHostname(), 15), false, false, 0);
		// Max Players
		Box tester1sub4 = new Box(Orientation.HORIZONTAL, 1);
		tester1sub4.setBorderWidth(8);
		tester1sub4.packStart(new Label("Max Players:"), false, false, 0);
		tester1sub4.packStart(new SpinButton(1, 64, 1), false, false, 0);
        
		tester1.packStart(tester1sub1, false, false, 0);
		tester1.packStart(tester1sub2, false, false, 0);
		tester1.packStart(tester1sub3, false, false, 0);
		tester1.packStart(tester1sub4, false, false, 0);

        this.appendPage(tester1, new Label("Settings"));
		this.appendPage(tester2, new Label("Addons"));
    }

}