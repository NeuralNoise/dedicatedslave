module dedicatedslave.gui.containers.list;

private import gtk.TreeView;
private import gtk.TreeViewColumn;
private import gtk.ListStore;
private import gtk.CellRendererText;
private import gtk.ListStore;
private import gtk.TreeIter;
private import gtkc.gobjecttypes;

class CountryListStore : ListStore
{
    this()
    {
        super([GType.STRING, GType.STRING]);
    }
   
    public void addCountry(in string name, in string capital)
    {
        TreeIter iter = createIter();
        setValue(iter, 0, name);
        setValue(iter, 1, capital);
    }
}

class CountryTreeView : TreeView
{
    private TreeViewColumn countryColumn;
    private TreeViewColumn capitalColumn;
   
    this(ListStore store)
    {       
        // Add Country Column
        countryColumn = new TreeViewColumn(
            "Country", new CellRendererText(), "text", 0);
        appendColumn(countryColumn);
       
        // Add Capital Column
        capitalColumn = new TreeViewColumn(
            "Capital", new CellRendererText(), "text", 1);
        appendColumn(capitalColumn);
       
        setModel(store);
    }
}