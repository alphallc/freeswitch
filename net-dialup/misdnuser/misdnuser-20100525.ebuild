# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-dialup/misdnuser/misdnuser-1.1.7.2.ebuild,v 1.1 2008/02/12 08:14:18 sbriesen Exp $

EAPI="2"

inherit eutils

MY_P="mISDNuser-${PV//./_}"

DESCRIPTION="mISDN (modular ISDN) kernel link library and includes"
HOMEPAGE="http://www.mISDN.org"
SRC_URI="http://www.linux-call-router.de/download/lcr-1.7/${MY_P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

RDEPEND="sys-libs/ncurses"
DEPEND="${RDEPEND}"

S="${WORKDIR}/mISDNuser"

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed"

	dodoc AUTHORS COPYING.LIB LICENSE NEWS README
}
