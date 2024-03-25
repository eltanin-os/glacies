#!/bin/execlineb -S3
if { mkdir $3 }
cd $3
if {
	redirfd -w 1 type
	echo longrun
}
redirfd -w 1 run
heredoc 0
"#!/bin/execlineb -P
dhcpcd -B ${2}"
cat
