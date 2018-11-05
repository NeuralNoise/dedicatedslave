module dedicatedslave.gui.containers.list;

import gtk.TreeView;
import gtk.TreeViewColumn;
import gtk.ListStore;
import gtk.CellRendererText;
import gtk.ListStore;
import gtk.TreeIter;
import gtkc.gobjecttypes;

import dedicatedslave.data.models;
import dedicatedslave.gui.loader;

class GameInstanceListStore : ListStore
{

    private GUILoader _loader;

    this(GUILoader loader)
    {
        super([GType.STRING, GType.STRING]);
        _loader = loader;
        GameInstance[] instances = loader.fetchInstances();
        foreach(instance; instances){
            addInstance(instance.getName(), "0");
        }
    }
   
    public void addInstance(in string name, in string type)
    {
        TreeIter iter = createIter();
        setValue(iter, 0, name);
        setValue(iter, 1, type);
    }

}

class ListContainer : TreeView
{
    private TreeViewColumn nameColumn;
    private TreeViewColumn typeColumn;
    private GUILoader _loader;

    this(GameInstanceListStore store, GUILoader loader)
    {
        _loader = loader;
        // Add Name Column
        nameColumn = new TreeViewColumn(
            "Name", new CellRendererText(), "text", 0);
        appendColumn(nameColumn);
       
        // Add Type Column
        typeColumn = new TreeViewColumn(
            "Type", new CellRendererText(), "text", 1);
        appendColumn(typeColumn);
       
        setModel(store);

        addOnCursorChanged(&onCursorChanged);
    }

    void onCursorChanged(TreeView t){
        TreeIter selectedIter = t.getSelectedIter();
        _loader.setSelectedInstance(selectedIter.getValueString(0));
    }
}