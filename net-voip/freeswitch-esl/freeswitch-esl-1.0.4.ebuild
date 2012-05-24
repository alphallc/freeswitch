#
# Copyright (C) 2009 Stefan Knoblich <s.knoblich@axsentis.de>
#
# Distributed under the terms of the GNU General Public License 2
# see http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt for
# more information
#

EAPI="2"

inherit subversion autotools flag-o-matic python

DESCRIPTION="FreeSWITCH Event-Socket client library and language bindings"
HOMEPAGE="http://www.freeswitch.org/"

if [ "${PV}" = "9999" ]; then
	ESVN_REPO_URI="http://svn.freeswitch.org/svn/freeswitch/trunk"
	ESVN_PROJECT="freeswitch"
#	ESVN_BOOTSTRAP="bootstrap.sh"
else
	SRC_URI="http://files.freeswitch.org/freeswitch-${PV}.tar.bz2"
	S="${WORKDIR}/freeswitch-${PV}"
fi

LICENSE="MPL-1.1"
KEYWORDS="~amd64 ~x86"
SLOT="0"

IUSE_LANG="ruby php +perl +python lua"

IUSE="${IUSE_LANG}"

#
#
#
RDEPEND="virtual/libc
	lua? ( dev-lang/lua )
	php? ( dev-lang/php )
	perl? ( dev-lang/perl )
	ruby? ( dev-lang/ruby )
	python? ( dev-lang/python )"

# needed for fs_cli
#	dev-libs/libedit
#	sys-libs/ncurses

DEPEND="${RDEPEND}
	>=sys-devel/autoconf-2.60
	>=sys-devel/automake-1.10"


###
# Helper functions
#
esl_modname() {
	[ -z "$1" ] && return 1

	case "$1" in
	"python")
		echo "pymod"
		;;

	*)
		echo "${1#*-}mod"
		;;
	esac
	return 0
}

esl_dorubymod() {
        ( # dont want to pollute calling env
                insinto $(${RUBY:-/usr/bin/ruby} -r rbconfig -e 'print Config::CONFIG["sitearchdir"]')
		insopts -m755
                doins "$@"
        ) || die "failed to install $@"
}

esl_dopymod() {
        ( # dont want to pollute calling env
                insinto $(python_get_sitedir)

		for x in ${@}; do
			insopts -m644 

			[ "${x}" != "${x%.so}" ] && insopts -m755

	                doins "${x}" || die "failed to install ${x}"
		done
        ) || die "failed to install $@"
}

esl_doluamod() {
        ( # dont want to pollute calling env
                insinto /usr/$(get_libdir)/lua/$(${LUA:-/usr/bin/lua} -v 2>&1 | sed -e '1s:^Lua \([0-9]\.[0-9]\)\.[0-9]\+.*:\1:')
		insopts -m755
                doins "$@"
        ) || die "failed to install $@"
}

esl_doperlmod() {
        ( # dont want to pollute calling env
		eval "$(${PERL:-/usr/bin/perl} -V:installvendorarch)"
		eval "$(${PERL:-/usr/bin/perl} -V:installvendorlib)"

		for x in ${@}; do
			target="lib"

			[ "${x}" != "${x%.so}" ] && target="arch"

			case "${target}" in
			"lib")
				insinto "${installvendorlib}"
				insopts -m644
				doins -r "${x}" || die "failed to install ${x}"
				;;
			"arch")
				insinto "${installvendorarch}"
				insopts -m755
				doins "${x}" || die "failed to install ${x}"
				;;
			esac
		done
        ) || die "failed to install $@"
}



###
# main ebuild functions
#

src_unpack() {
	if [ "${PV}" = "9999" ]; then
		subversion_src_unpack
	else
		unpack ${A}
	fi
}

src_prepare() {
	if [ "${PV}" = "9999" ]; then
		subversion_src_prepare
	fi

	#
	# 1. patches for esl modules (*sigh*)
	#
	sed -i -e '/^LOCAL_LDFLAGS/s:^\(.*\):\1 -lpthread:' \
		libs/esl/{ruby,python,perl,lua}/Makefile || die "failed to patch esl modules"

	if use python; then
		python_version || die "Failed to determine current python version"

		sed -i -e "/^LOCAL_/{ s:python-2\.[0-9]:python-${PYVER}:g; s:python2\.[0-9]:python${PYVER}:g }" \
			libs/esl/python/Makefile || die "failed to change python locations in esl python module"
	fi

	#
	# 2. workarounds remove as soon as the fix has been comitted
	#
}

src_configure() {
	#
	# 1. filter some flags known to break things
	#

	# breaks linking freeswitch core lib (missing libdl symbols)
	filter-ldflags -Wl,--as-needed

	# breaks openzap
	filter-flags -fvisibility-inlines-hidden
}

src_compile() {
	local esl_lang

	#
	# 1. filter some flags known to break things
	#

	# breaks linking freeswitch core lib (missing libdl symbols)
	filter-ldflags -Wl,--as-needed

	# breaks openzap
	filter-flags -fvisibility-inlines-hidden

	#
	# 2. build esl modules
	#
	for esl_lang in ${IUSE_LANG//+/}; do
		use ${esl_lang} || continue

		einfo "Building esl module for ${esl_lang}..."
		emake -C libs/esl "$(esl_modname "${esl_lang}")" || die "Failed to build esl module for language \"${esl_lang}\""
	done

	einfo "Building libesl..."
	emake -C libs/esl libesl.a || die "Failed to build libesl"
}


src_install() {
	local esl_lang

	#
	# 1. install esl modules
	#
	if use ruby; then
		einfo "Installing esl module for ruby..."
		esl_dorubymod libs/esl/ruby/ESL.so
	fi

	if use python; then
		einfo "Installing esl module for python..."
		esl_dopymod libs/esl/python/{_ESL.so,ESL.py}
	fi

	if use lua; then
		einfo "Installing esl module for lua..."
		esl_doluamod libs/esl/lua/ESL.so
	fi

	if use php; then
		einfo "Installing esl module for php..."
		emake DESTDIR="${D}" -C libs/esl phpmod-install || die "Failed to install esl module for php"
	fi

	if use perl; then
		einfo "Installing esl module for perl..."
		esl_doperlmod libs/esl/perl/{ESL,ESL.so,ESL.pm}
	fi

	einfo "Installing libesl..."
	dolib libs/esl/libesl.a

	insinto /usr/include/esl
	doins libs/esl/src/include/esl*.h
}

pkg_postinst() { return; }
pkg_preinst()  { return; }
