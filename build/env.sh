envvariable=".venv"

#function i() { virtualenv --python=python3 "${envvariable}"; source ./${envvariable}/bin/activate; pip install -r requirements.txt; deactivate; }
#function b() { source ./${envvariable}/bin/activate; meson; deactivate; }
#function b() { dub build; dub build :gui; dub build :cli; }
function b() {
    sudo cp src/gui/data/gsettings/com.enthdev.DedicatedSlave.gschema.xml /usr/share/glib-2.0/schemas/;
    sudo glib-compile-schemas /usr/share/glib-2.0/schemas;
    #dub build archive --compiler=ldc2
    dub build archive;
    dub build gtk-d:gtkd;
    dub build d2sqlite3;
    dub build;
    dub build :gui;
}
function bf() { 
    dub build --force;
    dub build :gui --force;
}
function clean(){
    rm -rf src/gui/.out
}
function s(){
    src/gui/.out/bin/dedicatedslave-gui
}
function check(){
    gsettings list-schemas | grep com.enthdev.DedicatedSlave;
    gsettings list-relocatable-schemas | grep com.enthdev.DedicatedSlave;
    find /usr/lib | grep libsqlite3;
    ldd src/gui/.out/bin/dedicatedslave-gui;
}

echo "Help:"
#echo "‘i’ - Install"
echo "‘clean’ - Clean"
echo "‘check’ - Check"
echo "‘b’ - Build"
echo "‘bf’ - Build (Force)"
echo "‘s’ - Start"