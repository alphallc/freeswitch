#!/bin/sh
find * -type f -name '*.ebuild' -print0 | xargs -0 sed -r \
	-e "1s/^#.*/# Copyright 1999-$(date +%Y) Gentoo Foundation/" \
	-e "2s/^#.*/# Distributed under the terms of the GNU General Public License v2/" \
	-e '3s/^#.*/# $Header: This ebuild is from freeswitch overlay; Bumped by mva; $/' \
	-e '5s/EAPI=["]?[^3].*/EAPI="4"/' -i
