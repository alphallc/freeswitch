# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="5"

DESCRIPTION="Sounds for FreeSWITCH (Meta package)"
HOMEPAGE="http://www.freeswitch.org/"
# The freeswitch-1.4.18 tarball contains .spec files for the creation of RPMs of the sounds.
# These files state "License: MPL".
LICENSE="MPL"
KEYWORDS="~amd64 ~x86"
SLOT="0"
IUSE="+8k 16k 32k 48k linguas_en_CA linguas_en_US linguas_fr_CA linguas_pt_BR linguas_ru_RU linguas_zh_HK"
REQUIRED_USE="
	|| ( linguas_en_CA linguas_en_US linguas_fr_CA linguas_pt_BR linguas_ru_RU linguas_zh_HK )
	|| ( 8k 16k 32k 48k )
"

MY_PV="${PV/_/.}"
URI_BASE="http://files.freeswitch.org/releases/sounds/${PN}"

S="${WORKDIR}"

SRC_URI="
	linguas_en_CA? (
		 8k? ( ${URI_BASE}-en-ca-june-8000-${MY_PV}.tar.gz )
		16k? ( ${URI_BASE}-en-ca-june-16000-${MY_PV}.tar.gz )
		32k? ( ${URI_BASE}-en-ca-june-32000-${MY_PV}.tar.gz )
		48k? ( ${URI_BASE}-en-ca-june-48000-${MY_PV}.tar.gz )
	)
	linguas_en_US? (
		 8k? ( ${URI_BASE}-en-us-callie-8000-${MY_PV}.tar.gz )
		16k? ( ${URI_BASE}-en-us-callie-16000-${MY_PV}.tar.gz )
		32k? ( ${URI_BASE}-en-us-callie-32000-${MY_PV}.tar.gz )
		48k? ( ${URI_BASE}-en-us-callie-48000-${MY_PV}.tar.gz )
	)
	linguas_fr_CA? (
		 8k? ( ${URI_BASE}-fr-ca-june-8000-${MY_PV}.tar.gz )
		16k? ( ${URI_BASE}-fr-ca-june-16000-${MY_PV}.tar.gz )
		32k? ( ${URI_BASE}-fr-ca-june-32000-${MY_PV}.tar.gz )
		48k? ( ${URI_BASE}-fr-ca-june-48000-${MY_PV}.tar.gz )
	)
	linguas_pt_BR? (
		 8k? ( ${URI_BASE}-pt-BR-karina-8000-${MY_PV}.tar.gz )
		16k? ( ${URI_BASE}-pt-BR-karina-16000-${MY_PV}.tar.gz )
		32k? ( ${URI_BASE}-pt-BR-karina-32000-${MY_PV}.tar.gz )
		48k? ( ${URI_BASE}-pt-BR-karina-48000-${MY_PV}.tar.gz )
	)
	linguas_ru_RU? (
		 8k? ( ${URI_BASE}-ru-RU-elena-8000-${MY_PV}.tar.gz )
		16k? ( ${URI_BASE}-ru-RU-elena-16000-${MY_PV}.tar.gz )
		32k? ( ${URI_BASE}-ru-RU-elena-32000-${MY_PV}.tar.gz )
		48k? ( ${URI_BASE}-ru-RU-elena-48000-${MY_PV}.tar.gz )
	)
	linguas_zh_HK? (
		 8k? ( ${URI_BASE}-zh-hk-sinmei-8000-${MY_PV}.tar.gz )
		16k? ( ${URI_BASE}-zh-hk-sinmei-16000-${MY_PV}.tar.gz )
		32k? ( ${URI_BASE}-zh-hk-sinmei-32000-${MY_PV}.tar.gz )
		48k? ( ${URI_BASE}-zh-hk-sinmei-48000-${MY_PV}.tar.gz )
	)
"

DEPEND=""
RDEPEND=""

src_install() {
	dodir /usr/share/freeswitch/sounds
	cp -R "${S}/"* "${D}/usr/share/freeswitch/sounds" || die "Installation failed"
}
