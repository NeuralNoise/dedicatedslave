module dedicatedslave.gui.constants;

import std.path;

import dedicatedslave.gui.i18n.l10n;

/**************************************
 * Application Constants
 **************************************/

// GTK Version required
enum GTK_VERSION_MAJOR = 3;
enum GTK_VERSION_MINOR = 18;
enum GTK_VERSION_PATCH = 0;

// GTK version required for scrolledwindow
enum GTK_SCROLLEDWINDOW_VERSION = 22;

// GetText Domain
enum TILIX_DOMAIN = "tilix";

/**
 * Application ID
 */
enum APPLICATION_ID = "com.enthdev.DedicatedSlave";

// Application values used in About Dialog
enum APPLICATION_NAME = "Tilix";
enum APPLICATION_VERSION = "1.8.6-0.2.0";
enum APPLICATION_AUTHOR = "Gerald Nunn";
enum APPLICATION_COPYRIGHT = "Copyright \xc2\xa9 2017 " ~ APPLICATION_AUTHOR;
enum APPLICATION_COMMENTS = N_("A VTE based terminal emulator for Linux");
enum APPLICATION_LICENSE = N_("This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0. If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.");
enum APPLICATION_ICON_NAME = "com.enthdev.Tilix";

immutable string[] APPLICATION_AUTHORS = [APPLICATION_AUTHOR];
string[] APPLICATION_CREDITS = [
    N_("GTK VTE widget team, Tilix would not be possible without their work"),
    N_("GtkD for providing such an excellent GTK wrapper"),
    N_("Dlang.org for such an excellent language, D")
];
immutable string[] APPLICATION_ARTISTS = [];
immutable string[] APPLICATION_DOCUMENTERS = [];

//GTK Settings
enum GTK_APP_PREFER_DARK_THEME = "gtk-application-prefer-dark-theme";
enum GTK_MENU_BAR_ACCEL = "gtk-menu-bar-accel";
enum GTK_ENABLE_ACCELS = "gtk-enable-accels";
enum GTK_DECORATION_LAYOUT = "gtk_decoration_layout";
enum GTK_SHELL_SHOWS_APP_MENU = "gtk-shell-shows-app-menu";
enum GTK_DOUBLE_CLICK_TIME = "gtk-double-click-time";
