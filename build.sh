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
	compiler_prepare || err "failed to prepare the enviroment"
	compiler_build   || err "failed to build the compiler" )

	( cd tmp
	git clone "$RPORTS"
	cd ports
	export PORTS="$(pwd)"
	CC="$(compiler_cc_path   0)"
	CXX="$(compiler_cxx_path 0)"
	sed -e "s/CC=cc/CC=$CC/"                 \
	    -e "s/CXX=c++/CXX=$CXX/"             \
	    -e "s/DBDIR=/DBDIR=${TOOLDIR}\/tmp/" \
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
	mkdir lib lock log pkg run spool )

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

	cp -R "${TOOLDIR}/etc" .
fi
