#!/bin/sh
#
set -e

compiler_cc_path()
{
	( cd ellcc
	path="`pwd`"
	printf "${path}/bin/ecc" )
}

compiler_cxx_path()
{
	( cd ellcc
	path="`pwd`"
	printf "${path}/bin/ecc++" )
}

compiler_prepare()
{
	for i in bash make svn git cmake automake autoconf bison flex; do
		type $i || printf "$0: dependency $i not found" >&2
	done
	svn co http://ellcc.org/svn/ellcc/trunk ellcc
	( cd ellcc
	for patch in ${TOOLDIR}/scripts/patches/ellcc/*; do
		patch -p1 < $patch
	done )
}

compiler_build()
{
	( cd ellcc
	./ellcc build )
	( cd database
	printf "version:git-a08910fc2cc739f631b75b2d09b8d72a0d64d285" > libc )
}

compiler_install()
{
	( cd ellcc
	mkdir -p ${ROOTDIR}/opt/ellcc
	mv bin lib libecc ${ROOTDIR}/opt/ellcc
	ln -s ../opt/ellcc/bin/ecc   ${ROOTDIR}/bin/cc
	ln -s ../opt/ellcc/bin/ecc++ ${ROOTDIR}/bin/c++ )
}
