module dedicatedslave.gui.menubar;

import gtk.Menu;
import gtk.MenuItem;
import gtk.SeparatorMenuItem;

import dedicatedslave.gui.mainwindow;
import dedicatedslave.gui.loader;

class MainMenu : MenuBar
{
    this(MainWindow parent, AccelGroup accelGroup, ref GUILoader loader)
    {
        super();
        _parent = parent;
        _loader = &loader;
        this.append(new FileMenuItem(accelGroup));
        this.append(new EditMenuItem());
        this.append(new ViewMenuItem());
        this.append(new HelpMenuItem(accelGroup));
    }

    class FileMenuItem : MenuItem
    {
        this(AccelGroup accelGroup)
        {
            super("File");
            _menu = new Menu();

            _menuItem_settings = new MenuItem(&MainWindow.onMenuActivate,"_Settings","file.settings", true, accelGroup, 'a', GdkModifierType.CONTROL_MASK|GdkModifierType.SHIFT_MASK);
            _menuItem_exit = new MenuItem("Exit");
            _menuItem_exit.addOnButtonRelease(&exit);

            _menu.append(_menuItem_settings);
            _menu.append(new SeparatorMenuItem());
            _menu.append(_menuItem_exit);

            setSubmenu(_menu);
        }
        bool exit(Event event, Widget widget)
        {
            Main.quit();
            return true;
        }
    private:
        Menu _menu;
        MenuItem _menuItem_settings;
        MenuItem _menuItem_exit;

    }

    class EditMenuItem : MenuItem
    {
        this()
        {
            super("Edit");
            _menu = new Menu();
            setSubmenu(_menu);
        }
    private:
        Menu _menu;
        MenuItem _menuItem;
    }

    class ViewMenuItem : MenuItem
    {
        this()
        {
            super("View");
            _menu = new Menu();
            setSubmenu(_menu);
        }
    private:
        Menu _menu;
        MenuItem _menuItem;
    }

    class HelpMenuItem : MenuItem
    {
        this(AccelGroup accelGroup)
        {
            super("Help");
            _menu = new Menu();

            _menuItem_welcome = new MenuItem(&MainWindow.onMenuActivate,"_Welcome","help.welcome", true, accelGroup, 'a', GdkModifierType.CONTROL_MASK|GdkModifierType.SHIFT_MASK);
            _menuItem_documentation = new MenuItem(&MainWindow.onMenuActivate,"_Documentation","help.documentation", true, accelGroup, 'a', GdkModifierType.CONTROL_MASK|GdkModifierType.SHIFT_MASK);
            _menuItem_releasenotes = new MenuItem(&MainWindow.onMenuActivate,"_Release Notes","help.releasenotes", true, accelGroup, 'a', GdkModifierType.CONTROL_MASK|GdkModifierType.SHIFT_MASK);
            _menuItem_discord = new MenuItem(&MainWindow.onMenuActivate,"_Join us on Discord","help.discord", true, accelGroup, 'a', GdkModifierType.CONTROL_MASK|GdkModifierType.SHIFT_MASK);
            _menuItem_issue = new MenuItem(&MainWindow.onMenuActivate,"_Report Issue","help.issue", true, accelGroup, 'a', GdkModifierType.CONTROL_MASK|GdkModifierType.SHIFT_MASK);
            _menuItem_license = new MenuItem(&MainWindow.onMenuActivate,"_License","help.license", true, accelGroup, 'a', GdkModifierType.CONTROL_MASK|GdkModifierType.SHIFT_MASK);
            _menuItem_about = new MenuItem(&MainWindow.onMenuActivate,"_About","help.about", true, accelGroup, 'a', GdkModifierType.CONTROL_MASK|GdkModifierType.SHIFT_MASK);
            
            _menu.append(_menuItem_welcome);
            _menu.append(_menuItem_documentation);
            _menu.append(_menuItem_releasenotes);
            _menu.append(new SeparatorMenuItem());
            _menu.append(_menuItem_discord);
            _menu.append(_menuItem_issue);
            _menu.append(new SeparatorMenuItem());
            _menu.append(_menuItem_license);
            _menu.append(new SeparatorMenuItem());
            _menu.append(_menuItem_about);
            
            setSubmenu(_menu);
        }
    private:
        Menu _menu;
        MenuItem _menuItem_welcome;
        MenuItem _menuItem_documentation;
        MenuItem _menuItem_releasenotes;
        MenuItem _menuItem_discord;
        MenuItem _menuItem_issue;
        MenuItem _menuItem_license;
        MenuItem _menuItem_about;
    }
private:
    GUILoader* _loader;
    MainWindow _parent;
}