DESCRIPTION="(S)ort (T)ransportable (F)ramed (U)tterances"
HOMEPAGE="http://freeswitch.org/"
LICENSE="MIT"

FS_P='freeswitch-1.0.1'
SRC_URI="http://files.freeswitch.org/${FS_P}.tar.gz"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND=""
RDEPEND="${DEPEND}"

subS="${FS_P}/libs/${PN}"
S="${WORKDIR}/${subS}"

src_unpack() {
	tar -xzf "${DISTDIR}/${A}" "${subS}"
}

src_compile() {
	gcc -c stfu.c -o stfu.o || die "compile failed"
}

src_install() {
	dolib stfu.o
	insinto /usr/include
	doins stfu.h
}
