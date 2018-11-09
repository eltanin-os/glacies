set -a

case "$1" in
"lux")
	NAME="lux"
	VERSION="1.1"
	LICENSE="UNLICENSE"
	DESCRIPTION="a simple package manager"
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
	DESCRIPTION="a persistent process supervisor and service managment framework for un!x"
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
	DESCRIPTION="a suckless init, initially based on Rich Felker’s minimal init"
	;;
"smdev")
	NAME="smdev"
	VERSION="master"
	LICENSE="MIT"
	DESCRIPTION="a mostly mdev-compatible suckless program to manage device nodes"
	;;
"ubase")
	NAME="ubase"
	VERSION="master"
	LICENSE="MIT"
	DESCRIPTION="a collection of unportable tools, similar in spirit to util-linux but much simpler"
	;;
esac
