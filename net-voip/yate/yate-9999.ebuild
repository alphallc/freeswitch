
EAPI="3"

IUSE="alsa dahdi debug doc gsm mysql postgres sctp speex ssl"

inherit flag-o-matic

MY_P="${P/_/-}"

DESCRIPTION="Yet Another Telephony Engine"
HOMEPAGE="http://yate.null.ro/"

if [[ "${PV}" = "9999" ]]
then
	inherit subversion
	ESVN_REPO_URI="http://yate.null.ro/svn/yate/trunk"
	ESVN_BOOTSTRAP="./autogen.sh"
	SVN_DEPENDS="media-sound/sox"
else
	SRC_URI="http://yate.null.ro/tarballs/yate3/${MY_P}.tar.gz"
fi

KEYWORDS="~amd64"
SLOT="0"
LICENSE="GPL-2"

RDEPENDS="
	alsa? ( media-libs/alsa-lib )
	ssl? ( dev-libs/openssl )
	gsm? ( media-sound/gsm )
	speex? ( media-sound/speex )
	mysql? ( dev-db/mysql )
	postgres? ( dev-db/postgresql-base )
	sctp? ( net-misc/lksctp-tools )
	dahdi? ( net-misc/dahdi )"

DEPENDS="
	${RDEPENDS}
	${SVN_DEPENDS}"

S="${WORKDIR}/${PN}"

src_configure() {
	use debug && append-cflags -DDEBUG=1

	econf \
		--without-libqt4 	\
		--without-coredumper	\
		--disable-wpcard --disable-tdmcard --disable-wanpipe \
		$(use_enable sctp)	\
		$(use_enable dahdi)	\
		$(use_with gsm libgsm)	\
		$(use_with speex libspeex)	\
		$(use_with postgres libpq)	\
		$(use_with mysql)		\
		|| die "configure failed"
}

src_compile() {
	emake -j1 || die "make failed"
}

src_install() {
	emake -j1 DESTDIR="${D}" install || die "make install failed"

	# remove yate installed docs
	rm -r "${D}/usr/share/doc"

	dodoc COPYING ChangeLog README
	dodoc docs/*.html docs/*.dia

	if use doc; then
		einfo "Installing API documentation"
		insinto "/usr/share/doc/${PF}"
		doins -r docs/api
	fi
}
