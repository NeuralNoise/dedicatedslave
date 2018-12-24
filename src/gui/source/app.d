import core.sys.windows.windows;

import std.stdio;

import std.array;
import std.experimental.logger;
import std.file;
import std.format;
import std.process;
import std.string;

import glib.FileUtils;
import glib.Util;
import gtk.Main;
import gtk.Version;
import gtk.MessageDialog;


import dedicatedslave.gui.app;
import dedicatedslave.gui.splashwindow;
import dedicatedslave.gui.appwindow;
import dedicatedslave.gui.loader;
import dedicatedslave.gui.i18n.l10n;
import dedicatedslave.gui.constants;

version(windows){
    int WinMain(HINSTANCE hInstance, HINSTANCE hPrevInstance, char*, int nShowCmd){
        return main( ["a", "b"] );
    }
}

int main(string[] args)
{
    bool newProcess = false;
    string group;

   
	string cwd = Util.getCurrentDir();
    string pwd;
    string de;
	trace("CWD = " ~ cwd);
	// try {
    //     pwd = environment["PWD"];
    //     de = environment["XDG_CURRENT_DESKTOP"];
    //     trace("PWD = " ~ pwd);
    // } catch (Exception e) {
    //     trace("No PWD environment variable found");
    // }
	// try {
    //     environment.remove("WINDOWID");
    // } catch (Exception e) {
    //     error("Unexpected error occurred", e);
    // }

	string uhd = Util.getHomeDir();
    trace("UHD = " ~ uhd);
	
    //Debug args
    foreach(i, arg; args) {
        tracef("args[%d]=%s", i, arg);
    }

	//textdomain
    textdomain(TILIX_DOMAIN);
    // Init GTK early so localization is available
    // Note used to pass empty args but was interfering with GTK default args
    Main.init(args);

	trace(format("Starting tilix with %d arguments...", args.length));
    foreach(i, arg; args) {
        trace(format("arg[%d] = %s",i, arg));
        // Workaround issue with Unity and older Gnome Shell when DBusActivatable sometimes CWD is set to /, see #285
        if (arg == "--gapplication-service" && pwd == uhd && cwd == "/") {
            info("Detecting DBusActivatable with improper directory, correcting by setting CWD to PWD");
            infof("CWD = %s", cwd);
            infof("PWD = %s", pwd);
            cwd = pwd;
            FileUtils.chdir(cwd);
        } else if (arg == "--new-process") {
            newProcess = true;
        } else if (arg == "-g") {
            group = args[i+1];
        } else if (arg.startsWith("--group")) {
            group = arg[8..$];
        } else if (arg == "-v" || arg == "--version") {
            outputVersions();
            return 0;
        }
    }
    //append TILIX_ID to args if present
    // try {
    //    string terminalUUID = environment["TILIX_ID"];
    //    trace("Inserting terminal UUID " ~ terminalUUID);
    //    args ~= ("--" ~ CMD_TERMINAL_UUID ~ "=" ~ terminalUUID);
    // }
    // catch (Exception e) {
    //    trace("No tilix UUID found");
    // }

	//Version checking cribbed from grestful, thanks!
    string gtkError = Version.checkVersion(GTK_VERSION_MAJOR, GTK_VERSION_MINOR, GTK_VERSION_PATCH);
    if (gtkError !is null) {
        MessageDialog dialog = new MessageDialog(null, DialogFlags.MODAL, MessageType.ERROR, ButtonsType.OK,
                format(_("Your GTK version is too old, you need at least GTK %d.%d.%d!"), GTK_VERSION_MAJOR, GTK_VERSION_MINOR, GTK_VERSION_PATCH), null);

        dialog.setDefaultResponse(ResponseType.OK);

        dialog.run();
        return 1;
    }

	trace("Creating app");
	//auto application = new Application("enthdev.dedicatedslave.gui", GApplicationFlags.FLAGS_NONE);
	auto dedicatedslaveApp = new DedicatedSlave(newProcess, group);
	
	// dedicatedslaveApp.addOnActivate(delegate void(GioApplication app){
	// 	SplashAppWindow splash_win = new SplashAppWindow(dedicatedslaveApp);
	// 	MainAppWindow mainWindow = new MainAppWindow(dedicatedslaveApp, splash_win.loader);
	// });

	int result;
	try {
        trace("Running application...");
        result = dedicatedslaveApp.run(args);
        trace("App completed...");
    }
    catch (Exception e) {
		error(_("Unexpected exception occurred"));
        error(_("Error: ") ~ e.msg);
    }
	return result;
}

private:

	void outputVersions()
    {
        //import gx.gtk.vte: getVTEVersion, checkVTEFeature, TerminalFeature, isVTEBackgroundDrawEnabled;
        import gtk.Version: Version;

        writeln(_("Versions"));
        writeln("\t" ~ format(_("Tilix version: %s"), APPLICATION_VERSION));
        //writeln("\t" ~ format(_("VTE version: %s"), getVTEVersion()));
        writeln("\t" ~ format(_("GTK Version: %d.%d.%d") ~ "\n", Version.getMajorVersion(), Version.getMinorVersion(), Version.getMicroVersion()));
        //writeln(_("Tilix Special Features"));
        //writeln("\t" ~ format(_("Notifications enabled=%b"), checkVTEFeature(TerminalFeature.EVENT_NOTIFICATION)));
        //writeln("\t" ~ format(_("Triggers enabled=%b"), checkVTEFeature(TerminalFeature.EVENT_SCREEN_CHANGED)));
        //writeln("\t" ~ format(_("Badges enabled=%b"), isVTEBackgroundDrawEnabled));
    }