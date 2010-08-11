EAPI="2"

IUSE=""

inherit base

DESCRIPTION="Lightweight message passing library"
HOMEPAGE="http://www.zeromq.org/"
SRC_URI="http://www.zeromq.org/local--files/area:download/${P}.tar.gz"

SLOT="0"
LICENSE="|| ( LGPL-3 GPL-3 )"
KEYWORDS="~amd64 ~x86"

S="${WORKDIR}/${P}"

DEPEND="dev-util/pkgconfig"

DOCS=("AUTHORS" "COPYING.LESSER" "INSTALL" "NEWS" "COPYING" "ChangeLog" "README")
