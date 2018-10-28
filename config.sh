#!/bin/sh
#
set -a

ARCH="x86_64"
COMPILER="ellcc"
ROOTDIR="/mnt/glacies"

##
RPORTS="git://github.com/eltanin-os/ports"
KHEADS="git://github.com/sabotage-linux/kernel-headers"

##
FETCH="curl -LO"
COMPRESS="pigz -z"
UNCOMPRESS="pigz -dc"
PKGSUF="pkg.tzz"
TAR="pax -x ustar -w"
UNTAR="pax -x ustar -r"
