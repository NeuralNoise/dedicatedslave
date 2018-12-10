module dedicatedslave.gui.prefs.settingseditor;


import std.algorithm;
import std.array;
import std.conv;
import std.experimental.logger;
import std.file;
import std.format;
import std.path;
import std.string;

import gdk.Event;
import gdk.RGBA;

import gio.Settings : GSettings = Settings;

import glib.URI;
import glib.Util;

import gtk.Application;
import gtk.ApplicationWindow;
import gtk.Box;
import gtk.Button;
import gtk.CellRendererText;
import gtk.CheckButton;
import gtk.ColorButton;
import gtk.ComboBox;
import gtk.ComboBoxText;
import gtk.Dialog;
import gtk.EditableIF;
import gtk.Entry;
import gtk.FileChooserDialog;
import gtk.FileFilter;
import gtk.FontButton;
import gtk.Grid;
import gtk.HeaderBar;
import gtk.Image;
import gtk.Label;
import gtk.ListStore;
import gtk.MenuButton;
import gtk.Notebook;
import gtk.Popover;
import gtk.Scale;
import gtk.ScrolledWindow;
import gtk.SizeGroup;
import gtk.SpinButton;
import gtk.Switch;
import gtk.TreeIter;
import gtk.TreePath;
import gtk.TreeView;
import gtk.TreeViewColumn;
import gtk.Version;
import gtk.Widget;
import gtk.Window;

//import dedicatedslave.gui.gtk.vte;
import dedicatedslave.gui.gtk.dialog;
import dedicatedslave.gui.gtk.settings;
import dedicatedslave.gui.gtk.util;
import dedicatedslave.gui.preferences;
import dedicatedslave.gui.i18n.l10n;
import dedicatedslave.gui.prefs.common;

/**
 * Base class for profile pages, takes care of binding/unbinding settings
 * in a consistent way as the user moves from profile to profile in the
 * preferences dialog.
 *
 * Relies extensively on the BindingHelper class to track bindings.
 */
class ProfilePage: Box {

private:
    ProfileInfo profile;
    GSettings gsProfile;
    BindingHelper bh;

public:
    this() {
        super(Orientation.VERTICAL, 6);
        setAllMargins(this, 18);
        bh = new BindingHelper();
    }

    void bind(ProfileInfo profile, GSettings gsProfile) {
        this.profile = profile;
        this.gsProfile = gsProfile;
        bh.settings = gsProfile;
    }

    void unbind() {
        bh.settings = null;
        profile = ProfileInfo(false, null, null);
    }
}

/**
 * Page for advanced profile options such as custom hyperlinks and profile switching
 */
class AdvancedPage: ProfilePage {
private:
    TreeView tvValues;
    ListStore lsValues;

    Button btnAdd;
    Button btnEdit;
    Button btnDelete;

     void createUI() {
        Grid grid = new Grid();
        grid.setColumnSpacing(12);
        grid.setRowSpacing(6);

        uint row = 0;

        //Notify silence threshold
        Label lblSilenceTitle = new Label(format("<b>%s</b>", _("Notify New Activity")));
        lblSilenceTitle.setUseMarkup(true);
        lblSilenceTitle.setHalign(Align.START);
        lblSilenceTitle.setMarginTop(12);
        grid.attach(lblSilenceTitle, 0, row, 3, 1);
        row++;

        grid.attach(createDescriptionLabel(_("A notification can be raised when new activity occurs after a specified period of silence.")),0,row,2,1);
        row++;

        Widget silenceUI = createSilenceUI();
        silenceUI.setMarginTop(6);
        silenceUI.setMarginBottom(6);
        grid.attach(silenceUI, 0, row, 2, 1);
        row++;

        // Create shared advance UI Settings
        createAdvancedUI(grid, row, &getSettings);

        // Profile Switching
        Label lblProfileSwitching = new Label(format("<b>%s</b>", _("Automatic Profile Switching")));
        lblProfileSwitching.setUseMarkup(true);
        lblProfileSwitching.setHalign(Align.START);
        lblProfileSwitching.setMarginTop(12);
        grid.attach(lblProfileSwitching, 0, row, 3, 1);
        row++;

        string profileSwitchingDescription;
        // if (checkVTEFeature(TerminalFeature.EVENT_SCREEN_CHANGED)) {
        //     profileSwitchingDescription = _("Profiles are automatically selected based on the values entered here.\nValues are entered using a <i>username@hostname:directory</i> format. Either the hostname or directory can be omitted but the colon must be present. Entries with neither hostname or directory are not permitted.");
        // } else {
        //     profileSwitchingDescription = _("Profiles are automatically selected based on the values entered here.\nValues are entered using a <i>hostname:directory</i> format. Either the hostname or directory can be omitted but the colon must be present. Entries with neither hostname or directory are not permitted.");
        // }
        grid.attach(createDescriptionLabel(profileSwitchingDescription),0,row,2,1);
        row++;

        lsValues = new ListStore([GType.STRING]);
        tvValues = new TreeView(lsValues);
        tvValues.setActivateOnSingleClick(true);
        tvValues.addOnCursorChanged(delegate(TreeView) {
            updateUI();
        });

        TreeViewColumn column = new TreeViewColumn(_("Match"), new CellRendererText(), "text", 0);
        tvValues.appendColumn(column);

        ScrolledWindow scValues = new ScrolledWindow(tvValues);
        scValues.setShadowType(ShadowType.ETCHED_IN);
        scValues.setPolicy(PolicyType.NEVER, PolicyType.AUTOMATIC);
        scValues.setHexpand(true);

        Box bButtons = new Box(Orientation.VERTICAL, 4);
        bButtons.setVexpand(true);

        btnAdd = new Button(_("Add"));
        btnAdd.addOnClicked(delegate(Button) {
            string label, value;
            // if (checkVTEFeature(TerminalFeature.EVENT_SCREEN_CHANGED)) {
            //     label = _("Enter username@hostname:directory to match");
            // } else {
            //     label = _("Enter hostname:directory to match");
            // }
            if (showInputDialog(cast(Window)getToplevel(), value, "", _("Add New Match"), label, &validateInput)) {
                TreeIter iter = lsValues.createIter();
                lsValues.setValue(iter, 0, value);
                storeValues();
                selectRow(tvValues, lsValues.iterNChildren(null) - 1, null);
            }
        });

        bButtons.add(btnAdd);

        btnEdit = new Button(_("Edit"));
        btnEdit.addOnClicked(delegate(Button) {
            TreeIter iter = tvValues.getSelectedIter();
            if (iter !is null) {
                string value = lsValues.getValueString(iter, 0);
                string label;
                // if (checkVTEFeature(TerminalFeature.EVENT_SCREEN_CHANGED)) {
                //     label = _("Edit username@hostname:directory to match");
                // } else {
                //     label = _("Edit hostname:directory to match");
                // }
                if (showInputDialog(cast(Window)getToplevel(), value, value, _("Edit Match"), label, &validateInput)) {
                    lsValues.setValue(iter, 0, value);
                    storeValues();
                }
            }
        });
        bButtons.add(btnEdit);

        btnDelete = new Button(_("Delete"));
        btnDelete.addOnClicked(delegate(Button) {
            TreeIter iter = tvValues.getSelectedIter();
            if (iter !is null) {
                lsValues.remove(iter);
                storeValues();
            }
        });
        bButtons.add(btnDelete);

        grid.attach(scValues, 0, row, 2, 1);
        grid.attach(bButtons, 2, row, 1, 1);

        this.add(grid);
    }

    Widget createSilenceUI() {
        Grid grid = new Grid();
        grid.setColumnSpacing(12);
        grid.setRowSpacing(6);

        uint row = 0;

        Label lblSilence = new Label(_("Enable by default"));
        lblSilence.setHalign(Align.END);
        grid.attach(lblSilence, 0, row, 1, 1);

        CheckButton cbSilence = new CheckButton();
        bh.bind(SETTINGS_PROFILE_NOTIFY_ENABLED_KEY, cbSilence, "active", GSettingsBindFlags.DEFAULT);
        grid.attach(cbSilence, 1, row, 1, 1);
        row++;

        Label lblSilenceDesc = new Label(_("Threshold for continuous silence"));
        lblSilenceDesc.setHalign(Align.END);
        grid.attach(lblSilenceDesc, 0, row, 1, 1);

        Box bSilence = new Box(Orientation.HORIZONTAL, 4);
        SpinButton sbSilence = new SpinButton(0, 3600, 60);
        bh.bind(SETTINGS_PROFILE_NOTIFY_SILENCE_THRESHOLD_KEY, sbSilence, "value", GSettingsBindFlags.DEFAULT);
        bSilence.add(sbSilence);

        Label lblSilenceTime = new Label(_("(seconds)"));
        lblSilenceTime.setSensitive(false);
        bSilence.add(lblSilenceTime);

        grid.attach(bSilence, 1, row, 1, 1);
        row++;

        return grid;
    }

    void updateUI() {
        TreeIter selected = tvValues.getSelectedIter();
        btnDelete.setSensitive(selected !is null);
        btnEdit.setSensitive(selected !is null);
    }

    void updateBindValues() {
        //Automatic switching
        lsValues.clear();
        string[] values = gsProfile.getStrv(SETTINGS_PROFILE_AUTOMATIC_SWITCH_KEY);
        foreach(value; values) {
            TreeIter iter = lsValues.createIter();
            lsValues.setValue(iter, 0, value);
        }

    }

    // Validate input, just checks something was entered at this point
    // and least one delimiter, either @ or :
    bool validateInput(string match) {
        // if (checkVTEFeature(TerminalFeature.EVENT_SCREEN_CHANGED))
        //     return (match.length > 1 && (match.indexOf('@') >= 0 || match.indexOf(':') >= 0));
        // else
        //     return (match.length > 1 && (match.indexOf('@') == 0 || match.indexOf(':') >= 0));
        return true;
    }

    // Store the values in the ListStore into settings
    void storeValues() {
        string[] values;
        foreach (TreeIter iter; TreeIterRange(lsValues)) {
            values ~= lsValues.getValueString(iter, 0);
        }
        gsProfile.setStrv(SETTINGS_PROFILE_AUTOMATIC_SWITCH_KEY, values);
    }

    GSettings getSettings() {
        return gsProfile;
    }

public:
    this() {
        super();
        createUI();
    }

    override void bind(ProfileInfo profile, GSettings gsProfile) {
        super.bind(profile, gsProfile);
        if (gsProfile !is null) {
            updateBindValues();
            updateUI();
        }
    }
}
