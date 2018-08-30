module dedicatedslave.gui.mainwindow;

import gtk.ApplicationWindow;
import gtk.Application;
import gtk.Label;
import gtk.MenuBar;
import gtk.Box;
import gtk.Main;
import gtk.MenuItem;
import gtk.Menu;
import gtk.Widget;
import gtk.Button;

import gdk.Event;

import dedicatedslave.gui.loader;

class MainWindow : ApplicationWindow
{
	this(Application application, ref GUILoader loader)
	{
		super(application);
		setTitle("DedicatedSlave");
		// TODO: provavelmente isto esta a foder o aspecto do MenuBar, tenta meter a MenuBar na MainWindow
		setBorderWidth(10);
		setDefaultSize(800, 600);

		MenuBar menuBar = new MenuBar();
     	menuBar.append(new FileMenuItem());
		Box box = new Box(Orientation.VERTICAL, 10);
    	box.packStart(menuBar, false, false, 0);
		box.packStart(new Button("Hello World"), true, true, 0);
		box.packStart(new Button("Click Me!"), true, false, 0);
		box.packStart(new Button("Goodbye World"), false, false, 10);
		add(box);

		showAll();
	}
}

class FileMenuItem : MenuItem
{
    Menu fileMenu;
    MenuItem exitMenuItem;
   
    this()
    {
        super("File");
        fileMenu = new Menu();
       
        exitMenuItem = new MenuItem("Exit");
        exitMenuItem.addOnButtonRelease(&exit);
        fileMenu.append(exitMenuItem);
       
        setSubmenu(fileMenu);
    }
   
    bool exit(Event event, Widget widget)
    {
        Main.quit();
        return true;
    }
}
