# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: This ebuild is from freeswitch overlay; Bumped by mva; $

EAPI="4"

IUSE="+capi static-libs"

inherit base eutils autotools git-2

DESCRIPTION="mISDN (modular ISDN) kernel link library and includes"
HOMEPAGE="http://www.mISDN.org/"

EGIT_REPO_URI="git://git.misdn.eu/mISDNuser.git"
EGIT_COMMIT="376ab1d56d654c8a5700dfaafe4e129854279b16"
EGIT_BRANCH="socket"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"

RDEPEND="sys-libs/ncurses
	capi? ( >=net-dialup/capi4k-utils-3.2.0
		!!>=net-dialup/capi4k-utils-20050718
		>=media-libs/spandsp-0.0.6_pre12 )"

DEPEND="${RDEPEND}"

S="${WORKDIR}/mISDNuser"

PATCHES=( "${FILESDIR}/${P}-udev-rulesd.patch" )
DOCS=( "AUTHORS" "COPYING.LIB" "LICENSE" "NEWS" "README" )

src_prepare() {
	base_src_prepare
	eautoreconf
}

src_configure() {
	# install example applications too, contains some useful stuff like misdntestlayer1
	econf \
		$(use_enable capi) \
		$(use_enable static-libs static) \
		--with-mISDN_group=dialout \
		--enable-example || die "econf failed"
}

src_install() {
	base_src_install

	use capi && \
		newinitd "${FILESDIR}/mISDNcapid.initd" mISDNcapid

	if ! use static-libs ; then
		# remove all .la files
		find "${D}" -name "*.la" -delete
	elif use capi ; then
		# remove capi plugin .la files
		find "${D}/usr/$(get_libdir)/capi/" -name "*.la" -delete
	fi

}
