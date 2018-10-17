#!/bin/sh
#
set -e

REPOSITORY=""
PKGMANREPO="git://github.com/eltanin-os/lux"

PACKAGES=`cat <<-EOF
	bzip2
	cbase
	mandoc
	mksh
	perp
	pigz
	sinit
	ubase
	utilchest
EOF
`
generate_env()
{
	true
}

generate_pkgs()
{
	true
}
