#!/bin/sh
#
set -e

err()
{
	printf "$0: $1\n" >&2
	exit 1
}

havedep()
{
	for dep in ${@}; do
		type $dep || err "dependency $dep not found" >&2
	done
}

gettool()
{
	printf "%s " $1
}

export TOOLDIR="$(pwd)"

[ -z "$CC"  ] && CC=cc
[ -z "$CXX" ] && CXX=c++

. ./config.sh
. ./scripts/compiler/${COMPILER}.sh
. ./scripts/common/source.sh

( deps="$(gettool $COMPRESS && gettool $FETCH && gettool $TAR)"
havedep awk byacc fakeroot git make $deps
# lilo
havedep as86 ld86 )

if [ ! -e .phase1 ]
then
	( [ -d tmp ] || mkdir tmp
	cd tmp
	mkdir database packages )

	( cd tmp
	compiler_prepare || err "failed to prepare the enviroment"
	compiler_build   || err "failed to build the compiler" )

	( cd tmp
	git clone "$KHEADS"
	( cd kernel-headers
	make prefix=/ DESTDIR="${TOOLDIR}/tmp" install )
	CC="$(compiler_cc_path   0)"
	CXX="$(compiler_cxx_path 0)"
	git clone "$RPORTS"
	cd ports
	cp ${TOOLDIR}/scripts/ports/*         pkg
	cp ${TOOLDIR}/scripts/patches/ports/* patches
	export PORTS="$(pwd)"
	sed -e "s|^CC=.*|CC=\"$CC\"|g"                             \
	    -e "s|^CXX=.*|CXX=\"$CXX\"|g"                          \
	    -e "s|^CFLAGS=\"|CFLAGS=\"-I${TOOLDIR}/tmp/include |g" \
	    -e "s|^YACC=|##YACC=|g"                                \
	    -e "s|^#YACC=|YACC=|g"                                 \
	    -e "s|^LDFLAGS=\"|LDFLAGS=\"-L${TOOLDIR}/tmp/lib |g"   \
	    -e "s|^DBDIR=.*|DBDIR=\"${TOOLDIR}/tmp/database\"|g"   \
	    mk/config.mk > config.mk~
	mv config.mk~ mk/config.mk
	generate_pkgs || err "failed to generate packages" )

	touch  .phase1
	printf "execute the script again with root permission\n"
else
	[ "$(whoami)" != "root" ] && err "root permission are needed"

	cd "${ROOTDIR}"

	# generate directories
	mkdir bin boot dev etc home include lib libexec\
	      media mnt opt proc share src srv sys var
	mkdir -m 0750 root
	mkdir -m 1777 tmp
	ln -s . usr
	ln -s bin sbin

	( cd var
	mkdir empty lib lock log pkg run spool )

	( cd var/pkg
	mkdir cache local remote tmp )

	# prepare package manager and minimal packages
	DIRPKGS="${TOOLDIR}/tmp/packages"
	DIRDB="${TOOLDIR}/tmp/database"

	# take name and version from ports
	( tmp="$(mktemp)"
	head -n 3 ${TOOLDIR}/tmp/ports/pkg/lux | sed '/\[vars\]/d' 1> $tmp
	. $tmp
	$UNCOMPRESS "${DIRPKGS}/${name}#${version}.$PKGSUF" | $UNTAR
	rm $tmp )

	( tmp="$(mktemp)"
	head -n 3 ${TOOLDIR}/tmp/ports/pkg/mksh | sed '/\[vars\]/d' 1> $tmp
	. $tmp
	$UNCOMPRESS "${DIRPKGS}/${name}#${version}.$PKGSUF" | $UNTAR
	rm $tmp )

	cp ${DIRPKGS}/*  var/pkg/cache
	cp ${DIRDB}/libc var/pkg/local
	cp ${DIRDB}/*    var/pkg/tmp
	rm var/pkg/tmp/libc

	( cd "${TOOLDIR}/tmp"
	compiler_install )

	# prepare environment
	cp -R "${TOOLDIR}/etc" .
	ln -s lksh bin/sh
	git clone "$RPORTS"

	# prepare the environment to chroot
	mount -t proc none proc
	mount --rbind /sys sys
	mount --rbind /dev dev
	cp /etc/resolv.conf etc

	# use lux to install packages
	PKGR="linux-headers linux-image"
	PKGL="var/pkg/tmp/*"
	chroot . /bin/sh <<-EOF
		lux -N explode  $PKGL
		lux -N add      $PKGL
		lux -N register $PKGL
		lux update
		lux fetch    $PKGR
		lux explode  $PKGR
		lux add      $PKGR
		lux register $PKGR
	EOF
fi
