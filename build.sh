#!/bin/sh
#
set -e

err()
{
	printf "$0: $1\n" >&2
	exit 1
}

TOOLDIR="$(pwd)"

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
	  generate_env  || err "failed to generate the local libraries" )

	generate_pkgs || err "failed to generate packages" )

	touch  .phase1
	printf "execute the script again with root permission\n"
else
	true
fi