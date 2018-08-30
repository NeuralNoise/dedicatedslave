module dedicatedslave.gui.mainwindow;

import gtk.ApplicationWindow;
import gtk.Application;
import gtk.Label;
import dedicatedslave.gui.loader;

class MainWindow : ApplicationWindow
{
	this(Application application, ref GUILoader loader)
	{
		super(application);
		setTitle("DedicatedSlave");
		setBorderWidth(10);
		setDefaultSize(800, 600);

		add(new Label("Hello World"));

		showAll();
	}
}
