module dedicatedslave.gui.app;

import std.algorithm;
import std.conv;
import std.experimental.logger;
import std.file;
import std.format;
import std.path;
import std.process;
import std.stdio;
import std.variant;

import cairo.ImageSurface;

import gdk.Screen;

import gdkpixbuf.Pixbuf;

import gio.ActionGroupIF;
import gio.ActionMapIF;
import gio.Application : GApplication = Application;
import gio.ApplicationCommandLine;
import gio.Menu;
import gio.MenuModel;
import gio.Settings : GSettings = Settings;
import gio.SimpleAction;

import glib.GException;
import glib.ListG;
import glib.Str;
import glib.Variant : GVariant = Variant;
import glib.VariantDict : GVariantDict = VariantDict;
import glib.VariantType : GVariantType = VariantType;

import gobject.ObjectG;
import gobject.ParamSpec;
import gobject.Value;

import gtkc.gtk;

import gtk.AboutDialog;
import gtk.Application;
import gtk.CheckButton;
import gtk.CssProvider;
import gtk.Dialog;
import gtk.Image;
import gtk.Label;
import gtk.LinkButton;
import gtk.Main;
import gtk.MessageDialog;
import gtk.Settings;
import gtk.StyleContext;
import gtk.Version;
import gtk.Widget;
import gtk.Window;

import dedicatedslave.gui.preferences;
import dedicatedslave.gui.appwindow;
import dedicatedslave.gui.constants;
import dedicatedslave.gui.loader;

import dedicatedslave.gui.i18n.l10n;

import dedicatedslave.gui.splashwindow;

static import dedicatedslave.gui.util.array;

DedicatedSlave dedicatedslavegui;

class DedicatedSlave : Application {

private:

    bool useTabs = false;

    void onAppActivate(GApplication app) {
        trace("Activate App Signal");
        if (!app.getIsRemote()) {
        //    if (cp.preferences) presentPreferences();
        //    else createAppWindow();
           createAppWindow();
        }
        //cp.clear();
    }
    
    void createAppWindow() {
        //MainAppWindow window = new MainAppWindow(this, useTabs);
        SplashAppWindow splash_win = new SplashAppWindow(this);
		MainAppWindow mainWindow = new MainAppWindow(this, splash_win.loader);
        // Window was being realized here to support inserting Window ID
        // into terminal but had lot's of other issues with it so commented
        // it out.
        //mainWindow.realize();
        //mainWindow.initialize();
        mainWindow.showAll();
    }

    void onAppStartup(GApplication) {
        trace("Startup App Signal");
        //Settings.getDefault.addOnNotify(&handleThemeChange, "gtk-theme-name", ConnectFlags.AFTER);
        //loadResources();
        //gsShortcuts = new GSettings(SETTINGS_KEY_BINDINGS_ID);
        //gsShortcuts.addOnChanged(delegate(string key, Settings) {
        //    string actionName = keyToDetailedActionName(key);
            //trace("Updating shortcut '" ~ actionName ~ "' to '" ~ gsShortcuts.getString(key) ~ "'");
        //    setShortcut(actionName, gsShortcuts.getString(key));
        //});
        //gsGeneral = new GSettings(SETTINGS_ID);
        // Set this once globally because it affects more then current window (i.e. shortcuts)
        //useTabs = gsGeneral.getBoolean(SETTINGS_USE_TABS_KEY);
        //_processMonitor = gsGeneral.getBoolean(SETTINGS_PROCESS_MONITOR);
        //gsGeneral.addOnChanged(delegate(string key, Settings) {
        //    applyPreference(key);
        //});
        
        initProfileManager();
        //initBookmarkManager();
        //bmMgr.load();
        //applyPreferences();
        //installAppMenu();
        //loadProfileShortcuts();
    }

    void onAppShutdown(GApplication) {
        trace("Quit App Signal");
        //if (bmMgr.hasChanged()) {
        //    bmMgr.save();
        //}
        dedicatedslavegui = null;
    }

    int onCommandLine(Scoped!ApplicationCommandLine acl, GApplication) {
        trace("App processing command line");
        
        return 0;
    }

public:

    this(bool newProcess, string group=null)
    {
        // ApplicationFlags flags = ApplicationFlags.HANDLES_COMMAND_LINE;
        // if (newProcess) flags |= ApplicationFlags.NON_UNIQUE;
        GApplicationFlags flags = GApplicationFlags.HANDLES_COMMAND_LINE;
        if (newProcess) flags |= GApplicationFlags.NON_UNIQUE;
        //flags |= ApplicationFlags.CAN_OVERRIDE_APP_ID;
        super(APPLICATION_ID, GApplicationFlags.FLAGS_NONE);

        if (group.length > 0) {
            string id = "com.gexperts.Tilix." ~ group;
            if (idIsValid(id)) {
                tracef("Setting app id to %s", id);
                setApplicationId(id);
            } else {
                warningf(_("The application ID %s is not valid"));
            }
        }

        this.addOnActivate(&onAppActivate);
        this.addOnStartup(&onAppStartup);
        this.addOnShutdown(&onAppShutdown);
        this.addOnCommandLine(&onCommandLine);

        dedicatedslavegui = this;
    }

}