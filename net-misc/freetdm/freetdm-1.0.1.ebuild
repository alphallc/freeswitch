EAPI="2"
IUSE="pcap"

inherit eutils

DESCRIPTION=""
HOMEPAGE="http://www.freeswitch.org/"
SRC_URI="ftp://ftp.sangoma.com/linux/${PN}/${P}.tar.gz"

KEYWORDS="~amd64 ~x86"
SLOT="0"
LICENSE="BSD"

RDEPEND="virtual/libc
	pcap? ( >=net-libs/libpcap-1.0.0 )"
#	libpri? ( >=net-libs/libpri-1.4.0 )"

DEPEND="${RDEPEND}"

src_configure() {
	econf \
		--with-modinstdir="/usr/$(get_libdir)/${PN}" \
		$(use_with pcap pcap /usr) || die "econf failed"

# fix --without-libpri b0rkage
#		$(use_with pcap pcap /usr) \
#		$(use_with libpri) || die "econf failed"
}

src_install() {
	emake DESTDIR="${D}" install

	dodoc AUTHORS COPYING ChangeLog INSTALL NEWS README TODO

	# remove static module files
	for x in "${D}/usr/$(get_libdir)/${PN}/"*.{a,la}; do
		rm -f "${x}" || die "failed to remove \"${x}\""
	done
}
