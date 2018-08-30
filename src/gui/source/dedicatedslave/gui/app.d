module dedicatedslave.gui.app;

import gio.Application : GioApplication = Application;
import gtk.Application;
import dedicatedslave.gui.splash;
import dedicatedslave.gui.mainwindow;

int main(string[] args)
{
	auto application = new Application("enthdev.dedicatedslave.gui", GApplicationFlags.FLAGS_NONE);
	SplashWindow splash_win;
	application.addOnActivate(delegate void(GioApplication app) {
			splash_win = new SplashWindow(application);
			new MainWindow(application, splash_win.loader);
		});
	return application.run(args);
}