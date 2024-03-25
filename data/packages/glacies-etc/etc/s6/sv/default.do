#!/bin/execlineb -S3
if { redo-ifchange /etc/s6/rc.conf }
if { mkdir $3 }
cd $3
backtick type {
	pipeline { venus-conf -t services /etc/s6/rc.conf }
	pipeline { venus-conf -t $1 }
	venus-conf type
}
importas -iu type type
if {
	redirfd -w 1 type
	echo $type
}
ifelse { test "bundle" = "${type}" } {
	backtick files {
		pipeline { venus-conf -t services /etc/s6/rc.conf }
		pipeline { venus-conf -t $1 }
		venus-conf -lt contents.d
	}
	mkdir contents.d
	importas -isu files files
	if { redo-ifchange ../${files} }
	touch contents.d/${files}
}
# optional dependencies.d
if {
	backtick -D "" files {
		pipeline { venus-conf -t services /etc/s6/rc.conf }
		pipeline { venus-conf -t $1 }
		venus-conf -t dependencies.d
	}
	if -t {
		importas -iu files files
		test -n "${dependencies}"
	}
	mkdir dependencies.d
	importas -iu files files
	touch dependencies.d/$files
}
# oneshot or longrun
ifelse { test "oneshot" = "${type}" } {
	if {
		backtick -D "" down {
			pipeline { venus-conf -t services /etc/s6/rc.conf }
			pipeline { venus-conf -t $1 }
			venus-conf down
		}
		if -t {
			importas -iu down down
			test -n "${down}"
		}
		redirfd -w 1 "down"
		printf "#!/bin/execlineb -P\n%s\n" $down
	}
	backtick up {
		pipeline { venus-conf -t services /etc/s6/rc.conf }
		pipeline { venus-conf -t $1 }
		venus-conf up
	}
	redirfd -w 1 "up"
	importas -iu up up
	printf "#!/bin/execlineb -P\n%s\n" $up
}
# longrun or let s6-rc-compile deal with errors
backtick run {
	pipeline { venus-conf -t services /etc/s6/rc.conf }
	pipeline { venus-conf -t $1 }
	venus-conf run
}
redirfd -w 1 "run"
importas -iu run run
printf "#!/bin/execlineb -P\n%s\n" $run
