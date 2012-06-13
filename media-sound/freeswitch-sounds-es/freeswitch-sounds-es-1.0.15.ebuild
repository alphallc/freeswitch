# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: This ebuild is from freeswitch overlay; Bumped by mva; $

EAPI="4"

MY_PV="${PV/_/.}"

DESCRIPTION="Spanish soundfiles for FreeSWITCH"
HOMEPAGE="http://www.wirelessmundi.com/"
SRC_URI="
	http://www.wirelessmundi.com/${PN}-ES-cristina-48000-${MY_PV}.tar.gz
	http://files.freeswitch.org/${PN}-mx-maria-44100.tar.gz
"

LICENSE="CCPL-Attribution-3.0"
SLOT="0"

KEYWORDS="~amd64 ~x86"

DEPEND="net-voip/freeswitch"
RDEPEND="${DEPEND}"

src_install() {
        dodir /usr/share/freeswitch/sounds
        mv "${WORKDIR}"/* "${D}/usr/share/freeswitch/sounds/" || die "Failed to copy sound files"
        fowners freeswitch:freeswitch "${D}/usr/share/freeswitch/sounds/"
}
