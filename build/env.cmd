@echo off
REM https://stackoverflow.com/questions/18742150/how-to-package-all-my-functions-in-a-batch-file-as-a-seperate-file/18743342#18743342
echo ----------------------------
echo        dedicatedslave
echo ----------------------------
echo.
echo Usage:   call SCRIPTNAME :FUNCTION PARAM1 PARAM2
echo Example: call script.cmd :help
echo.

set virtualenvname=.venv

goto %1

:help
REM code here - recursion and subroutines will complicate the library
REM use random names for any temp files, and check if they are in use - else pick a different random name
echo == HELP ==
echo Usage:   call SCRIPTNAME COMMAND
echo Example: call script.cmd help
echo.
echo == REPO ==
echo db    - Build
echo dbf   - Build (Force)
echo ds    - Start
echo dd    - Documentation Build (Doxygen + PlantUML)
echo ddd   - Diagram Build (PlantUML)
echo check - Check Deps
goto :eof

:db
echo executing :db
echo arg1 = %1
::dub build archive --compiler=ldc2
::dub build gtk-d:gtkd --compiler=ldc2
::dub build d2sqlite3 --compiler=ldc2
dub build --build debug --compiler=ldc2
dub build :gui --build debug --compiler=ldc2
goto :eof

:dbf
echo executing :dbf
echo arg1 = %1
echo arg2 = %2
dub build archive --force --compiler=ldc2
dub build gtk-d:gtkd --force --compiler=ldc2
dub build gtk-d:gstreamer --force --compiler=ldc2
dub build --force --compiler=ldc2
dub build :gui --force --compiler=ldc2
goto :eof

:ds
echo executing :ds
echo arg1 = %1
echo arg2 = %2
echo arg3 = %3
start "" "src\gui\.out\bin\dedicatedslave-gui.exe"
goto :eof

:dd
echo executing :dd
echo arg1 = %1
echo arg2 = %2
echo arg3 = %3
doxygen
goto :ddd
goto :eof

:ddd
echo executing :ddd
echo arg1 = %1
echo arg2 = %2
echo arg3 = %3
plantuml -tpng -o output docs/diagrams/*
plantuml -tsvg -o output docs/diagrams/*
goto :eof

:check
echo executing :check
echo arg1 = %1
echo arg2 = %2
echo arg3 = %3
dub list
copy /Y src\gui\data\gsettings\com.enthdev.DedicatedSlave.gschema.xml "C:\Program Files\Gtk-Runtime\share\glib-2.0\schemas"
glib-compile-schemas "C:\Program Files\Gtk-Runtime\share\glib-2.0\schemas"
gsettings list-schemas
gsettings list-relocatable-schemas
dub --version
doxygen --version
gsettings --version
goto :eof