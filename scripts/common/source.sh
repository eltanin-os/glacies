#!/bin/sh
# Environment:
# * DIRPKGS
# *
set -e

DIRPKGS="${TOOLDIR}/tmp/packages"
DIRDB="${TOOLDIR}/tmp/database"
REPOSITORY=""

# ports do not handle dependencies,
# keep the libraries first and then sort(1)
PACKAGES="$(cat <<-EOF
	ncurses
	libnl-tiny
	libressl
	libz
	bzip2
	cbase
	curl
	iproute2
	lux
	m4
	make
	mandoc
	mksh
	perp
	pigz
	pkgconf
	sdhcp
	sinit
	smdev
	ubase
	utilchest
	wpa_supplicant
EOF
)
"

generate_pkgs()
{
	env _PORTSYS_PKG_DESTDIR="${DIRPKGS}"\
	    _PORTSYS_DB_DESTDIR="${DIRDB}"\
	    mk/portsys.sh opackage ${PACKAGES}
}
