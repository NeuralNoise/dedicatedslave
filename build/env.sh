envvariable=".venv"

function __cco() {
	if [ -x "/bin/ldc" ] || [ -x "/usr/bin/ldc" ]; then
		export DC=ldc;
	elif [ -x "/bin/dmd" ] || [ -x "/usr/bin/dmd" ]; then
		export DC=dmd;
	fi;
}

function __pdep() {
	dub build gtk-d:gtkd --compiler=$DC;
}

echo "Development commands:"
function __prepare() {
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

function __start() { ./.build/src/gui/dedicatedslave-$@ }
alias s="__start"
echo "s\tStart"
function __startdbg() { gdb ./.build/src/gui/dedicatedslave-$@ }
alias sd="__startdbg"
echo "sd\tStart Debug"

echo "\nQuick commands:"
alias breakfast="__prepare"
echo "breakfast\tPrepare"
function brunch() {
	if [[ $@ == "clear" ]]; then
		__clear all;
	else
		if [[ ! -d ".build" ]];then
			__prepare;
		fi;
		__build $@;
	fi;
}
echo "brunch\t\tEasy prepare & build"