DESCRIPTION="an open-source implementation of the Secure Real-time Transport Protocol (SRTP)"
HOMEPAGE="http://srtp.sourceforge.net/srtp.html"
LICENSE="BSD-Cisco"

SRC_URI="http://srtp.sourceforge.net/srtp-${PV}.tgz"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="debug doc syslog"

DEPEND=""
RDEPEND="${DEPEND}"

S="${WORKDIR}/srtp"

src_compile() {
	econf \
		--enable-pic \
		$(use_enable debug) \
		$(use_enable syslog) \
	|| die "econf failed"
	emake || die "emake failed"
}

src_install() {
	einstall || die "einstall failed"
	if use doc; then
		dodoc doc/*.txt doc/*.pdf
	fi
}
