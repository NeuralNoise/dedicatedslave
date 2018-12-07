module dedicatedslave.gui.app;

import core.sys.windows.windows;

import gio.Application : GioApplication = Application;
import gtkc.giotypes : GApplicationFlags;
import gtk.Application;
import dedicatedslave.gui.splashwindow;
import dedicatedslave.gui.appwindow;
import dedicatedslave.gui.loader;


int WinMain(HINSTANCE hInstance, HINSTANCE hPrevInstance, char*, int nShowCmd)
{
	return main( ["a", "b"] );
}

int main(string[] args)
{
	auto application = new Application("enthdev.dedicatedslave.gui", GApplicationFlags.FLAGS_NONE);
	
	application.addOnActivate(delegate void(GioApplication app){
		SplashAppWindow splash_win = new SplashAppWindow(application);
		MainAppWindow mainWindow = new MainAppWindow(application, splash_win.loader);
	});
	return application.run(args);
}