# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
IUSE=""

inherit eutils

MY_PN="${PN/-/_}"
MY_P="${MY_PN}-${PV}"

DESCRIPTION="Sangoma ISDN library"
HOMEPAGE="http://www.sangoma.com/"
SRC_URI="amd64? ( ftp://ftp.sangoma.com/linux/${MY_PN}/${MY_P}.x86_64.tgz )
	 x86? ( ftp://ftp.sangoma.com/linux/${MY_PN}/${MY_P}.i686.tgz )"

RESTRICT="mirror strip"

KEYWORDS="-* ~amd64 ~x86"
SLOT="0"
LICENSE="unknown"

RDEPEND="net-misc/wanpipe"
DEPEND="${RDEPEND}"

S="${WORKDIR}/${MY_P}"

src_unpack() {
	unpack ${A}

	if use amd64 ; then
		ln -s "${S}.x86_64" "${S}" || die "Failed to create symlink"
	else
		ln -s "${S}.i686"   "${S}" || die "Failed to create symlink"
	fi
}

src_prepare() {
	sed -i -e "/@ldconfig/d" Makefile || die "sed failed"
}

src_install() {
	dodir "/usr/$(get_libdir)"

	emake DESTDIR="${D}/usr" install || die "emake install failed"

	# generate libsng_ss7.so.X -> libsng_ss7.so symlink
	ldconfig -n "${D}/usr/$(get_libdir)" || die "failed to generate versioned .so symlinks"

	[ ! -e "${ROOT}/usr/$(get_libdir)/libssl.so.6" ] && {
		einfo "Creating libssl.so.6 compat symlink"
		ln -s "libssl.so" "${D}/usr/$(get_libdir)/libssl.so.6" || die "Failed to create libssl.so.6 compat symlink"
	}
}
