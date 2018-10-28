module dedicatedslave.gui.containers.notebook;

private import gtk.TreeView;
private import gtk.TreeViewColumn;
private import gtk.Label;
private import gtk.CellRendererText;
private import gtk.Notebook;
private import gtk.ListStore;
private import gtk.Box;
private import gtkc.gobjecttypes;

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