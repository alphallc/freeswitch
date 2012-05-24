#
# Copyright (C) 2010 Stefan Knoblich <s.knoblich@axsentis.de>
#
# Distributed under the terms of the GNU General Public License 2
# see http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt for
# more information
#

EAPI="2"

inherit git

IUSE="pcap"

DESCRIPTION="ISDN (Q.931; PRI/BRI) protocol module for OpenZAP"
HOMEPAGE="http://oss.axsentis.de/gitweb/?p=ozmod_isdn.git;a=summary"
#SRC_URI="http://oss.axsentis.de/"

EGIT_REPO_URI="http://oss.axsentis.de/git/ozmod_isdn.git"
EGIT_BOOTSTRAP="./autogen.sh"

SLOT="0"

LICENSE="BSD"
KEYWORDS=""

RDEPEND="virtual/libc
	 ~net-libs/libisdn-${PV}
	 net-voip/freeswitch[freeswitch_modules_openzap]
	 pcap? ( net-libs/libpcap )"

DEPEND="${RDEPEND}
	>=sys-devel/autoconf-2.61
	>=sys-devel/automake-1.10"

src_configure() {
	# NOTE: temporarily using --with-openzap
	#       will be replaced by pkgconfig detection
	econf \
		--with-openzap="/opt/freeswitch" \
		--with-openzap-modules-dir="/opt/freeswitch/mod" \
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
