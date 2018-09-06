module dedicatedslave.gui.splash;

import gtk.Image;
import gtk.Application;
import gtk.ApplicationWindow;
import gtk.ProgressBar;
import gtk.Box;
import gtk.Label;
import gtk.Main;
import gdk.RGBA;
import glib.Timeout;
import std.stdio;
import core.time;
import core.thread;
import dedicatedslave.gui.loader;

class SplashWindow : ApplicationWindow {
	this(Application application)
	{
		super(application);

		setTitle("DedicatedSlave");
		setTypeHint(GdkWindowTypeHint.SPLASHSCREEN);
		setSkipTaskbarHint(true);
		setSkipPagerHint(true);
		overrideBackgroundColor(GtkStateFlags.NORMAL, new RGBA(1.0, 1.0,1.0));
		setBorderWidth(10);
		setDecorated(false);
		setPosition(GtkWindowPosition.CENTER_ALWAYS);
		setResizable(false);

		Box box = new Box(GtkOrientation.VERTICAL, 0);
		box.setCenterWidget(new Image("assets/logo.svg"));
		ProgressBar pb = new ProgressBar();
		Label statusLbl = new Label("Loading...");
		statusLbl.overrideColor(GtkStateFlags.NORMAL, new RGBA(0.0, 0.0, 0.0));
		box.packEnd(statusLbl, true, true, 0);
		box.packEnd(pb, true, true, 10);
		pb.pulse();
		add(box);

		showAll();

		Duration timeElapsed;
		Thread _t = new Thread({
			MonoTime timeBefore = MonoTime.currTime;
			loader = new GUILoader((immutable string msg){
				if(pb !is null) pb.pulse();
				if(statusLbl !is null) statusLbl.setText(msg);
			});
			MonoTime timeAfter = MonoTime.currTime;
			timeElapsed = timeAfter - timeBefore;
		}).start;

		while(_t.isRunning)
			if(Main.eventsPending) Main.iteration;

		if(timeElapsed.total!"msecs" >= 1000)
			destroy();

		new Timeout(
			cast(uint)(1000 - timeElapsed.total!"msecs"),
			{
				destroy();
				return false;
			});
	}

	GUILoader loader;
}
