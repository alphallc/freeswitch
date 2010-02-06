#
# Copyright (C) 2010 Stefan Knoblich <s.knoblich@axsentis.de>
#
# Distributed under the terms of the GNU General Public License 2
# see http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt for
# more information
#

EAPI="2"

inherit git flag-o-matic

IUSE="doc"

DESCRIPTION="ISDN (Q.931; PRI/BRI) protocol stack"
HOMEPAGE="http://oss.axsentis.de/gitweb/?p=libisdn.git;a=summary"
#SRC_URI="http://oss.axsentis.de/"

EGIT_REPO_URI="http://oss.axsentis.de/git/libisdn.git"
EGIT_BOOTSTRAP="./autogen.sh"

SLOT="0"

LICENSE="BSD"
KEYWORDS=""

RDEPEND="virtual/libc"

DEPEND="${RDEPEND}
	>=sys-devel/autoconf-2.61
	>=sys-devel/automake-1.10
	doc? ( app-doc/doxygen )"

src_configure() {
	econf || die "econf failed"
}

src_compile() {
	emake || die "emake failed"

	# build API documentation
	use doc && \
		emake doxygen || die "building API docs failed"
}

src_install() {
	emake DESTDIR="${D}" install || die "make install failed"

	dodoc CREDITS TODO

	# install API documentation
	use doc && \
		cp -dPR docs/html "${D}/usr/share/doc/${PF}"
}