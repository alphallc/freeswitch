# Portions Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-libs/sofia-sip/sofia-sip-1.12.8.ebuild,v 1.1 2008/04/10 23:38:34 tester Exp $

EAPI="1"

DESCRIPTION="RFC3261 compliant SIP User-Agent library"
HOMEPAGE="http://sofia-sip.sourceforge.net/"

EDARCS_REPOSITORY="http://${PN}.org/repos/${PN}"
inherit darcs

SLOT="0"
LICENSE="LGPL-2.1"
KEYWORDS=""
IUSE="glib ipv6 ntlm sctp ssl +stun"

RDEPEND="
	glib? ( dev-libs/glib )
	ssl? ( dev-libs/openssl )"
DEPEND="${RDEPEND}"

src_unpack() {
	darcs_src_unpack
	
	cd "${S}"
	sh autogen.sh
}

src_compile() {
	econf \
		$(use_enable ipv6 ip6) \
		$(use_enable sctp) \
		$(use_enable stun) \
		$(use_enable ntlm) \
		$(use_with glib) \
		$(use_with ssl openssl) \
	|| die "econf failed"
	emake || die "emake failed"
}

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed"

	dodoc ChangeLog COPYRIGHTS README TODO
}
