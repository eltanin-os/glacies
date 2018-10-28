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
	export PORTS="$(pwd)"
	CC="$(compiler_cc_path   0)"
	CXX="$(compiler_cxx_path 0)"
	sed -e "s/CC=\"cc\"/CC=\"$CC\"/"                       \
	    -e "s/CXX=\"c++\"/CXX=\"$CXX\"/"                   \
	    -e "s/CFLAGS=\"/CFLAGS=\"-I${TOOLDIR}/tmp/include" \
	    -e "s/LDFLAGS=\"/LDFLAGS=\"-L${TOOLDIR}/tmp/lib"   \
	    -e "s/DBDIR=\"/DBDIR=\"${TOOLDIR}\/tmp/"           \
	    -i mk/config.mk

	( export ROOT="${TOOLDIR}/tmp" # env var used inside ports
	export DBDIR="$ROOT"
	generate_env  || err "failed to generate the local libraries" )

	generate_pkgs || err "failed to generate packages" )

	touch  .phase1
	printf "execute the script again with root permission\n"
else
	cd "${ROOTDIR}"

	# generate directories
	mkdir boot dev etc home media mnt opt srv usr var
	mkdir -m 0750 root
	mkdir -m 1777 tmp
	ln -s usr/bin bin sbin
	ln -s usr/lib lib

	( cd usr
	mkdir bin include lib libexec lib share src
	ln -s bin sbin )

	( cd var
	mkdir empty lib lock log pkg run spool )

	( cd var/pkg
	mkdir cache local remote tmp )

	# prepare package manager and minimal packages
	DPKGS="${TOOLDIR}/tmp/pkg"

	( ${TOOLDIR}/common/pkginfo.sh lux
	$UNCOMPRESS "${DPKGS}/${NAME}#${VERSION}.${PKGSUF}" | $UNTAR
	rm -f "${DPKGS}/${NAME}#${VERSION}.${PKGSUF}"
	mv "${DPKGS}/${NAME}" var/pkg/local )

	mv "${DPKGS}/*.${PKGSUF}" var/pkg/cache
	mv "${DPKGS}/*"           var/pkg/tmp

	( cd "${TOOLDIR}/tmp"
	compiler_install )

	# prepare environment
	cp -R "${TOOLDIR}/etc" .

	( cd usr
	git clone "$RPORTS"
	ln -s lksh bin/sh )

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
	chroot . lux update
	chroot . lux fetch    linux-headers
	chroot . lux fetch    linux-image
	chroot . lux explode  linux-headers
	chroot . lux explode  linux-image
	chroot . lux add      linux-headers
	chroot . lux add      linux-image
	chroot . lux register linux-headers
	chroot . lux register linux-image
fi
