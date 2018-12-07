module dedicatedslave.gui.instance.instwindow;

import gtk.Window;
import gtk.VBox;
import gtk.AccelGroup;
import gtk.Label;
import gtk.Box;
import gtk.ComboBoxText;
import gtk.ScrolledWindow;
import gtk.TextView;

import dedicatedslave.gui.instance.insttoolbar;
import dedicatedslave.gui.apptoolbar;
import dedicatedslave.gui.loader;
import dedicatedslave.gui.containers.notebook;

class InstanceWindow : Window
{
    private MainToolbar _parent;
    private GUILoader* _loader;

    this(MainToolbar parent, GUILoader* loader, string title)
    {
        super(title);
        
        _parent = parent;
        _loader = loader;

        setupWindow(loader);
        maximize();

    }

    void setupWindow(GUILoader* loader)
    {

        Box box = new Box(Orientation.VERTICAL, 10);

		AccelGroup accelGroup = new AccelGroup();
        addAccelGroup(accelGroup);

		Box hbox = new Box(Orientation.HORIZONTAL, 10);
		hbox.setBorderWidth(8);

        TextView t = new TextView();
        t.setEditable(false);
        t.setMonospace(true);
        t.setWrapMode(GtkWrapMode.WORD_CHAR);
        //_loader.changeLogCallback(delegate(immutable string msg) {
        //    import glib.Idle;
        //    new Idle({t.appendText(msg~"\n"); return false;}, GPriority.DEFAULT_IDLE, true);
        //});

        TextView t1 = new TextView();

		Box left_vbox = new Box(Orientation.VERTICAL, 10);
		left_vbox.packStart(new ScrolledWindow(t), true, true, 0);
		left_vbox.packStart(t1, true, true, 0);
		hbox.packStart(left_vbox, true, true, 0);

		Box right_vbox = new Box(Orientation.VERTICAL, 10);
		right_vbox.packStart(new NotebookContainer(), true, true, 0);
		hbox.packStart(right_vbox, true, true, 0);

		//box.packStart(new MainMenuBar(this, accelGroup, loader), false, false, 0);
		box.packStart(new InstanceToolbar(this, loader), false, false, 0);
		
		box.packStart(hbox, true, true, 0);
		//box.packStart(new MainStatusbar(), false, false, 0);

		add(box);
        this.showAll();

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
}