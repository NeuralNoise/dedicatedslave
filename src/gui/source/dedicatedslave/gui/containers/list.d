module dedicatedslave.gui.containers.list;

private import gtk.TreeView;
private import gtk.TreeViewColumn;
private import gtk.ListStore;
private import gtk.CellRendererText;
private import gtk.ListStore;
private import gtk.TreeIter;
private import gtkc.gobjecttypes;

class GameListStore : ListStore
{
    this()
    {
        super([GType.STRING, GType.STRING]);
    }
   
    public void addInstance(in string name, in string type)
    {
        TreeIter iter = createIter();
        setValue(iter, 0, name);
        setValue(iter, 1, type);
    }
}

class GameTreeView : TreeView
{
    private TreeViewColumn nameColumn;
    private TreeViewColumn typeColumn;
   
    this(ListStore store)
    {       
        // Add Name Column
        nameColumn = new TreeViewColumn(
            "Name", new CellRendererText(), "text", 0);
        appendColumn(nameColumn);
       
        // Add Type Column
        typeColumn = new TreeViewColumn(
            "Type", new CellRendererText(), "text", 1);
        appendColumn(typeColumn);
       
        setModel(store);
    }
}