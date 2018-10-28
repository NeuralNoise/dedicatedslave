module dedicatedslave.gui.containers.console;

private import gtk.TreeView;
private import gtk.TreeViewColumn;
private import gtk.ListStore;
private import gtk.CellRendererText;
private import gtk.TextView;

private import gtk.ListStore;
private import gtk.TreeIter;
private import gtkc.gobjecttypes;
private import dedicatedslave.gui.loader;

class MainConsole : TextView
{
    this(ref GUILoader loader)
    {
        super();
		this.setEditable(false);
		this.setMonospace(true);
		this.setWrapMode(GtkWrapMode.WORD_CHAR);
		loader.changeLogCallback(delegate(immutable string msg) {
			import glib.Idle;
			new Idle({this.appendText(msg~"\n"); return false;}, GPriority.DEFAULT_IDLE, true);
		});
    }

}