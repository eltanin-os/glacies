#!/bin/sh
# Environment:
# * DIRPKGS
# *
set -e

DIRPKGS="${TOOLDIR}/tmp/pkg"
REPOSITORY=""

# Libraries (ports)
LENV=`cat <<-EOF
	devel/libz
	devel/ncurses
EOF
`

# Packages (ports)
PENV=`cat <<-EOF
	archivers/bzip2
	archivers/pigz
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
	git://github.com/eadwardus/perp
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

	${TOOLDIR}/common/pkginfo.sh ${base}

	git clone $1
	cd  $base

	if [ "$VERSION" == "master" ]; then
		VERSION="$(git rev-parse HEAD)"
	else
		git checkout tags/v${VERSION}
	fi

	for patch in "${TOOLDIR}/scripts/patches/${base}/*"; do
		patch -p1 < $patch
	done

	make  CC=$CC CFLAGS=$CFLAGS CPPFLAGS=$CPPFLAGS
	make  DESTDIR="$(pwd)/.pkgroot" install

	olddir="$(pwd)"
	name="${NAME}#${VERSION}.${PKGSUF}"
	( cd .pkgroot
	  fakeroot -- $TAR . | $COMPRESS > "${olddir}/${name}" )
	__gendbfile 1> dbfile
	rm -rf .pkgroot
}

# External
generate_env()
{
	for pkg in $LENV; do
		( port_compile $pkg Install
		mv dbfile "${TOOLDIR}/tmp/$NAME" )
	done
}

generate_pkgs()
{
	for pkg in $PENV; do
		( port_compile $pkg Package
		pkgname="${NAME}#${VERSION}.${PKGSUF}"
		mv $pkgname $DIRPKGS
		mv dbfile   ${DIRPKGS}/$NAME )
	done
	for pkg in $TENV; do
		( tenv_compile $pkg
		pkgname="${NAME}#${VERSION}.${PKGSUF}"
		mv $pkgname $DIRPKGS
		mv dbfile   ${DIRPKGS}/$NAME )
	done
}
