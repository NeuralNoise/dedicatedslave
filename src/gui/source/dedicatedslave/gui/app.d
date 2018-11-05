module dedicatedslave.gui.app;

import gio.Application : GioApplication = Application;
import gtk.Application;
import dedicatedslave.gui.splash;
import dedicatedslave.gui.mainwindow;
import dedicatedslave.gui.loader;

int main(string[] args)
{
	auto application = new Application("enthdev.dedicatedslave.gui", GApplicationFlags.FLAGS_NONE);
	SplashAppWindow splash_win;
	//GUILoader loader = new GUILoader((immutable string msg){
	//});
	application.addOnActivate(delegate void(GioApplication app){
		splash_win = new SplashAppWindow(application);
		MainAppWindow mainWindow = new MainAppWindow(application, splash_win.loader);
	});
	return application.run(args);
}