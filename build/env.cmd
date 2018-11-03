@echo off
title %~n0.%~x0
cls

set sshpublickey=E:\ProgramFiles\Dropbox\_backup\credentials\rsa\alexpc_win\id_rsa.ppk
set sshprivatekey=E:\ProgramFiles\Dropbox\_backup\credentials\rsa\alexpc_linux\id_rsa.ppk

set errlvl=%ERRORLEVEL%
if "%~1" neq "" (
  2>nul >nul findstr /rc:"^ *:%~1\>" "%~f0" && (
    shift /1
    goto %1
  ) || (
    >&2 echo ERROR: routine %~1 not found. Usage: call scriptfile.cmd help
  )
) else >&2 echo ERROR: missing routine. Usage: call scriptfile.cmd help
exit /b

:help
echo == HELP ==
echo Usage:   call SCRIPTNAME COMMAND
echo Example: call script.cmd help
echo.
echo == REPO ==
echo db   - Build
echo dbf  - Build (Force)
echo ds   - Start
exit /b

:db
echo executing :db
echo arg1 = %1
::dub build archive --compiler=ldc2
::dub build gtk-d:gtkd --compiler=ldc2
::dub build d2sqlite3 --compiler=ldc2
dub build --compiler=ldc2
dub build :gui --compiler=ldc2
exit /b

:dbf
echo executing :dbf
echo arg1 = %1
echo arg2 = %2
dub build archive --force --compiler=ldc2
dub build gtk-d:gtkd --force --compiler=ldc2
dub build --force --compiler=ldc2
dub build :gui --force --compiler=ldc2
exit /b

:ds
echo executing :ds
echo arg1 = %1
echo arg2 = %2
echo arg3 = %3
start "" "src\gui\.out\bin\dedicatedslave-gui.exe"
exit /b %errlvl%