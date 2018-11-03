envvariable=".venv"

#function i() { virtualenv --python=python3 "${envvariable}"; source ./${envvariable}/bin/activate; pip install -r requirements.txt; deactivate; }
#function b() { source ./${envvariable}/bin/activate; meson; deactivate; }
#function b() { dub build; dub build :gui; dub build :cli; }
function b() {
    #dub build archive --compiler=ldc2
    dub build archive;
    dub build gtk-d:gtkd;
    dub build d2sqlite3;
    dub build;
    dub build :gui;
    }
function bf() { dub build --force; dub build :gui --force;}
function s() { src/gui/.out/bin/dedicatedslave-gui }

echo "Help:"
#echo "‘i’ - Install"
echo "‘b’ - Build"
echo "‘bf’ - Build (Force)"
echo "‘s’ - Start"