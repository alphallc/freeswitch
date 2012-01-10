#
# Copyright (C) 2010 Stefan Knoblich <s.knoblich@axsentis.de>
#
# Distributed under the terms of the GNU General Public License 2
# see http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt for
# more information
#

EAPI="2"

inherit git-2 flag-o-matic

IUSE="doc lua pcap static-libs"

DESCRIPTION="ISDN (Q.931; PRI/BRI) protocol stack"
HOMEPAGE="http://www.openisdn.net/"
#SRC_URI="http://files.openisdn.net/"

EGIT_REPO_URI="http://git.openisdn.net/libisdn.git/"
EGIT_BOOTSTRAP="./autogen.sh"

SLOT="0"

LICENSE="BSD"
KEYWORDS=""

RDEPEND="virtual/libc"

DEPEND="${RDEPEND}
	>=sys-devel/autoconf-2.61
	>=sys-devel/automake-1.10
	doc? ( app-doc/doxygen )
	lua? ( dev-lang/lua )
	pcap? ( >=net-libs/libpcap-1.0 )"

src_configure() {
	local myconf=""

	if [ -n "${FREETDM_SOURCE_DIR}" ]
	then
		myconf="${myconf} --with-freetdm=${FREETDM_SOURCE_DIR}"
	fi

	econf \
		$(use_with lua) \
		$(use_with pcap) \
		$(use_enable static-libs static) \
		${myconf} || die "econf failed"
}

src_compile() {
	emake || die "emake failed"

	# build API documentation
	if use doc ; then
		emake doxygen || die "building API docs failed"
	fi
}

src_install() {
	emake DESTDIR="${D}" install || die "make install failed"

	dodoc CREDITS TODO

	# install API documentation
	use doc && \
		cp -dPR docs/html "${D}/usr/share/doc/${PF}"
}
