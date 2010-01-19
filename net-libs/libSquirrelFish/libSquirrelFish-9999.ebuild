#
# Copyright (C) 2008 Stefan Knoblich <s.knoblich@axsentis.de>
#
# Distributed under the terms of the GNU General Public License 2
# see http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt for
# more information
#

inherit git flag-o-matic autotools

IUSE=""

DESCRIPTION="Stand-alone version of the WebKit JavaScript engine"
HOMEPAGE="http://oss.axsentis.de/"
#SRC_URI="http://oss.axsentis.de/"

EGIT_REPO_URI="http://oss.axsentis.de/git/libSquirrelFish.git"
#EGIT_BOOTSTRAP="./autogen.sh"

SLOT="0"

LICENSE="LGPL-2"
KEYWORDS="~amd64 ~x86"

RDEPEND="virtual/libc
	 dev-libs/icu"

DEPEND="${RDEPEND}
	>=sys-devel/autoconf-2.61
	>=sys-devel/automake-1.10
	sys-devel/flex
	sys-devel/bison
	dev-lang/perl"

S="${WORKDIR}/${PN}"

src_unpack() {
	git_src_unpack

	cd "${S}"
	eautoreconf
}

src_compile() {
	# wrong order of libs in configure script
	filter-ldflags -Wl,--as-needed

	econf || die "econf failed"
	emake || die "emake failed"
}

src_install() {
	emake DESTDIR="${D}" install || die "make install failed"

	# install docs
	dodoc README INSTALL JavaScriptCore/{COPYING.LIB,AUTHORS,THANKS}
}
