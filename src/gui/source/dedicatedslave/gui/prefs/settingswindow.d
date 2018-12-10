module dedicatedslave.gui.prefs.settingswindow;

import std.algorithm;
import std.conv;
import std.experimental.logger;
import std.file;
import std.format;
import std.process;
import std.string;
import std.typecons : No;
import std.variant;

import gdk.Event;
import gdk.Screen;

import gio.Menu: GMenu = Menu;
import gio.Settings: GSettings = Settings;
import gio.SimpleAction;
import gio.SimpleActionGroup;

import glib.Variant: GVariant = Variant;

import gobject.ObjectG;
import gobject.Signals;
import gobject.Value;

import gtk.AccelGroup;
import gtk.Application;
import gtk.ApplicationWindow;
import gtk.Box;
import gtk.Button;
import gtk.CellRendererAccel;
import gtk.CellRendererText;
import gtk.CellRendererToggle;
import gtk.CheckButton;
import gtk.ComboBox;
import gtk.Dialog;
import gtk.Entry;
import gtk.FileChooserButton;
import gtk.FileFilter;
import gtk.Grid;
import gtk.HeaderBar;
import gtk.Image;
import gtk.Label;
import gtk.ListBox;
import gtk.ListBoxRow;
import gtk.ListStore;
import gtk.MenuButton;
import gtk.MessageDialog;
import gtk.Popover;
import gtk.Revealer;
import gtk.Scale;
import gtk.ScrolledWindow;
import gtk.SearchEntry;
import gtk.Separator;
import gtk.Settings;
import gtk.SizeGroup;
import gtk.SpinButton;
import gtk.Stack;
import gtk.Switch;
import gtk.ToggleButton;
import gtk.TreeIter;
import gtk.TreeModel;
import gtk.TreeModelFilter;
import gtk.TreePath;
import gtk.TreeStore;
import gtk.TreeView;
import gtk.TreeViewColumn;
import gtk.Version;
import gtk.Widget;
import gtk.Window;

import dedicatedslave.gui.loader;
import dedicatedslave.gui.app;
import dedicatedslave.gui.preferences;
import dedicatedslave.gui.constants;
import dedicatedslave.gui.actions;
import dedicatedslave.gui.i18n.l10n;
import dedicatedslave.gui.gtk.util;
import dedicatedslave.gui.gtk.dialog;
import dedicatedslave.gui.gtk.settings;

import dedicatedslave.gui.prefs.settingseditor;
import dedicatedslave.gui.prefs.common;

class SettingsWindow : ApplicationWindow {

private:

    ToggleButton searchButton;
    Stack pages;
    GSettings gsSettings;
    HeaderBar hbMain;
    HeaderBar hbSide;
    ListBox lbSide;
    Button btnDeleteProfile;

    int nonProfileRowCount = 0;

    GUILoader* _loader;

    void createUI(){

        setTitle("Dedicated Settings");

        createSplitHeaders();

        //Create Listbox
        lbSide = new ListBox();
        lbSide.setCanFocus(true);
        lbSide.setSelectionMode(SelectionMode.BROWSE);
        lbSide.setVexpand(true);
        lbSide.addOnRowSelected(&onRowSelected);

        //Create Stack and boxes
        pages = new Stack();
        pages.setHexpand(true);
        pages.setVexpand(true);

        GlobalPreferences gp = new GlobalPreferences(gsSettings);
        pages.addTitled(gp, N_("Global"), _("Global"));
        addNonProfileRow(new GenericPreferenceRow(N_("Global"), _("Global")));

        // AppearancePreferences ap = new AppearancePreferences(gsSettings);
        // pages.addTitled(ap, N_("Appearance"), _("Appearance"));
        // addNonProfileRow(new GenericPreferenceRow(N_("Appearance"), _("Appearance")));

        // // Quake disabled in Wayland, see #1314
        // if (!isWayland(null)) {
        //     QuakePreferences qp = new QuakePreferences(gsSettings, _wayland);
        //     pages.addTitled(qp, N_("Quake"), _("Quake"));
        //     addNonProfileRow(new GenericPreferenceRow(N_("Quake"), _("Quake")));
        // }

        // bmEditor = new GlobalBookmarkEditor();
        // pages.addTitled(bmEditor, N_("Bookmarks"), _("Bookmarks"));
        // addNonProfileRow(new GenericPreferenceRow(N_("Bookmarks"), _("Bookmarks")));

        // ShortcutPreferences sp = new ShortcutPreferences(gsSettings);
        // searchButton.addOnToggled(delegate(ToggleButton button) {
        //     sp.toggleShortcutsFind();
        // });
        // pages.addTitled(sp, N_("Shortcuts"), _("Shortcuts"));
        // addNonProfileRow(new GenericPreferenceRow(N_("Shortcuts"), _("Shortcuts")));

        // EncodingPreferences ep = new EncodingPreferences(gsSettings);
        // pages.addTitled(ep, N_("Encoding"), _("Encoding"));
        // addNonProfileRow(new GenericPreferenceRow(N_("Encoding"), _("Encoding")));

        AdvancedPreferences advp = new AdvancedPreferences(gsSettings);
        pages.addTitled(advp, N_("Advanced"), _("Advanced"));
        addNonProfileRow(new GenericPreferenceRow(N_("Advanced"), _("Advanced")));

        // // Profile Editor - Re-used for all profiles
        // pe = new ProfileEditor();
        // pe.onProfileNameChanged.connect(&profileNameChanged);
        // pages.addTitled(pe, N_("Profile"), _("Profile"));
        // addNonProfileRow(createProfileTitleRow());
        // loadProfiles();

        ScrolledWindow sw = new ScrolledWindow(lbSide);
        sw.setPolicy(PolicyType.NEVER, PolicyType.AUTOMATIC);
        sw.setShadowType(ShadowType.NONE);
        sw.setSizeRequest(220, -1);

        Box bButtons = new Box(Orientation.HORIZONTAL, 0);
        bButtons.getStyleContext().addClass("linked");
        setAllMargins(bButtons, 6);
        Button btnAddProfile = new Button("list-add-symbolic", IconSize.BUTTON);
        btnAddProfile.setTooltipText(_("Add profile"));
        btnAddProfile.addOnClicked(&onAddProfile);
        bButtons.packStart(btnAddProfile, false, false, 0);

        btnDeleteProfile = new Button("list-remove-symbolic", IconSize.BUTTON);
        btnDeleteProfile.setTooltipText(_("Delete profile"));
        btnDeleteProfile.addOnClicked(&onDeleteProfile);
        bButtons.packStart(btnDeleteProfile, false, false, 0);

        Box bSide = new Box(Orientation.VERTICAL, 0);
        bSide.add(sw);
        bSide.add(new Separator(Orientation.HORIZONTAL));
        bSide.add(bButtons);

        Box box = new Box(Orientation.HORIZONTAL, 0);
        box.add(bSide);
        box.add(new Separator(Orientation.VERTICAL));
        box.add(pages);

        add(box);

        SizeGroup sgSide = new SizeGroup(SizeGroupMode.HORIZONTAL);
        sgSide.addWidget(hbSide);
        sgSide.addWidget(bSide);

        SizeGroup sgMain = new SizeGroup(SizeGroupMode.HORIZONTAL);
        sgMain.addWidget(hbMain);
        sgMain.addWidget(pages);

        //Set initial title
        hbMain.setTitle(_("Global"));

        // VBox box = new VBox(false, 5);
			
        // Box hbox1 = new Box(Orientation.HORIZONTAL, 10);
        // hbox1.setBorderWidth(8);
        // hbox1.packStart(new Label("Instance Folder:"), false, false, 0);
        // hbox1.packStart(new Label(_loader.getInstanceName()), false, false, 0);

        //Box hbox2 = new Box(Orientation.HORIZONTAL, 10);
        //hbox2.setBorderWidth(8);
        //hbox2.packStart(new Button("OK"), false, false, 0);

        // box.packStart(hbox1, false, false, 0);
        //box.packStart(hbox2, false, false, 0);

        // add(box);
    }

    void createSplitHeaders() {
        hbMain = new HeaderBar();
        hbMain.setHexpand(true);
        hbMain.setTitle("");

        searchButton = new ToggleButton();
        searchButton.setImage(new Image("system-search-symbolic", IconSize.MENU));
        searchButton.setNoShowAll(true);
        hbMain.packEnd(searchButton);

        hbMain.setShowCloseButton(true);

        hbSide = new HeaderBar();
        hbSide.setHexpand(false);
        hbSide.setShowCloseButton(true);
        hbSide.setTitle("Preferences");

        Box bTitle = new Box(Orientation.HORIZONTAL, 0);
        bTitle.add(hbSide);
        Separator sTitle = new Separator(Orientation.VERTICAL);
        sTitle.getStyleContext().addClass("tilix-title-separator");
        bTitle.add(sTitle);
        bTitle.add(hbMain);

        this.setTitlebar(bTitle);
        this.addOnNotify(delegate(ParamSpec, ObjectG) {
            onDecorationLayout();
        }, "gtk-decoration-layout");
        onDecorationLayout();
    }

    void onRowSelected(ListBoxRow row, ListBox) {
        scope(exit) {updateUI();}
        GenericPreferenceRow gr = cast(GenericPreferenceRow) row;
        if (gr !is null) {
            if (gr.name == "Shortcuts") {
                searchButton.setVisible(true);
            } else {
                searchButton.setVisible(false);
            }
            pages.setVisibleChildName(gr.name);
            hbMain.setTitle(gr.title);
            return;
        }
        ProfilePreferenceRow pr = cast(ProfilePreferenceRow) row;
        if (pr !is null) {
            //pe.bind(pr.getProfile());
            pages.setVisibleChildName("Profile");
            hbMain.setTitle(format("Profile: %s", pr.getProfile().name));
        }
    }

    // Keep track of non-profile rows
    void addNonProfileRow(ListBoxRow row) {
        lbSide.add(row);
        nonProfileRowCount++;
    }

    void onDecorationLayout() {
        import std.array;
        Value layoutValue = new Value("");
        Settings settings = this.getSettings();
        settings.getProperty(GTK_DECORATION_LAYOUT, layoutValue);

        string layout = layoutValue.getString();

        string[] parts = split(layout, ":");
        string part1 = parts[0] ~ ":";
        string part2;

        if (parts.length >= 2)
            part2 = ":" ~ parts[1];

        hbSide.setDecorationLayout(part1);
        hbMain.setDecorationLayout(part2);

        tracef("Decoration layout original: '%s', side: '%s', main: '%s'", layout, part1, part2);
    }

    void updateUI() {
        ProfilePreferenceRow row = cast(ProfilePreferenceRow)lbSide.getSelectedRow();
        if (row !is null) {
            btnDeleteProfile.setSensitive(getProfileRowCount() >= 2);
        } else {
            btnDeleteProfile.setSensitive(false);
        }
    }

    int getProfileRowCount() {
        return lbSide.getChildren().length - nonProfileRowCount;
    }

    void loadProfiles() {
        ProfileInfo[] infos = prfMgr.getProfiles();
        foreach (ProfileInfo info; infos) {
            ProfilePreferenceRow row = new ProfilePreferenceRow(this, info);
            lbSide.add(row);
        }
    }

    void onAddProfile(Button button) {
        ProfileInfo profile = prfMgr.createProfile(SETTINGS_PROFILE_NEW_NAME_VALUE);
        ProfilePreferenceRow row = new ProfilePreferenceRow(this, profile);
        row.showAll();
        lbSide.add(row);
        lbSide.selectRow(row);
        updateUI();
    }

    void onDeleteProfile(Button button) {
        ProfilePreferenceRow row = cast(ProfilePreferenceRow)lbSide.getSelectedRow();
        if (row !is null) {
            deleteProfile(row);
        }
    }

    void deleteProfile(ProfilePreferenceRow row) {
        if (getProfileRowCount() < 2) return;
        if (!showConfirmDialog(this, format(_("Are you sure you want to delete '%s'?"), row.name), gsSettings, SETTINGS_PROMPT_ON_DELETE_PROFILE_KEY)) return;

        string uuid = row.uuid;
        int index = getChildIndex(lbSide, row) - 1;
        lbSide.remove(row);
        prfMgr.deleteProfile(uuid);
        if (index < 0) index = 0;
        lbSide.selectRow(lbSide.getRowAtIndex(index));
        updateUI();
        updateDefaultProfileMarker();
    }

    void cloneProfile(ProfilePreferenceRow sourceRow) {
        ProfileInfo target = prfMgr.cloneProfile(sourceRow.getProfile());
        ProfilePreferenceRow row = new ProfilePreferenceRow(this, target);
        row.showAll();
        lbSide.add(row);
        lbSide.selectRow(row);
        updateUI();
    }

    void setDefaultProfile(ProfilePreferenceRow row) {
        prfMgr.setDefaultProfile(row.getProfile().uuid);
        ProfilePreferenceRow[] rows = dedicatedslave.gui.gtk.util.getChildren!ProfilePreferenceRow(lbSide, false);
        foreach(r; rows) {
            if (r.uuid != row.uuid) {
                r.updateDefault(false);
            }
        }
        row.updateDefault(true);
    }

    void updateDefaultProfileMarker() {
        string uuid = prfMgr.getDefaultProfile();
        ProfilePreferenceRow[] rows = dedicatedslave.gui.gtk.util.getChildren!ProfilePreferenceRow(lbSide, false);
        foreach(r; rows) {
            if (r.uuid != uuid) {
                r.updateDefault(false);
            } else {
                r.updateDefault(true);
            }
        }
    }


public:

    this(GUILoader* loader){
        super(dedicatedslavegui);
        _loader = loader;

        setTitle("Settings Application Window");
        setTypeHint(WindowTypeHint.DIALOG);
        //setTransientFor(window);
        setDestroyWithParent(true);
        setShowMenubar(false);

        gsSettings = new GSettings(SETTINGS_ID);

        createUI();
        updateUI();

        this.addOnDestroy(delegate(Widget) {
            trace("Preference window is destroyed");
            //pe.onProfileNameChanged.disconnect(&profileNameChanged);
            gsSettings.destroy();
            gsSettings = null;
        });
    }
    
}

class GenericPreferenceRow: ListBoxRow {
private:
    string _name;
    string _title;

public:
    this(string name, string title) {
        super();
        _name = name;
        _title = title;

        Label label = new Label(name);
        label.setHalign(Align.START);
        setAllMargins(label, 6);
        add(label);
    }

    @property string name() {
        return _name;
    }

    @property string title() {
        return _title;
    }
}

class ProfilePreferenceRow: ListBoxRow {
private:
    ProfileInfo profile;
    SettingsWindow dialog;

    Label lblName;
    Image imgDefault;

    SimpleActionGroup sag;
    SimpleAction saDefault;

    immutable ACTION_PROFILE_PREFIX = "profile";
    immutable ACTION_PROFILE_DELETE = "delete";
    immutable ACTION_PROFILE_CLONE = "clone";
    immutable ACTION_PROFILE_DEFAULT = "default";

    void createUI() {
        Box box = new Box(Orientation.HORIZONTAL, 0);
        setAllMargins(box, 6);

        lblName = new Label(profile.name);
        lblName.setHalign(Align.START);
        box.packStart(lblName, true, true, 2);

        MenuButton btnMenu = new MenuButton();
        btnMenu.setRelief(ReliefStyle.NONE);
        btnMenu.setFocusOnClick(false);
        btnMenu.setPopover(createPopover(btnMenu));

        box.packEnd(btnMenu, false, false, 0);

        imgDefault = new Image("object-select-symbolic", IconSize.BUTTON);
        imgDefault.setNoShowAll(true);
        box.packEnd(imgDefault, false, false, 0);
        if (isDefault) {
            imgDefault.show();
            saDefault.setEnabled(false);
        }

        add(box);
    }

    void createActions() {
        sag = new SimpleActionGroup();
        registerAction(sag, ACTION_PROFILE_PREFIX, ACTION_PROFILE_DELETE, null, delegate(GVariant, SimpleAction) {
            dialog.deleteProfile(this);
        });
        registerAction(sag, ACTION_PROFILE_PREFIX, ACTION_PROFILE_CLONE, null, delegate(GVariant, SimpleAction) {
            dialog.cloneProfile(this);
        });
        saDefault = registerAction(sag, ACTION_PROFILE_PREFIX, ACTION_PROFILE_DEFAULT, null, delegate(GVariant, SimpleAction) {
            dialog.setDefaultProfile(this);
        });
        insertActionGroup(ACTION_PROFILE_PREFIX, sag);
    }

    Popover createPopover(Widget parent) {
        GMenu model = new GMenu();
        GMenu section = new GMenu();
        section.append("Delete", getActionDetailedName(ACTION_PROFILE_PREFIX, ACTION_PROFILE_DELETE));
        section.append("Clone", getActionDetailedName(ACTION_PROFILE_PREFIX, ACTION_PROFILE_CLONE));
        model.appendSection(null, section);

        section = new GMenu();
        section.append("Use for new terminals", getActionDetailedName(ACTION_PROFILE_PREFIX, ACTION_PROFILE_DEFAULT));
        model.appendSection(null, section);

        Popover popover = new Popover(parent);
        popover.bindModel(model, null);
        return popover;
    }

public:
    this(SettingsWindow dialog, ProfileInfo profile) {
        this.profile = profile;
        this.dialog = dialog;
        createActions();
        createUI();
        addOnDestroy(delegate(Widget) {
            trace("ProfileRow destroyed");
            dialog = null;
            sag.destroy();
        });
    }

    void updateName(string newName) {
        profile.name = newName;
        lblName.setText(newName);
    }

    void updateDefault(bool value) {
        if (profile.isDefault != value) {
            profile.isDefault = value;
            if (value) {
                imgDefault.show();
                saDefault.setEnabled(false);
            } else {
                imgDefault.hide();
                saDefault.setEnabled(true);
            }
        }
    }

    ProfileInfo getProfile() {
        return profile;
    }

    @property string name() {
        return profile.name;
    }

    @property bool isDefault() {
        return profile.isDefault;
    }

    @property string uuid() {
        return profile.uuid;
    }
}


/**
 * Global preferences page *
 */
class GlobalPreferences : Box {

private:

    BindingHelper bh;

    void createUI() {
        setMarginTop(18);
        setMarginBottom(18);
        setMarginLeft(18);
        setMarginRight(18);

        Label lblBehavior = new Label(format("<b>%s</b>", _("Behavior")));
        lblBehavior.setUseMarkup(true);
        lblBehavior.setHalign(Align.START);
        add(lblBehavior);

        //Prompt on new session
        CheckButton cbPrompt = new CheckButton(_("Prompt when creating a new session"));
        bh.bind(SETTINGS_PROMPT_ON_NEW_SESSION_KEY, cbPrompt, "active", GSettingsBindFlags.DEFAULT);
        add(cbPrompt);

        //Focus follows the mouse
        CheckButton cbFocusMouse = new CheckButton(_("Focus a terminal when the mouse moves over it"));
        bh.bind(SETTINGS_TERMINAL_FOCUS_FOLLOWS_MOUSE_KEY, cbFocusMouse, "active", GSettingsBindFlags.DEFAULT);
        add(cbFocusMouse);

        //Auto hide the mouse
        CheckButton cbAutoHideMouse = new CheckButton(_("Autohide the mouse pointer when typing"));
        bh.bind(SETTINGS_AUTO_HIDE_MOUSE_KEY, cbAutoHideMouse, "active", GSettingsBindFlags.DEFAULT);
        add(cbAutoHideMouse);

        //middle click closes the terminal
        CheckButton cbMiddleClickClose = new CheckButton(_("Close terminal by clicking middle mouse button on title"));
        bh.bind(SETTINGS_MIDDLE_CLICK_CLOSE_KEY, cbMiddleClickClose, "active", GSettingsBindFlags.DEFAULT);
        add(cbMiddleClickClose);

        //zoom in/out terminal with scroll wheel
        CheckButton cbControlScrollZoom = new CheckButton(_("Zoom the terminal using <Control> and scroll wheel"));
        bh.bind(SETTINGS_CONTROL_SCROLL_ZOOM_KEY, cbControlScrollZoom, "active", GSettingsBindFlags.DEFAULT);
        add(cbControlScrollZoom);

        //require control modifier when clicking title
        CheckButton cbControlClickTitle = new CheckButton(_("Require the <Control> modifier to edit title on click"));
        bh.bind(SETTINGS_CONTROL_CLICK_TITLE_KEY, cbControlClickTitle, "active", GSettingsBindFlags.DEFAULT);
        add(cbControlClickTitle);

        //Closing of last session closes window
        CheckButton cbCloseWithLastSession = new CheckButton(_("Close window when last session is closed"));
        bh.bind(SETTINGS_CLOSE_WITH_LAST_SESSION_KEY, cbCloseWithLastSession, "active", GSettingsBindFlags.DEFAULT);
        add(cbCloseWithLastSession);

        // Save window state (maximized, minimized, fullscreen) between invocations
        CheckButton cbWindowSaveState = new CheckButton(_("Save and restore window state"));
        bh.bind(SETTINGS_WINDOW_SAVE_STATE_KEY, cbWindowSaveState, "active", GSettingsBindFlags.DEFAULT);
        add(cbWindowSaveState);

        //Show Notifications, only show option if notifications are supported
        // if (checkVTEFeature(TerminalFeature.EVENT_NOTIFICATION)) {
        //     CheckButton cbNotify = new CheckButton(_("Send desktop notification on process complete"));
        //     bh.bind(SETTINGS_NOTIFY_ON_PROCESS_COMPLETE_KEY, cbNotify, "active", GSettingsBindFlags.DEFAULT);
        //     add(cbNotify);
        // }

        //New Instance Options
        Box bNewInstance = new Box(Orientation.HORIZONTAL, 6);

        Label lblNewInstance = new Label(_("On new instance"));
        lblNewInstance.setHalign(Align.END);
        bNewInstance.add(lblNewInstance);
        ComboBox cbNewInstance = createNameValueCombo([_("New Window"), _("New Session"), _("Split Right"), _("Split Down"), _("Focus Window")], SETTINGS_NEW_INSTANCE_MODE_VALUES);
        bh.bind(SETTINGS_NEW_INSTANCE_MODE_KEY, cbNewInstance, "active-id", GSettingsBindFlags.DEFAULT);
        bNewInstance.add(cbNewInstance);
        add(bNewInstance);

        // *********** Clipboard Options
        Label lblClipboard = new Label(format("<b>%s</b>", _("Clipboard")));
        lblClipboard.setUseMarkup(true);
        lblClipboard.setHalign(Align.START);
        add(lblClipboard);

        //Advacned paste is default
        CheckButton cbAdvDefault = new CheckButton(_("Always use advanced paste dialog"));
        bh.bind(SETTINGS_PASTE_ADVANCED_DEFAULT_KEY, cbAdvDefault, "active", GSettingsBindFlags.DEFAULT);
        add(cbAdvDefault);

        //Unsafe Paste Warning
        CheckButton cbUnsafe = new CheckButton(_("Warn when attempting unsafe paste"));
        bh.bind(SETTINGS_UNSAFE_PASTE_ALERT_KEY, cbUnsafe, "active", GSettingsBindFlags.DEFAULT);
        add(cbUnsafe);

        //Strip Paste
        CheckButton cbStrip = new CheckButton(_("Strip first character of paste if comment or variable declaration"));
        bh.bind(SETTINGS_STRIP_FIRST_COMMENT_CHAR_ON_PASTE_KEY, cbStrip, "active", GSettingsBindFlags.DEFAULT);
        add(cbStrip);

        //Copy on Select
        CheckButton cbCopyOnSelect = new CheckButton(_("Automatically copy text to clipboard when selecting"));
        bh.bind(SETTINGS_COPY_ON_SELECT_KEY, cbCopyOnSelect, "active", GSettingsBindFlags.DEFAULT);
        add(cbCopyOnSelect);
    }

public:

    this(GSettings gsSettings) {
        super(Orientation.VERTICAL, 6);
        bh = new BindingHelper(gsSettings);
        createUI();
        addOnDestroy(delegate(Widget) {
            bh.unbind();
            bh = null;
        });
    }
}

/**
 * Global preferences page *
 */
class AdvancedPreferences : Box {
private:
    GSettings gsSettings;

    void createUI() {
        setAllMargins(this, 18);
        Grid grid = new Grid();
        grid.setHalign(Align.FILL);
        grid.setColumnSpacing(12);
        grid.setRowSpacing(6);

        uint row = 0;
        createAdvancedUI(grid, row, &getSettings);

        this.add(grid);
    }

    GSettings getSettings() {
        return gsSettings;
    }

public:

    this(GSettings gsSettings) {
        super(Orientation.VERTICAL, 6);
        this.gsSettings = gsSettings;
        createUI();
    }

}