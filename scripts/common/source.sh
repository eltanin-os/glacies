#!/bin/sh
# Environment:
# * DIRPKGS
# *
set -e

UNAR="tar -xzf"
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

# copy from eltanin-os/ports
__gendbfile()
{
	size=`du -sk .pkgroot | awk '{printf "%u", $1*1024}'`
	pkgsize=`du -sk ${name} | awk '{printf "%u", $1*1024}'`
	dirs=`find .pkgroot -type d -print | sed -e 's/.pkgroot\///g' -e 's/.pkgroot//g'`
	files=`find -L .pkgroot -type f -print | sed -e 's/.pkgroot\///g' -e 's/.pkgroot//g'`
	cat <<-EOF
		name:$NAME
		version:$VERSION
		license:$LICENSE
		description:$DESCRIPTION
		size:$size
		pkgsize:$pkgsize
	EOF
	for d in $RUNDEPS; do
		printf "run-dep:${d}\n"
	done
	for d in $MAKEDEPS; do
		# get package version from dbfile
		d="${d}#`grep 'version' ${DBDIR}/${d} | sed 's/version://g'`"
		printf "make-dep:${d}\n"
	done
	for d in $dirs; do
		printf "dir:${d}\n"
	done
	for f in $files; do
		printf "file:${f}\n"
	done
}

port_compile()
{
	cd "$1"
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

	patch -p1 < ${TOOLDIR}/scripts/patches/$1
	make  CC=$CC CFLAGS=$CFLAGS CPPFLAGS=$CPPFLAGS
	make  DESTDIR="$(pwd)/.pkgroot" install

	olddir="$(pwd)"
	name="${base}.${PKGSUF}"
	( cd .pkgroot
	  fakeroot -- $TAR . | $COMPRESS > "${olddir}/${name}" )
	rm -rf .pkgroot
	__gendbfile 1> dbfile
}

# External
generate_env()
{
	for pkg in $LENV; do
		( port_compile $pkg Install )
	done
}

generate_pkgs()
{
	for pkg in $PENV; do
		( port_compile $pkg Package
		pkgname="$(basename $pkg).${PKGSUF}"
		mv $pkgname $DIRPKGS
		mv dbfile   ${DIRPKGS}/$pkg )
	done
	for pkg in $TENV; do
		( tenv_compile $pkg
		pkgname="$(basename $pkg).${PKGSUF}"
		mv $pkgname $DIRPKGS
		mv dbfile   ${DIRPKGS}/$pkg )
	done
}
