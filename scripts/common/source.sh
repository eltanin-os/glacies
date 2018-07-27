#!/bin/sh

REPOSITORY=""

# Libraries (ports)
LENV=`cat <<-EOF
	devel/libz
	devel/ncurses
EOF
`

# Packages (ports)
PENV=`cat <<-EOF
	shells/mksh
	sysutils/cbase
	sysutils/mandoc
	sysutils/utilchest
EOF
`

# Packages (non-ports)
TENV=`cat <<-EOF
	git://github.com/eltanin-os/lux
	git://git.suckless.org/sinit
	git://git.suckless.org/ubase
	http://b0llix.net/perp/distfiles/perp-2.07.tar.gz
EOF
`

port_compile()
{
	cd .
	./pkgbuild Prepare
	./pkgbuild Build
	./pkgbuild $2
}

tenv_compile()
{
	base="$(basename "$1")"
	type="$(printf "%.3s" $1)"

	if [ "$type" == "git" ]; then
		git clone $1
		cd $base
	else
		$FETCH $1
		$UNAR  $base
		cd "$(basename "$base" .tar.gz)"
	fi

	make CC=$CC CFLAGS=$CFLAGS CPPFLAGS=$CPPFLAGS
	make DESTDIR="" install
}

generate_env()
{
	cd .
	for pkg in $LENV; do
		( port_compile pkg Install )
	done
}

generate_pkgs()
{
	cd .
	for pkg in $PENV; do
		( port_compile $pkg Package
		mv package $pkg_dir
		mv dbfile  ${pkg_dir}/$pkg )
	done
	for pkg in $TENV; do
		( tenv_compile $pkg 
		mv package $pkg_dir
		mv dbfile  ${pkgdir}/$pkg )
	done
}
