#!/bin/sh
#
set -a

COMPILER="ellcc"
RPORTS="git://github.com/eltanin-os/ports"
ROOTDIR="/mnt/glacies"

##
FETCH="curl -LO"
COMPRESS="pigz -z"
UNCOMPRESS="pigz -d"
PKGSUF="pkg.tzz"
TAR="pax -x ustar -w"
UNTAR="pax -x ustar -r"
