#
# Copyright (C) 2011 Stefan Knoblich <s.knoblich@axsentis.de>
#
# Distributed under the terms of the GNU General Public License 2
# see http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt for
# more information
#

EAPI="1"

#IUSE="+16k 32k 48k"

MY_PV="${PV/_/.}"
URI_BASE="http://www.wirelessmundi.com/freeswitch-sounds"

DESCRIPTION="Portuguese soundfiles for FreeSWITCH"
HOMEPAGE="http://www.wirelessmundi.com/"
SRC_URI="${URI_BASE}-pt-BR-karina-48000-${MY_PV}.tar.gz"
#	${URI_BASE}-pt-BR-karina-8000-${MY_PV}.tar.gz
#	 16k? ( ${URI_BASE}-pt-BR-karina-16000-${MY_PV}.tar.gz )
#	 32k? ( ${URI_BASE}-pt-BR-karina-32000-${MY_PV}.tar.gz )
#	 48k? ( ${URI_BASE}-pt-BR-karina-48000-${MY_PV}.tar.gz )"

LICENSE="CCPL-Attribution-3.0"
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
