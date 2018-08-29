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
	__clear; __cco; __pdep; meson $@ . .build
}
alias p="__prepare"
echo "p\tPrepare"

function __clear() {
	__build clean;
	if [[ $@ == "all" ]]; then
		rm -rf .build .dub .dedicatedslave ._dedicatedslave;
	fi;
}
alias c="__clear"
echo "c\tClear"

function __build() {
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
	if [[ ! -d ".build" ]];then
		__prepare;
	fi;
	__build $@;
}
echo "brunch\t\tEasy prepare & build"