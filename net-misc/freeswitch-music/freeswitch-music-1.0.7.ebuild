#
# Copyright (C) 2008 Stefan Knoblich <s.knoblich@axsentis.de>
#
# Distributed under the terms of the GNU General Public License 2
# see http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt for
# more information
#

EAPI="1"

IUSE="+16k 32k 48k"

MY_PV="${PV/_/.}"
URI_BASE="http://files.freeswitch.org/freeswitch-sounds-music"

DESCRIPTION="On-Hold Music for FreeSWITCH"
HOMEPAGE="http://www.freeswitch.org/"
SRC_URI="
	${URI_BASE}-8000-${MY_PV}.tar.gz
	16k? ( ${URI_BASE}-16000-${MY_PV}.tar.gz )
	32k? ( ${URI_BASE}-32000-${MY_PV}.tar.gz )
	48k? ( ${URI_BASE}-48000-${MY_PV}.tar.gz )
        "


LICENSE="MPL-1.1"
SLOT="0"

KEYWORDS="~amd64 ~x86"

DEPEND="net-misc/freeswitch"

RDEPEND="${DEPEND}"


src_install() {
	#
	# 1. Copy files
	#
	dodir /opt/freeswitch/sounds
	mv "${WORKDIR}/"* "${D}/opt/freeswitch/sounds/" || die "Failed to copy sound files"

	#
	# 2. Fix permissions
	#
	einfo "Setting file and directory permissions..."

	# prefix
	chown -R root:freeswitch "${D}/opt/freeswitch"
	chmod -R u=rwX,g=rX,o=   "${D}/opt/freeswitch"
}
