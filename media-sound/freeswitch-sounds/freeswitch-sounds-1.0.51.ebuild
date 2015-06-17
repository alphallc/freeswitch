# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="5"

DESCRIPTION="Sounds for FreeSWITCH (Meta package)"
HOMEPAGE="http://www.freeswitch.org/"
LICENSE="MPL-1.1"
KEYWORDS="~amd64 ~x86"
SLOT="0"
IUSE="linguas_en_US linguas_fr_CA linguas_pt_BR linguas_ru_RU"
REQUIRED_USE=" || ( linguas_en_US linguas_fr_CA linguas_pt_BR linguas_ru_RU )"
SRC_URI=""

DEPEND="
	|| (
		(
		  linguas_en_US? ( >=${CATEGORY}/${PN}-en-us-${PV} )
		  linguas_fr_CA? ( >=${CATEGORY}/${PN}-fr-ca-${PV} )
		  linguas_pt_BR? ( >=${CATEGORY}/${PN}-pt-br-${PV} )
		  linguas_ru_RU? ( >=${CATEGORY}/${PN}-ru-ru-${PV} )
		)
	)
"
RDEPEND=""
