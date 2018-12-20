#!/bin/sh
#
set -e

err()
{
	printf "$0: $1\n" >&2
	exit 1
}

export TOOLDIR="$(pwd)"

[ -z "$CC"  ] && CC=cc
[ -z "$CXX" ] && CXX=c++

. config.sh
. scripts/compiler/${COMPILER}.sh
. scripts/common/source.sh

( type awk || err "dependency awk not found"
compress=""$(printf "$COMPRESS" | awk '{ print $1 }')""
fetch="$(printf "$FETCH" | awk '{ print $1 }')"
tar="$(printf "$TAR" | awk '{ print $1 }')"

for i in $compress fakeroot $fetch git make $tar; do
	type $i || err "dependency $i not found"
done
# lilo
type as86 || err "dependency as86 not found"
type ld86 || err "dependency ld86 not found" )

if [ ! -e .phase1 ]
then
	( [ -d tmp ] || mkdir tmp
	cd tmp
	mkdir -p var/pkg/local )

	( cd tmp
	compiler_prepare || err "failed to prepare the enviroment"
	compiler_build   || err "failed to build the compiler" )

	( cd tmp
	git clone "$KHEADS"
	( cd kernel-headers
	make prefix=/ DESTDIR="${TOOLDIR}/tmp" install )
	git clone "$RPORTS"
	cd ports
	cp ${TOOLDIR}/scripts/ports/*         pkg
	cp ${TOOLDIR}/scripts/patches/ports/* patches
	export PORTS="$(pwd)"
	CC="$(compiler_cc_path   0)"
	CXX="$(compiler_cxx_path 0)"
	sed -e "s/CC=\"cc\"/CC=\"$CC\"/"                           \
	    -e "s/CXX=\"c++\"/CXX=\"$CXX\"/"                       \
	    -e "s/CFLAGS=\"/CFLAGS=\"-I${TOOLDIR}\/tmp\/include /" \
	    -e "s/LDFLAGS=\"/LDFLAGS=\"-L${TOOLDIR}\/tmp\/lib /"   \
	    -e "s/DBDIR=\"/DBDIR=\"${TOOLDIR}\/tmp/"               \
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
	      media mnt opt share src srv usr var
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
	DIRDB=="${TOOLDIR}/tmp/database"

	# take name and version from lux port entry
	# then extract it to the system
	( tmp="$(mktemp)"
	head -n 3 ${TOOLDIR}/scripts/ports/lux | sed '/\[vars\]/d' 1> $tmp
	. $tmp
	$UNCOMPRESS "${DIRPKGS}/${name}#${version}.$pkgsuf" | $UNTAR
	rm $tmp )

	mv "${DIRPKGS}/*" var/pkg/cache
	mv "${DIRDB}/*"   var/pkg/tmp

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

	# use lux on chroot
	for pkg in var/pkg/tmp/*; do
		chroot . lux -N explode  "/${pkg}"
		chroot . lux -N add      "/${pkg}"
		chroot . lux -N register "/${pkg}"
	done
	chroot . lux  update
	for pkg in linux-headers linux-image; do
		chroot . lux fetch    $pkg
		chroot . lux explode  $pkg
		chroot . lux add      $pkg
		chroot . lux register $pkg
	done
fi
