#!/bin/execlineb -P
backtick packages { ls packages }
importas -isu packages packages
forx -Ep package { $packages }
if {
	cd packages/${package}
	pipeline { venus-ar -c . }
	redirfd -w 1 ../../venus-store/cache/${package}
	lzip -9
}
cd venus-store/cache
backtick sum { pipeline { venus-cksum $package } venus-conf $package }
backtick version { venus-conf version ../repo/disk/${package} }
multisubstitute {
	importas -iu sum sum
	importas -iu version version
}
mv $package ${sum}.${package}#${version}.pkg