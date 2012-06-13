# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: This ebuild is from freeswitch overlay; Bumped by mva; $

EAPI="4"

DESCRIPTION="Sounds for FreeSWITCH (Meta package)"
HOMEPAGE="http://www.freeswitch.org/"
LICENSE="MPL-1.1"
KEYWORDS="~amd64 ~x86"
SLOT="0"
IUSE="linguas_en linguas_es linguas_fr linguas_pt_BR linguas_ru"
REQUIRED_USE=" || ( linguas_en linguas_es linguas_fr linguas_pt_BR linguas_ru )"
SRC_URI=""

RU_VERSION="1.0.13"
FR_VERSION="1.0.15"
ES_VERSION="1.0.14"
PT_VERSION="1.0.14"
EN_VERSION="1.0.18"

DEPEND="
	|| (
		(
		  linguas_en? ( >=${CATEGORY}/${PN}-en-${EN_VERSION} )
		  linguas_es? ( >=${CATEGORY}/${PN}-es-${ES_VERSION} )
		  linguas_fr? ( >=${CATEGORY}/${PN}-fr-${FR_VERSION} )
		  linguas_pt_BR? ( >=${CATEGORY}/${PN}-pt-${PT_VERSION} )
		  linguas_ru? ( >=${CATEGORY}/${PN}-ru-${RU_VERSION} )
		)
	)
"
RDEPEND="net-voip/freeswitch"
