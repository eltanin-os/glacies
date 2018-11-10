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
	net-devel/libnl-tiny
EOF
`

# Packages (ports)
PENV=`cat <<-EOF
	archivers/bzip2
	archivers/pigz
	devel/m4
	devel/make
	devel/samurai
	net/curl
	net/wpa_supplicant
	shells/mksh
	sysutils/cbase
	sysutils/mandoc
	sysutils/utilchest
EOF
`

# Packages (non-ports)
TENV=`cat <<-EOF
	git://git.2f30.org/sdhcp
	git://git.kernel.org/pub/scm/network/iproute2/iproute2
	git://git.suckless.org/sinit
	git://git.suckless.org/smdev
	git://git.suckless.org/ubase
	git://github.com/eadwardus/perp
	git://github.com/eltanin-os/lux
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

	for patch in ${TOOLDIR}/scripts/patches/${base}/*; do
		patch -p1 < $patch
	done

	make CC=$CC\
	     CFLAGS=$CFLAGS\
	     CPPFLAGS=$CPPFLAGS\
	     PREFIX=$PREFIX\
	     MANPREFIX=$MANDIR

	make DESTDIR="$(pwd)/.pkgroot" install
	make DESTDIR="$(pwd)/.pkgroot" install-man 2>/dev/null || true

	olddir="$(pwd)"
	name="${NAME}#${VERSION}.${PKGSUF}"
	( cd .pkgroot
	__manpages="-name *.1 $(printf "-o -name *.%s " $(seq 2 8))"
	find ./${MANDIR} -type f $__manpages -exec $COMPRESS {} +
	fakeroot -- $TAR . | $PKGCOMP > "${olddir}/${name}" )
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
