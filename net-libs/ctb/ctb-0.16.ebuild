# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
inherit eutils

DESCRIPTION="Communication toolbox library"
HOMEPAGE=""
SRC_URI="https://iftools.com/download/${P/-//}/lib${P}.tar.gz"

IUSE="-gpib debug"

SLOT="0"

LICENSE="GPL"
KEYWORDS="~amd64 ~x86"

RDEPEND="gpib? ( net-libs/gpib )"
DEPEND="${RDEPEND}"

S="${WORKDIR}/lib${P}/build"

QA_SONAME="usr/lib/lib${P}.so"

src_prepare() {
	epatch "${FILESDIR}/Makefile.patch"
	sed -e "s#prefix .*#prefix ?= /usr#" -i GNUmakefile
}

src_install() {
	use debug && DEBUG=1
	use gpib && GPIB=1
	emake DEBUG=${DEBUG:-0} GPIB=${GPIB:-0} DESTDIR="${D}" install || die "Failed to install"
}
