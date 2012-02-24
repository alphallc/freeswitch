WANT_AUTOCONF='2.5'
AT_M4DIR='m4'
inherit autotools
inherit flag-o-matic

MyPN="${PN/lib/}"
MyPV="${PV/_/}"
MyP="${MyPN}-${MyPV}"
DESCRIPTION="an open source, multiplatform library for creating telephony solutions that interoperate with Asterisk, the Open Source PBX"
HOMEPAGE="http://${MyPN}.wiki.sourceforge.net/"
LICENSE="GPL-2 LGPL-2"

SRC_URI="mirror://sourceforge/${MyPN}/${MyP}.tar.gz"
SLOT="0"
KEYWORDS="~arm ~x86"
IUSE="ogg theora"

RESTRICT="mirror"  # libgsm is included in tarball

DEPEND='
	>=media-libs/portaudio-19_alpha0
	media-sound/gsm
	>=media-libs/speex-1.2_alpha0
	ogg? ( >=media-libs/libogg-1.1.3 )
	theora? ( >=media-libs/libtheora-1.0_alpha7 )
	media-video/ffmpeg
'
# NOTE: bundled libiax2 is FORKED :<
# NOTE: for some reason, ffmpeg isn't really optional
# TODO: ilbc, oggz, vidcap(last dep required for video)
RDEPEND="${DEPEND} "'
'

S="${WORKDIR}/${MyP}"

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}/${MyPN}-lib-only.patch"
	sed -i 's:ffmpeg/:libavcodec/:' lib/codec_ffmpeg.c
	eautoreconf
}

src_compile() {
	append-flags -I/usr/include/iax
	econf \
		--disable-video \
		$(use_with ogg) \
		$(use_with theora) \
		--disable-clients \
		|| die 'econf failed'
	emake || die 'emake failed'
}

src_install() {
	emake DESTDIR="${D}" install || die 'emake install failed'
}
