# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="5"

DESCRIPTION="English soundfiles for FreeSWITCH"
HOMEPAGE="http://www.freeswitch.org/"
LICENSE="MPL-1.1"
KEYWORDS="~amd64 ~x86"
SLOT="0"
IUSE="+8k 16k 32k 48k"
REQUIRED_USE=" || ( 8k 16k 32k 48k ) "

MY_PV="${PV/_/.}"
URI_BASE="http://files.freeswitch.org/${PN}"

SRC_URI=" 8k? ( ${URI_BASE}-callie-8000-${MY_PV}.tar.gz )
	 16k? ( ${URI_BASE}-callie-16000-${MY_PV}.tar.gz )
	 32k? ( ${URI_BASE}-callie-32000-${MY_PV}.tar.gz )
	 48k? ( ${URI_BASE}-callie-48000-${MY_PV}.tar.gz )"

DEPEND=""
RDEPEND="${DEPEND}"

S="${WORKDIR}"

src_install() {
        dodir /usr/share/freeswitch/sounds
        mv "${S}"/* "${D}/usr/share/freeswitch/sounds/" || die "Failed to copy sound files"
}

