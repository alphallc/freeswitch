#
# Copyright (C) 2008-2010 Stefan Knoblich <s.knoblich@axsentis.de>
#
# Distributed under the terms of the GNU General Public License 2
# see http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt for
# more information
#
EAPI="1"

IUSE="+linguas_en linguas_ru"

URI_BASE="http://files.freeswitch.org/freeswitch-sounds"

RU_VERSION="1.0.12"
EN_VERSION="${PV}"

DESCRIPTION="Sounds for FreeSWITCH (Meta package)"
HOMEPAGE="http://www.freeswitch.org/"
SRC_URI=""


DEPEND="
	|| (
		(
		  linguas_en? ( >=${CATEGORY}/${PN}-en-${EN_VERSION} )
		  linguas_ru? ( >=${CATEGORY}/${PN}-ru-${RU_VERSION} )
		)
		>=${CATEGORY}/${PN}-en-${EN_VERSION}
	)"


LICENSE="MPL-1.1"
SLOT="0"

KEYWORDS="~amd64 ~x86"

RDEPEND="net-misc/freeswitch"
