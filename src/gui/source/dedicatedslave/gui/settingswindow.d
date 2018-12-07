module dedicatedslave.gui.settingswindow;
import gtk.VBox;
import gtk.HBox;
import gtk.Box;
import gtk.Button;
import gtk.ComboBoxText;
import gtk.Label;
import gtk.Entry;
import gtk.Window;

import dedicatedslave.gui.loader;

class SettingsWindow : Window {

    private GUILoader* _loader;

    this(GUILoader* loader){
        super("Settings");
        _loader = loader;
        setupWindow();
    }

    void setupWindow(){
        VBox box = new VBox(false, 5);
			
        Box hbox1 = new Box(Orientation.HORIZONTAL, 10);
        hbox1.setBorderWidth(8);
        hbox1.packStart(new Label("Instance Folder:"), false, false, 0);
        hbox1.packStart(new Label(_loader.getInstanceName()), false, false, 0);

        Box hbox2 = new Box(Orientation.HORIZONTAL, 10);
        hbox2.setBorderWidth(8);
        hbox2.packStart(new Label("Instance Folder:"), false, false, 0);
        hbox2.packStart(new Label("..."), false, false, 0);

        Box hbox3 = new Box(Orientation.HORIZONTAL, 10);
        hbox3.setBorderWidth(8);
        hbox3.packStart(new Button("OK"), false, false, 0);

        box.packStart(hbox1, false, false, 0);
        box.packStart(hbox2, false, false, 0);
        box.packStart(hbox3, false, false, 0);

        add(box);
    }
    
}