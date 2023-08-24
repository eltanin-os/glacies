#!/bin/execlineb -S3
foreground { rm -Rf $1 }
if {
	importas -i S6_INIT_FLAGS S6_INIT_FLAGS
	s6-linux-init-maker $S6_INIT_FLAGS /etc/s6/current $3
}
elglob files "${3}/bin/*"
cp -PRp $files /sbin
