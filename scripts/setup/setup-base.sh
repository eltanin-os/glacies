#!/bin/sh
#
set -e

# use lux to install and register the base packages
for pkg in /var/pkg/tmp/*; do
	lux -N explode  $pkg
	lux -N add      $pkg
	lux -N register $pkg
done
