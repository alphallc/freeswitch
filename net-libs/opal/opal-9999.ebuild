# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit eutils flag-o-matic subversion autotools

DESCRIPTION="C++ class library normalising numerous telephony protocols"
HOMEPAGE="http://www.opalvoip.org/"

ESVN_REPO_URI="https://opalvoip.svn.sourceforge.net/svnroot/opalvoip/opal/trunk"

LICENSE="MPL-1.0"
SLOT="0"
KEYWORDS=""
IUSE="debug doc java"

S="${WORKDIR}/opal"

RDEPEND=">=net-libs/ptlib-9999
	>=media-video/ffmpeg-0.4.7
	media-libs/speex
	java? ( virtual/jdk )"

DEPEND="${RDEPEND}
	doc? ( app-doc/doxygen )"

pkg_setup() {
	if use debug && ! built_with_use net-libs/ptlib debug; then
		eerror "You need to build net-libs/ptlib with USE=debug enabled."
		die "net-libs/ptlib has to be built with USE=debug"
	fi

	if ! use debug && built_with_use net-libs/ptlib debug; then
		eerror "You need to build net-libs/ptlib without USE=debug."
		die "net-libs/ptlib has not to be built with USE=debug"
	fi

	# opal can't build with --as-needed
	append-ldflags -Wl,--no-as-needed
}

src_unpack() {
	subversion_src_unpack
	cd "${S}"

	# recreate configure etc.
	eautoreconf
}

src_compile() {
	local makeopts

	# zrtp doesn't depend on net-libs/libzrtpcpp but on libzrtp from
	# http://zfoneproject.com/ that is not in portage
	econf \
		$(use_enable debug) \
		$(use_enable java) \
		--enable-plugins \
		--disable-localspeex \
		--disable-zrtp \
		|| die "econf failed"

	if use debug; then
		makeopts="debug"
	else
		makeopts="opt"
	fi

	emake ${makeopts} || die "emake failed"

	if use doc; then
		emake doc || die "emake doc failed"
	fi
}

src_install() {
	emake PREFIX=/usr DESTDIR="${D}" install || die "emake install failed"

	if use doc; then
		dohtml -r html/* docs/* || die "documentation installation failed"
	fi
}
