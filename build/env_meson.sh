#set -e

function __avirtualenv()
{
	virtualenv --python=python3 ".venv";
	source .venv/bin/activate;
}
if [[ -z "$VIRTUAL_ENV" ]]; then; __avirtualenv; fi;

function __cco() {
	if output=$(where ldc); then
		export DC=$((printf '%s\n' "$output") | sed -n 1p);
	elif output=$(where dmd); then
		export DC=$((printf '%s\n' "$output") | sed -n 1p);
	elif output=$(where gdc); then
		export DC=$((printf '%s\n' "$output") | sed -n 1p);
	else
		(>&2 echo "error: no compiler detected!")
	fi;
}

function __pdep() {
	dub build gtk-d:gtkd --compiler=$DC;
}

echo "\nDevelopment commands:"
function __prepare() {
	if where meson > /dev/null; then;
		if [[ -z "$VIRTUAL_ENV" ]]; then; __avirtualenv; fi;
		mkdir -p .tmp; pushd .tmp;
		wget "https://github.com/mesonbuild/meson/archive/master.zip";
		mkdir -p meson;
		unzip master.zip;
		rm -rf master.zip;
		pushd meson-master;
		python3 setup.py install;
		popd; popd;
	fi;
	__cco; __pdep; meson $@ . .build
}
alias p="__prepare"
echo "p\tPrepare"

function __clear() {
	if [[ $@ == "all" ]]; then
		rm -rf .build .dub;
	elif [[ $@ == "appcache" ]]; then
		rm -rf .dedicatedslave ._dedicatedslave;
	else
		__build clean;
	fi;
}
alias c="__clear"
echo "c\tClear"

function __build() {
	if [[ ! -d ".build" ]]; then
		(>&2 echo "error: no .build folder")
	fi;
	if [[ $@ == "force" ]]; then
		pushd .build;
			ninja clean;
			ninja
		popd;
	else
		pushd .build; ninja $@; popd;
	fi;
}
alias b="__build"
echo "b\tBuild"

function __install() { __build install; }
alias i="__install"
echo "i\tInstall"

function __uninstall_env() {
	source ./${envvariable}/bin/activate;
	pip uninstall -r requirements.txt -y;
	deactivate;
}

function __start() { ./.build/src/gui/dedicatedslave-$@ }
alias s="__start"
echo "s\tStart"
function __startdbg() { gdb ./.build/src/gui/dedicatedslave-$@ }
alias sd="__startdbg"
echo "sd\tStart Debug"

echo "\nQuick commands:"
alias breakfast="__prepare"
echo "breakfast\tPrepare"

function lunch() {
	if [[ $@ == "clear" ]]; then
		__clear all;
	else
		if [[ ! -d ".build" ]];then
			__prepare;
		fi;
		__build $@;
	fi;
}
echo "lunch\t\tEasy prepare & build"

alias brunch="breakfast; lunch"