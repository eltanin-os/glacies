#!/bin/sh

REPOSITORY=""
PKGMANREPO="git://github.com/eltanin-os/lux"

PACKAGES=`cat <<-EOF
	cbase
	mandoc
	mksh
	perp
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
