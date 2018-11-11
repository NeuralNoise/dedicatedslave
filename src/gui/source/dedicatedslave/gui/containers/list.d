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
import dedicatedslave.gui.mainwindow;

class GameInstanceListStore : ListStore
{

    private GUILoader _loader;

    this(GUILoader loader)
    {
        super([GType.STRING, GType.STRING]);
        _loader = loader;
        GameInstance[] instances = loader.fetchInstances();
        foreach(instance; instances){
            addInstance(instance.getName(), instance.getType);
        }
    }
   
    public void addInstance(in string name, in int type)
    {
        TreeIter iter = createIter();
        setValue(iter, 0, name);
        setValue(iter, 1, type);
    }

    public bool removeInstance(TreeIter selectedIter)
    {
        return remove(selectedIter);
    }

}

class ListContainer : TreeView
{
    private TreeViewColumn nameColumn;
    private TreeViewColumn typeColumn;
    private GUILoader _loader;
    private MainAppWindow _parent;

    this(MainAppWindow parent, GameInstanceListStore store, GUILoader loader)
    {
        _parent = parent;
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

        // TODO: when getSelectedIter return invalid treeiter, don't set selected instance.
        _loader.setSelectedInstance(selectedIter.getValueString(0));
        _parent.setSelectedInstance(selectedIter);
    }
}