# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: This ebuild is from freeswitch overlay; Bumped by mva; $

EAPI="4"

inherit git flag-o-matic

IUSE=""

DESCRIPTION="Experimental JavaScript module for FreeSWITCH"
HOMEPAGE="http://oss.axsentis.de/"

EGIT_REPO_URI="http://oss.axsentis.de/git/mod_squirrelfish.git"
EGIT_BOOTSTRAP="./bootstrap.sh"

SLOT="0"

LICENSE="MPL-1.1"
KEYWORDS="~amd64 ~x86"

RDEPEND="virtual/libc
	 net-libs/libSquirrelFish
	 net-voip/freeswitch"

DEPEND="${RDEPEND}
	>=sys-devel/autoconf-2.61
	>=sys-devel/automake-1.10"

src_compile() {
	# wrong order of libs in configure script
	filter-ldflags -Wl,--as-needed

	econf || die "econf failed"
	emake || die "emake failed"
}

src_install() {
	emake DESTDIR="${D}" install || die "make install failed"

	# install docs
	dodoc README COPYING
}
