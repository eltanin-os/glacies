set -a

case "$1" in
"lux")
	NAME="lux"
	VERSION="1.0"
	LICENSE="UNLICENSE"
	DESCRIPTION="simple package manager"
	;;
"sinit")
	NAME="sinit"
	VERSION="1.1"
	LICENSE="MIT"
	DESCRIPTION="a suckless init, initially based on Rich Felker’s minimal init"
	;;
"ubase")
	NAME="ubase"
	VERSION="master"
	LICENSE="MIT"
	DESCRIPTION="a collection of unportable tools, similar in spirit to util-linux but much simpler"
	;;
"perp")
	NAME="perp"
	VERSION="master"
	LICENSE="CUSTOM"
	DESCRIPTION="a persistent process supervisor and service managment framework for un!x"
	;;
esac
