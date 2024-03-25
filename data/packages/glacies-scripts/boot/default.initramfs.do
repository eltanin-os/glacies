#!/bin/execlineb -S3
if { redo-ifchange /etc/init.in }
backtick tmpdir { mktemp -d }
importas -iu tmpdir tmpdir
foreground {
	cd $tmpdir
	# filesystem build
	if { mkdir -p etc/default bin dev lib/firmware run sys proc tmp }
	if { ln -s . usr }
	if { ln -s bin sbin }
	# files build
	if { touch etc/fstab }
	if {
		define path "/venus-store/modules/venus"
		backtick core {
			export VENUS_CONFIG_FILE "root"
			${path}/repo/get -t rundeps system-core
		}
		importas -isu core core
		forx -E package { $core }
		cp -R ${path}/root.progs/${package}/. .
	}
	# /etc files
	if {
		redirfd -w 1 etc/group
		echo "root:x:0:"
	}
	if {
		redirfd -w 1 etc/passwd
		echo "root:x:0:0::/root:/bin/sh"
	}
	if {
		redirfd -w 1 etc/mdev.conf
		echo "$MODALIAS=.*    root:root 660 @modprobe -qb \"$MODALIAS\""
	}
	# modules build
	if {
		pipeline {
			elglob crypto "/lib/modules/${2}/kernel/arch/*/crypto"
			find
			    $crypto
			    /lib/modules/${2}/kernel/block
			    /lib/modules/${2}/kernel/crypto
			    /lib/modules/${2}/kernel/drivers/ata
			    /lib/modules/${2}/kernel/drivers/block
			    /lib/modules/${2}/kernel/drivers/cdrom
			    /lib/modules/${2}/kernel/drivers/firewire
			    /lib/modules/${2}/kernel/drivers/md
			    /lib/modules/${2}/kernel/drivers/scsi
			    /lib/modules/${2}/kernel/drivers/usb/common
			    /lib/modules/${2}/kernel/drivers/usb/core
			    /lib/modules/${2}/kernel/drivers/usb/host
			    /lib/modules/${2}/kernel/drivers/usb/storage
			    /lib/modules/${2}/kernel/fs
			    /lib/modules/${2}/kernel/lib
			    ! -type d
		}
		cpio -pLd .
	}
	if {
		cd /lib/modules/${2}
		if { install -cm 0755 modules.builtin lib/modules/${2} }
		install -cm 0755 modules.order lib/modules/${2}
	}
	if { depmod -b . $2 }
	# init build
	if { install -cm 0755 /etc/init.in init }
	pipeline { find . }
	pipeline { cpio -o -H newc }
	redirfd -w 1 $3
	pigz -9
}
importas -iu status ?
foreground { rm -Rf $tmpdir }
exit $status
