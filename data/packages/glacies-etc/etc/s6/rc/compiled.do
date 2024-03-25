#!/bin/execlineb -S3
if {
	ifelse {
		redirfd -w 1 /dev/null
		venus-conf -t user /etc/s6/rc.conf
	} {
		if { redo-ifchange /etc/s6/sv/user }
		touch /etc/s6/sv/default/contents.d/user
	}
	rm -f /etc/s6/sv/default/contents.d/user
}
s6-rc-compile $3 /etc/s6/sv
