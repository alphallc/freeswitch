# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: This ebuild is from freeswitch overlay; Bumped by mva; $

EAPI="4"

inherit git-2 flag-o-matic

IUSE=""

DESCRIPTION="SSH Console module for FreeSWITCH"
HOMEPAGE="http://oss.axsentis.de/"

EGIT_REPO_URI="http://oss.axsentis.de/git/mod_ssh.git"
EGIT_BOOTSTRAP="./bootstrap.sh"

SLOT="0"

LICENSE="BSD"
KEYWORDS=""

RDEPEND="virtual/libc
	 dev-libs/openssl
	 net-voip/freeswitch"

DEPEND="${RDEPEND}
	>=sys-devel/autoconf-2.61
	>=sys-devel/automake-1.10"

#S="${WORKDIR}/${PN}-${MY_PV}"

src_prepare() {
	default
	epatch_user
}

#src_compile() {
#	# wrong order of libs in configure script
#	filter-ldflags -Wl,--as-needed
#
#	econf || die "econf failed"
#	emake || die "emake failed"
#}

src_install() {
	emake DESTDIR="${D}" install || die "make install failed"

	# install docs
	dodoc README config/ssh.conf.xml
	newdoc COPYING COPYING.mod_ssh
	newdoc libssh/COPYING COPYING.libssh
}
