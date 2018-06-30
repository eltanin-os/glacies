#!/bin/sh
#
set -e

compiler_cc_path()
{
	( cd ellcc
	path="`pwd`" )

	if [ "$1" -eq 0 ]
	then
		printf "${path}/bin/ecc"
	else
		printf "${ROOTDIR}/opt/ellcc/bin/ecc"
	fi
}

compiler_cxx_path()
{
	( cd ellcc
	path="`pwd`" )

	if [ "$1" -eq 0 ]
	then
		printf "${path}/bin/ecc++"
	else
		printf "${ROOTDIR}/opt/ellcc/bin/ecc++"
	fi
}

compiler_prepare()
{
	for i in bash make svn git cmake automake autoconf bison flex; do
		type $i || printf "$0: dependency $i not found" >&2
	done
	svn co http://ellcc.org/svn/ellcc/trunk ellcc
}

compiler_build()
{
	( cd ellcc
	./ellcc build)
}

compiler_install()
{
	( cd ellcc
	mkdir /opt/ellcc
	mv bin lib libecc ${ROOTDIR}/opt/ellcc )
}
