# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: This ebuild is from freeswitch overlay; Bumped by mva; $

EAPI="4"
IUSE="rcapid static-libs"

inherit eutils autotools git-2 flag-o-matic

DESCRIPTION="mISDN (modular ISDN) kernel link library and includes"
HOMEPAGE="http://www.mISDN.eu/"

EGIT_REPO_URI="git://git.misdn.eu/isdn4k-utils.git"
EGIT_COMMIT="013a7b6cad848057340a40ebcf722453fd8b842a"
EGIT_BRANCH="master"

LICENSE="|| ( GPL-2 LGPL-2.1 )"
SLOT="0"
KEYWORDS="~amd64 ~x86"

RDEPEND="sys-libs/ncurses"
DEPEND="${RDEPEND}"

# base directory
S="${WORKDIR}/isdn4k-utils"
S_SUBDIRS="capi20 capiinfo capiinit avmb1"

src_prepare() {
	for x in ${S_SUBDIRS}; do
		cd "${S}/${x}" || die
		eautoreconf || die "failed to recreate \"${x}\" autotools files"
	done

	if use rcapid; then
		cd "${S}/rcapid" || die
		eautoreconf || die "failed to recreate \"rcapid\" autotools files"
	fi
}

src_configure() {
#	append-cppflags -I"${S}/capi20"
#	append-ldflags  -L"${S}/capi20"

	cd "${S}/capi20" || die
	econf \
		$(use_enable static-libs static) || die "configuration of \"capi20\" failed"

	if use rcapid; then
		cd "${S}/rcapid" || die
		econf || die "configuration of \"rcapid\" failed"
	fi

	cd "${S}/capiinfo" || die
	econf || die "configuration of \"capiinfo\" failed"

	cd "${S}/capiinit" || die
	econf || die "configuration of \"capiinit\" failed"

	cd "${S}/avmb1" || die
	econf || die "configuration of \"avmb1\" failed"
}

src_compile() {
	for x in ${S_SUBDIRS}; do
		cd "${S}/${x}" || die
		emake || die "building \"${x}\" failed"
	done

	if use rcapid; then
		cd "${S}/rcapid" || die
		emake || die "building \"rcapid\" failed"
	fi
}

src_install() {
	for x in ${S_SUBDIRS}; do
		cd "${S}/${x}" || die
		emake DESTDIR="${D}" install || die "installing \"${x}\" failed"
	done

	if use rcapid; then
		cd "${S}/rcapid" || die
		emake DESTDIR="${D}" install || die "installing \"rcapid\" failed"

		docinto rcapid
		dodoc README
	fi

	# TODO: fix in avmb1 sources
	mv "${D}/sbin/avmcapictrl" "${D}/usr/sbin"
	doman "${D}/usr/man/man8/avmcapictrl.8"
	rm -rf "${D}/usr/man"

	# remove .la files
	find "${D}/usr/$(get_libdir)/capi/" -name "*.la" -delete
}
