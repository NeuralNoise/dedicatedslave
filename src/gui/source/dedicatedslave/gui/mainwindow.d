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
import gtk.ListBox;
import gtk.TextView;
import gtk.Toolbar;
import gtk.Statusbar;
import gtk.Notebook;
import gdk.Event;
import dedicatedslave.gui.loader;

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

		//_menuItem = new MenuItem("");
		//_menuItem.addOnButtonRelease(&);
		//_menu.append(_menuItem);

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

		//_menuItem = new MenuItem("");
		//_menuItem.addOnButtonRelease(&);
		//_menu.append(_menuItem);

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

		//_menuItem = new MenuItem("");
		//_menuItem.addOnButtonRelease(&);
		//_menu.append(_menuItem);

		setSubmenu(_menu);
	}
private:
	Menu _menu;
	MenuItem _menuItem;
}

class HelpMenuItem : MenuItem
{
	this()
	{
		super("Help");
		_menu = new Menu();

		_menuItem = new MenuItem("About");
		//_menuItem.addOnButtonRelease(&);
		_menu.append(_menuItem);

		setSubmenu(_menu);
	}
private:
	Menu _menu;
	MenuItem _menuItem;
}

class MainWindow : ApplicationWindow
{
	this(Application application, ref GUILoader loader)
	{
		super(application);
		setTitle("DedicatedSlave");
		setDefaultSize(800, 600);

		MenuBar menuBar = new MenuBar();
		menuBar.append(new FileMenuItem());
		menuBar.append(new EditMenuItem());
		menuBar.append(new ViewMenuItem());
		menuBar.append(new ToolsMenuItem());
		menuBar.append(new HelpMenuItem());

		Toolbar toolbar = new Toolbar();
		Box box = new Box(Orientation.VERTICAL, 10);
		Box hbox = new Box(Orientation.HORIZONTAL, 10);
		Box left_vbox = new Box(Orientation.VERTICAL, 10);
		Box right_vbox = new Box(Orientation.VERTICAL, 10);
		box.packStart(menuBar, false, false, 0);
		box.packStart(toolbar, false, false, 0);
		hbox.setBorderWidth(8);
		TextView terminalTextView = new TextView();
		ListBox listBox = new ListBox();
		left_vbox.packStart(terminalTextView, true, true, 0);
		left_vbox.packStart(listBox, true, true, 0);
		hbox.packStart(left_vbox, true, true, 0);
		Notebook tabController = new Notebook();
		right_vbox.packStart(tabController, true, true, 0);
		hbox.packStart(right_vbox, true, true, 0);
		box.packStart(hbox, true, true, 0);
		Statusbar statusbar = new Statusbar();
		box.packStart(statusbar, false, false, 0);
		add(box);

		showAll();
	}
}