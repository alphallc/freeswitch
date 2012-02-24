DESCRIPTION="Cross Platform Jingle (Google Talk) voip signaling library"
HOMEPAGE="http://freeswitch.org/dingaling_docs/"
LICENSE="MPL-1.1"

FS_P='freeswitch-1.0.1'
SRC_URI="http://files.freeswitch.org/${FS_P}.tar.gz"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="debug"

DEPEND="
	=dev-libs/apr-1*
	dev-libs/iksemel
"
RDEPEND="${DEPEND}"

subS="${FS_P}/libs/${PN}"
S="${WORKDIR}/${subS}"

inherit autotools libtool

src_unpack() {
	tar -xzf "${DISTDIR}/${A}" "${subS}"
	cd "${S}"
	epatch "${FILESDIR}/${PN}-system-libs.patch"
	eautoreconf
}

src_compile() {
	econf \
		$(use_enable debug) \
	|| die "econf failed"
	emake || die "emake failed"
}

src_install() {
	einstall || die "einstall failed"
	insinto /usr/lib/pkgconfig
	newins "${FILESDIR}/${P}.pc" "${PN}.pc"
}
