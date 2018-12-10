module dedicatedslave.gui.actions;

import std.experimental.logger;
import std.string;

import gio.ActionMapIF;
import gio.SimpleAction;
import gio.Settings : GSettings = Settings;

import glib.Variant: GVariant = Variant;
import glib.VariantType: GVariantType = VariantType;

import gtk.AccelGroup;
import gtk.Application;
import gtk.ApplicationWindow;

private Application app = null;

/**
 * Given an action prefix and id returns the detailed name
 */
string getActionDetailedName(string prefix, string id) {
    return prefix ~ "." ~ id;
}

/**
    * Adds a new action to the specified menu. An action is automatically added to the application that invokes the
    * specified callback when the actual menu item is activated.
    *
    * This code from grestful (https://github.com/Gert-dev/grestful)
    *
    * Params:
    * actionMap =            The map that is holding the action
    * prefix =               The prefix part of the action name that comes before the ".", i.e. "app" for GtkApplication, etc
    * id =                   The ID to give to the action. This can be used in other places to refer to the action
    *                             by a string. Must always start with "app.".
    * accelerator =          The (application wide) keyboard accelerator to activate the action.
    * callback =             The callback to invoke when the action is invoked.
    * parameterType =        The type of data passed as parameter to the action when activated.
    * state =                The state of the action, creates a stateful action
    *
    * Returns: The registered action.
    */
SimpleAction registerAction(ActionMapIF actionMap, string prefix, string id, string[] accelerators = null, void delegate(GVariant,
        SimpleAction) cbActivate = null, GVariantType parameterType = null, GVariant state = null, void delegate(GVariant,
        SimpleAction) cbStateChange = null) {
    SimpleAction action;
    if (state is null)
        action = new SimpleAction(id, parameterType);
    else {
        action = new SimpleAction(id, parameterType, state);
    }

    if (cbActivate !is null)
        action.addOnActivate(cbActivate);

    if (cbStateChange !is null)
        action.addOnChangeState(cbStateChange);

    actionMap.addAction(action);

    if (accelerators.length > 0) {
        if (app is null) {
            app = cast(Application) Application.getDefault();
        }
        if (app !is null) {
            app.setAccelsForAction(prefix.length == 0 ? id : getActionDetailedName(prefix, id), accelerators);
        } else {
            errorf("Accelerator for action %s could not be registered", id);
        }
    }
    return action;
}