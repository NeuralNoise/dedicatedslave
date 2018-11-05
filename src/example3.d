class CustomSignals
{
    this() {}

    void connect(Widget widget, string signal, bool delegate(Event, Widget) dlg)
    {
        auto wrapper = new Wrapper(widget, dlg);
        Signals.connectData(widget, signal,
                            cast(GCallback)&callback,
                            cast(void*)wrapper,
                            cast(GClosureNotify)&destroyCallback,
                            cast(ConnectFlags)0
                            );
    }

protected:
    class Wrapper
    {
        Widget widget;
        bool delegate(Event, Widget) dlg;

        this(Widget widget, bool delegate(Event, Widget) dlg)
        {
            this.widget = widget;
            this.dlg = dlg;
            wrappers ~= this;
        }

        bool opCall(Event e) { return dlg(e, widget); }

        void selfRemove()
        {
            import std.algorithm : filter;
            import std.array : array;
            wrappers = wrappers.filter!(a => this !is a).array;
        }
    }

    Wrapper[] wrappers;

    extern(C) static int callback(void* widgetStruct, GdkEvent* event, Wrapper wrapper)
    { return wrapper(ObjectG.getDObject!Event(event)); }

    extern(C) static void destroyCallback(Wrapper wrapper, void* closure)
    { wrapper.selfRemove(); }
}