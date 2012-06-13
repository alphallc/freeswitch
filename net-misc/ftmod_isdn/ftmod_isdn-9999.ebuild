# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: This ebuild is from freeswitch overlay; Bumped by mva; $
# Distributed under the terms of the GNU General Public License 2
# see http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt for
# more information
#

EAPI="4"

inherit git

IUSE="pcap"

DESCRIPTION="ISDN (Q.931; PRI/BRI) protocol module for FreeTDM"
HOMEPAGE="http://oss.axsentis.de/gitweb/?p=ftmod_isdn.git;a=summary"
#SRC_URI="http://oss.axsentis.de/"

EGIT_REPO_URI="http://oss.axsentis.de/git/ftmod_isdn.git"
EGIT_BOOTSTRAP="./autogen.sh"

SLOT="0"

LICENSE="BSD"
KEYWORDS=""

RDEPEND="virtual/libc
	 ~net-libs/libisdn-${PV}
	 net-voip/freeswitch[freeswitch_modules_freetdm]
	 pcap? ( net-libs/libpcap )"

DEPEND="${RDEPEND}
	>=sys-devel/autoconf-2.61
	>=sys-devel/automake-1.10"

src_configure() {
	# NOTE: temporarily using --with-freetdm
	#       will be replaced by pkgconfig detection
	econf \
		--with-freetdm="/opt/freeswitch" \
		--with-freetdm-modules-dir="/opt/freeswitch/mod" \
		$(use_with pcap) || die "econf failed"
}

src_compile() {
	emake || die "emake failed"
}

src_install() {
	emake DESTDIR="${D}" install || die "make install failed"

	# install docs
	dodoc README COPYING

	# remove .la files
	find "${D}" -type f -name "*.la" -exec rm {} \;
}
