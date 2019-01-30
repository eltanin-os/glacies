#!/bin/sh
#
set -a

HOSTARCH="x86_64"
ARCH="x86_64"
COMPILER="ellcc"
ROOTDIR="/mnt/glacies"

##
RPORTS="git://github.com/eltanin-os/ports"
KHEADS="git://github.com/sabotage-linux/kernel-headers"

##
FETCH="curl -LO"
COMPRESS="pigz -z -9"
PKGCOMP="pigz -z -0"
UNCOMPRESS="pigz -dc"
PKGSUF="pkg.tzz"
TAR="pax -x ustar -w"
UNTAR="pax -x ustar -r"

##
BZ2="bzip2 -dc"
GZ="pigz -dc"
LZ="true"
XZ="true"
ZZ="pigz -dc"
