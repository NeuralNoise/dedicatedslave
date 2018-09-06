module dedicatedslave.gui.loader;

import dedicatedslave.loader;
import gtk.Label;
import gtk.ProgressBar;

class GUILoader : Loader {
	this(void delegate(immutable string) func)
	{
		_func = func;
		super();
	}

	override void changeLogState(immutable string msg)
	{
		super.changeLogState(msg);
		_func(msg);
	}

	final void changeLogCallback(void delegate(immutable string) func)
	{
		_func = func;
	}

private:
	void delegate(immutable string) _func;
}