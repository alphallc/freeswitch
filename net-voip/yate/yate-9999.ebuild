# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

IUSE="dahdi debug doc gsm mysql postgres sctp speex ssl h323 ilbc qt4 spandsp amr zaptel wanpipe sse2"

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
	SRC_URI="http://yate.null.ro/tarballs/yate4/${MY_P}.tar.gz"
fi

KEYWORDS="~amd64"
SLOT="0"
LICENSE="GPL-2"

RDEPENDS="
        h323? ( dev-libs/pwlib
                net-libs/openh323 )
        ilbc? ( dev-libs/ilbc-rfc3951 )
        mysql? ( virtual/mysql )
        postgres? ( dev-db/postgresql-base )
        qt4? ( x11-libs/qt-core:4
                x11-libs/qt-gui:4 )
        spandsp? ( >=media-libs/spandsp-0.0.3 )
        amr? ( media-libs/opencore-amr )
	alsa? ( media-libs/alsa-lib )
	ssl? ( dev-libs/openssl )
	gsm? ( media-sound/gsm )
	speex? ( media-sound/speex )
	sctp? ( net-misc/lksctp-tools )
	zaptel? ( net-misc/zaptel )
	wanpipe? ( net-misc/wanpipe )
	dahdi? ( net-misc/dahdi )"

DEPENDS="
	${RDEPENDS}
	${SVN_DEPENDS}"

S="${WORKDIR}/${PN}"

src_configure() {
	use debug && append-cflags -DDEBUG=1

#                --without-doxygen \
#                --without-kdoc \
	econf \
                --disable-internalregex \
                --without-coredumper \
                --with-archlib=$(get_libdir) \
		$(use_enable dahdi)	\
                $(use_with gsm libgsm) \
                $(use_with amr amrnb /usr) \
                $(use_with h323 openh323 /usr) \
                $(use_with h323 pwlib /usr) \
                $(use_enable ilbc) \
                $(use_with mysql mysql /usr) \
                $(use_enable wanpipe wpcard) \
                $(use_with wanpipe wphwec /usr) \
                $(use_with postgres libpq /usr) \
                $(use_with qt4 libqt4) \
                $(use_enable sctp) \
                $(use_enable sse2) \
                $(use_with spandsp) \
                $(use_with speex libspeex) \
                $(use_with ssl openssl) \
		$(use_enable zaptel)	\
		|| die "configure failed"
}

#src_compile() {
#	emake -j1 DESTDIR="${D}" || die "make failed"
#}

src_install() {
	use doc && (
		emake DESTDIR="${D}" install || die "make install failed"
	) || (
		emake DESTDIR="${D}" install-noapi check-ldconfig || die "make install failed"
	)
#		emake DESTDIR="${D}" apidocs || die "make apidocs failed"
#		emake -j1 DESTDIR="${D}" install || die "make install failed"
	dodoc COPYING ChangeLog README
	dodoc docs/*.html docs/*.dia
}
