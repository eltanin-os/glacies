set -a

case "$1" in
"lux")
	NAME="lux"
	VERSION="1.1"
	LICENSE="UNLICENSE"
	DESCRIPTION="A simple package manager."
	;;
"iproute2")
	NAME="iproute2"
	VERSION="4.19.0"
	LICENSE="GPL-2"
	DESCRIPTION="A set of utilities for Linux networking."
	;;
"perp")
	NAME="perp"
	VERSION="2.07"
	LICENSE="CUSTOM"
	DESCRIPTION="A persistent process supervisor and service managment framework for un*x."
	;;
"sdhcp")
	NAME="sdhcp"
	VERSION="master"
	LICENSE="MIT"
	DESCRIPTION="A suckless dhcp client."
	;;
"sinit")
	NAME="sinit"
	VERSION="1.1"
	LICENSE="MIT"
	DESCRIPTION="A suckless init."
	;;
"smdev")
	NAME="smdev"
	VERSION="master"
	LICENSE="MIT"
	DESCRIPTION="A mostly mdev-compatible suckless program to manage device nodes."
	;;
"ubase")
	NAME="ubase"
	VERSION="master"
	LICENSE="MIT"
	DESCRIPTION="A collection of unportable tools."
	;;
esac
