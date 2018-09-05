module dedicatedslave.gui.loader;

import dedicatedslave.loader;
import gtk.Label;
import gtk.ProgressBar;

class GUILoader : Loader {
	this(ref Label lbl, ref ProgressBar pb)
	{
		this._lbl = lbl;
		this._pb = pb;
		super();
	}

	override void changeLogState(immutable string msg)
	{
		super.changeLogState(msg);
		if(_pb !is null) _pb.pulse();
		if(_lbl !is null) _lbl.setText(msg);
	}

	@property void label(ref Label lbl) { _lbl = lbl;}
	@property void progressBar(ref ProgressBar pb) { _pb = pb;}

private:
	Label _lbl;
	ProgressBar _pb;
}