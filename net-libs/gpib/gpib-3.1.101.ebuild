EAPI="4"

inherit eutils

DESCRIPTION="GPIB Library (seems to be usefull only for 2.4 kernel)"
HOMEPAGE=""
SRC_URI="https://iftools.com/download/ctb/linux-${P}.tar.gz"

IUSE=""

SLOT="0"

LICENSE="GPL"
KEYWORDS="-*"

RDEPEND=""
DEPEND="${RDEPEND}"

S="${WORKDIR}/linux-${P}"
