# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: This ebuild is from freeswitch overlay; Bumped by mva; $

EAPI="4"

IUSE=""

inherit eutils autotools git-r3

#MY_P="mISDNuser-${PV//./_}"

DESCRIPTION="mISDN (modular ISDN) kernel link library and includes"
HOMEPAGE="http://www.mISDN.org/"
#SRC_URI="http://www.linux-call-router.de/download/lcr-1.7/${MY_P}.tar.gz"

EGIT_REPO_URI="git://git.misdn.org/mISDNuser.git"
EGIT_COMMIT="8d01cd531d4422b1368ecc76f7852bb40317a1a0"
EGIT_BRANCH="socket"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"

RDEPEND="sys-libs/ncurses"
DEPEND="${RDEPEND}"

src_prepare() {
	eautoreconf
}

src_configure() {
	# install example applications too, contains some useful stuff like misdntestlayer1
	econf \
		--enable-example || die "econf failed"
}

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed"

	dodoc AUTHORS COPYING.LIB NEWS README
}
