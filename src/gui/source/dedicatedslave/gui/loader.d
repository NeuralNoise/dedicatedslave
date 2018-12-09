module dedicatedslave.gui.loader;

import dedicatedslave.loader;
import gtk.Label;
import gtk.ProgressBar;

class GUILoader : Loader {
	this(void delegate(immutable string) func)
	{
		_func[0] = func;
		super();
	}

	override void changeLogState(immutable string msg, int index)
	{
		super.changeLogState(msg, index);
		_func[index](msg);
	}

	final void changeLogCallback(void delegate(immutable string) func, int index)
	{
		_func[index] = func;
	}

private:
	void delegate(immutable string)[32] _func;
}