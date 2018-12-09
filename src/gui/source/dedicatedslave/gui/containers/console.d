module dedicatedslave.gui.containers.console;

import gtk.TreeView;
import gtk.TreeViewColumn;
import gtk.ListStore;
import gtk.CellRendererText;
import gtk.TextView;
import gtk.ListStore;
import gtk.TreeIter;
import gtkc.gobjecttypes;

import glib.ShellUtils;

import dedicatedslave.gui.loader;

class ConsoleContainer : TextView
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
		}, 0);
    }

}