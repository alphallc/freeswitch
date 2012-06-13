# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: This ebuild is from freeswitch overlay; Bumped by mva; $
# Distributed under the terms of the GNU General Public License 2
# see http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt for
# more information
#

EAPI="4"

inherit autotools

IUSE=""

DESCRIPTION="Stand-alone version of the WebKit JavaScript engine"
HOMEPAGE="http://oss.axsentis.de/"

if [[ "${PV}" = "9999" ]]; then
	inherit git-2
	EGIT_REPO_URI="http://oss.axsentis.de/git/libSquirrelFish.git"
else
	SRC_URI="http://oss.axsentis.de/"
fi

KEYWORDS="~amd64 ~x86"

SLOT="0"
LICENSE="LGPL-2"

RDEPEND="virtual/libc
	 dev-libs/icu"

DEPEND="${RDEPEND}
	sys-devel/flex
	sys-devel/bison
	dev-lang/perl"

S="${WORKDIR}/${PN}"

src_unpack() {
	if [[ "${PV}" = "9999" ]]; then
		git-2_src_unpack
	else
		default_src_unpack
	fi

	cd "${S}"
	# eautoreconf doesn't work here,
	# aclocal dies with a circular dependency error
	AT_M4DIR="Source/autotools" eautoreconf
}

src_install() {
	emake DESTDIR="${D}" install || die "make install failed"

	# install docs
	dodoc Source/JavaScriptCore/{COPYING.LIB,AUTHORS,THANKS}
}
