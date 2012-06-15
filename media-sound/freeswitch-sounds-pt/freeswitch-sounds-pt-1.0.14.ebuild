# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: This ebuild is from freeswitch overlay; Bumped by mva; $

EAPI="4"

DESCRIPTION="Portuguese soundfiles for FreeSWITCH"
HOMEPAGE="http://www.wirelessmundi.com/"
LICENSE="CCPL-Attribution-3.0"
SLOT="0"
KEYWORDS="~amd64 ~x86"

MY_PV="${PV/_/.}"
SRC_URI="http://www.wirelessmundi.com/${PN}-BR-karina-48000-${MY_PV}.tar.gz"

DEPEND="net-voip/freeswitch"
RDEPEND="${DEPEND}"

S="${WORKDIR}"

FREESWITCH_USER=${FREESWITCH_USER:-voip}
FREESWITCH_GROUP=${FREESWITCH_GROUP:-voip}

src_install() {
        dodir /usr/share/freeswitch/sounds
        mv "${S}"/* "${D}/usr/share/freeswitch/sounds/" || die "Failed to copy sound files"
        fowners "${FREESWITCH_USER}":"${FREESWITCH_GROUP}" "${D}/usr/share/freeswitch/sounds/"
}
