# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: This ebuild is from freeswitch overlay; Bumped by mva; $

EAPI="4"

IUSE="16k 32k 48k"
REQUIRED_USE=" || ( 16k 32k 48k )"

DESCRIPTION="Russian soundfiles for FreeSWITCH"
HOMEPAGE="http://www.freeswitch.org/"
LICENSE="MPL-1.1"
SLOT="0"
KEYWORDS="~amd64 ~x86"

MY_PV="${PV/_/.}"
URI_BASE="http://files.freeswitch.org/${PN}"
SRC_URI="${URI_BASE}-RU-elena-8000-${MY_PV}.tar.gz
	 16k? ( ${URI_BASE}-RU-elena-16000-${MY_PV}.tar.gz )
	 32k? ( ${URI_BASE}-RU-elena-32000-${MY_PV}.tar.gz )
	 48k? ( ${URI_BASE}-RU-elena-48000-${MY_PV}.tar.gz )
"

DEPEND="net-voip/freeswitch"
RDEPEND="${DEPEND}"

S="${WORKDIR}"

FREESWITCH_USER=${FREESWITCH_USER:-voip}
FREESWITCH_GROUP=${FREESWITCH_GROUP:-voip}

src_install() {
        dodir /usr/share/freeswitch/sounds
        mv "${S}"/* "${D}/usr/share/freeswitch/sounds/" || die "Failed to copy sound files"
        fowners "${FREESWITCH_USER}":"${FREESWITCH_GROUP}" "/usr/share/freeswitch/sounds"
}
