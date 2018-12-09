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
echo dd    - Documentation Build (Doxygen)
echo check - Check Deps
goto :eof

:db
echo executing :db
echo arg1 = %1
::dub build archive --compiler=ldc2
::dub build gtk-d:gtkd --compiler=ldc2
::dub build d2sqlite3 --compiler=ldc2
dub build --compiler=ldc2
dub build :gui --compiler=ldc2
goto :eof

:dbf
echo executing :dbf
echo arg1 = %1
echo arg2 = %2
dub build archive --force --compiler=ldc2
dub build gtk-d:gtkd --force --compiler=ldc2
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
goto :eof

:check
echo executing :check
echo arg1 = %1
echo arg2 = %2
echo arg3 = %3
dub --version
doxygen --version
gsettings --version
goto :eof