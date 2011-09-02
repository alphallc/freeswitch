#
# Copyright (C) 2008-2011 Stefan Knoblich <s.knoblich@axsentis.de>
#
# Distributed under the terms of the GNU General Public License 2
# see http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt for
# more information
#

EAPI="2"
PYTHON_DEPEND="2"

inherit autotools eutils flag-o-matic python

DESCRIPTION="FreeSWITCH telephony platform GIT Head"
HOMEPAGE="http://www.freeswitch.org/"

KEYWORDS="~amd64 ~x86"

if [ "${PV}" = "9999" ]; then
	inherit git
	EGIT_REPO_URI="git://git.freeswitch.org/freeswitch.git"
	EGIT_BOOTSTRAP=""
	KEYWORDS=""
else
	SRC_URI="http://files.freeswitch.org/${P/_/}.tar.bz2"
	S="${WORKDIR}/${P/_/}"
fi

LICENSE="MPL-1.1"
SLOT="0"

IUSE="esl nosamples odbc +resampler sctp libpri"

IUSE_ESL="esl-ruby esl-php esl-perl esl-python esl-lua"

IUSE_MODULES="alsa amr amrwb avmd bv +cdr_csv cdr_pg_csv cdr_sqlite celt cepstral cidlookup +console curl
	+db dialplan_asterisk dialplan_directory dingaling distributor easyroute erlang_event
	flite freetdm fsk +g723_1 g729 gsmopen h26x +hash +ilbc java lcr ldap +limit +local_stream +logfile +lua
	managed memcache mp4 mp4v nibblebill opal osp perl pocketsphinx portaudio portaudio_stream python radius_cdr redis rtmp
	shell_stream shout silk siren skinny skypopen snapshot +sndfile +sofia +spandsp +speex spidermonkey spy +syslog
	+tone_stream tts_commandline unimrcp valet_parking vmd +voicemail
	xml_cdr xml_curl xml_ldap xml_rpc yaml
"

# mod_say_X
IUSE_LINGUAS="de +en es fr it nl ru zh"

# inter-module dependencies
INTER_MODULE_DEPENDS="
	limit:db
	limit:hash
"

# modules need these core functions
CORE_MODULE_DEPENDS="
	nibblebill:odbc
	easyroute:odbc
	lcr:odbc
"

# external dependencies of modules
MODULES_RDEPEND="
	freeswitch_modules_alsa? ( media-libs/alsa-lib )
	freeswitch_modules_radius_cdr? ( net-dialup/freeradius-client )
	freeswitch_modules_xml_curl? ( net-misc/curl )
	freeswitch_modules_xml_ldap? ( net-nds/openldap )
	freeswitch_modules_ldap? ( net-nds/openldap )
	freeswitch_modules_java? ( >=virtual/jdk-1.5 )
	freeswitch_modules_opal? ( >=net-libs/opal-9999[h323,iax]
				   >=net-libs/ptlib-9999 )
	freeswitch_modules_python? ( =dev-lang/python-2* )
	freeswitch_modules_managed? ( >=dev-lang/mono-1.9 )
	freeswitch_modules_nibblebill? ( dev-db/unixODBC )
	freeswitch_modules_easyroute? ( dev-db/unixODBC )
	freeswitch_modules_lcr? ( dev-db/unixODBC )
	freeswitch_modules_skypopen? ( x11-base/xorg-server x11-apps/xhost net-im/skype media-fonts/font-misc-misc media-fonts/font-cursor-misc )
	freeswitch_modules_memcache? ( net-misc/memcached )
	freeswitch_modules_erlang_event? ( dev-lang/erlang )
	freeswitch_modules_shout? ( media-libs/libogg )
	freeswitch_modules_osp? ( >=net-libs/osptoolkit-3.5.0 )
	freeswitch_modules_freetdm? ( libpri? ( >=net-libs/libpri-1.4.0 ) )
	freeswitch_modules_spandsp? ( media-libs/jpeg )
	freeswitch_modules_redis? ( dev-db/redis )
	freeswitch_modules_cdr_pg_csv? ( dev-db/postgresql-base )
"

# external core dependencies
CORE_RDEPEND="
	odbc? ( dev-db/unixODBC )
	esl-lua? ( dev-lang/lua )
	esl-php? ( dev-lang/php )
	esl-perl? ( dev-lang/perl )
	esl-ruby? ( dev-lang/ruby )
	esl-python? ( dev-lang/python )
"

#
#
#
RDEPEND="virtual/libc
	 ${CORE_RDEPEND}
	 ${MODULES_RDEPEND}"

DEPEND="${RDEPEND}
	>=sys-devel/autoconf-2.60
	>=sys-devel/automake-1.10
	sctp? ( kernel_linux? ( net-misc/lksctp-tools ) )"

PDEPEND=">=net-misc/freeswitch-sounds-1.0.14
	 >=net-misc/freeswitch-music-1.0.8"

###
# IUSE merging
#
for x in ${IUSE_MODULES}; do
	IUSE="${IUSE} ${x//[^+]/}freeswitch_modules_${x/+}"
done
for x in ${IUSE_LINGUAS}; do
	IUSE="${IUSE} ${x//[^+]/}linguas_${x/+}"
done

IUSE="${IUSE} ${IUSE_ESL}"


###
# pre-flight checks
#
pkg_setup() {
	local x mod dep error_cnt=0 mod_cnt=0 lang_cnt=0

	ewarn "--- Work-In-Progress ebuild ---"
	epause 5

	#
	# 1. safety check
	#
	for mod in ${IUSE_MODULES}; do
		use freeswitch_modules_${mod/+} && (( mod_cnt++ ))
	done
	if [ "${mod_cnt}" = "0" -a "${FREESWITCH_CORE_ONLY}" != "yes" ]; then
		eerror "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
		eerror "No modules selected for build! Are you sure you only want the FreeSWITCH core?"
		eerror "This isn't a good idea, usually..."
		eerror ""
		eerror "If you really know what you are doing set FREESWITCH_CORE_ONLY="yes" in your make.conf"
		eerror "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
		die "FREESWITCH_MODULES empty / no modules selected for build"
	fi

	#
	# 2. check prerequisites
	#
	if use freeswitch_modules_cepstral; then

		SWIFT_HOME="${SWIFT_HOME:-/opt/swift}"

		if [ ! -d "${SWIFT_HOME}" ]; then
			eerror "No cepstral installation found in \"${SWIFT_HOME}\""
			die "No cepstral installation found in \"${SWIFT_HOME}\""
		fi

		if [ ! -e "${SWIFT_HOME}/lib/libswift.so" ]; then
			eerror "Cepstral library not found in \"${SWIFT_HOME}\""
			die "Cepstral library not found!"
		fi

		einfo "Cepstral installation found in \"${SWIFT_HOME}\""

		export SWIFT_HOME
	fi

	if use freeswitch_modules_python ; then

		if built_with_use --missing false dev-lang/python nothreads ; then
			echo
			eerror "python: FreeSWITCH needs python with threads support"
			eerror "python: please reemerge python with \"nothreads\" useflag disabled"
			echo
			(( error_cnt++ ))

		elif ! built_with_use --missing true dev-lang/python threads ; then
			echo
			eerror "python: FreeSWITCH needs python with threads support"
			eerror "python: please reemerge python with \"threads\" useflag enabled"
			echo
			(( error_cnt++ ))
		fi
	fi

	if use freeswitch_modules_perl && ! built_with_use dev-lang/perl ithreads; then
		echo
		eerror "perl: FreeSWITCH needs perl with threads support"
		eerror "perl: please reemerge libperl and perl with \"ithreads\" useflag enabled"
		echo

		(( error_cnt++ ))
	fi

	if use freeswitch_modules_xml_ldap && ! built_with_use net-nds/openldap sasl; then
		echo
		eerror "ldap: OpenLDAP with sasl support is required"
		eerror "ldap: please reemerge openldap with \"sasl\" useflag enabled"
		echo

		(( error_cnt++ ))
	fi

	if [ "${error_cnt}" != "0" ]; then
		echo
		eerror "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
		eerror "Build-time requirements not met!"
		eerror "Please correct above error messages or disable the useflags and re-emerge ${PN}"
		eerror "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
		die "Build-time requirements not met: ${error_cnt} errors"
	fi

	#
	# 3. check inter-module dependencies
	#
	einfo "Checking inter-module dependencies..."
	for x in ${INTER_MODULE_DEPENDS}; do
		mod="${x%:*}"
		dep="${x#*:}"

		if use "freeswitch_modules_${mod}" && ! use "freeswitch_modules_${dep}"; then
			# check if this module has an external dependency
			if $(echo "${MODULES_RDEPEND}" | grep -q "freeswitch_modules_${dep}\?"); then
				eerror "Module \"${mod}\" requires module \"${dep}\","
				eerror "can not auto-enable this feature because it has an unmet external dependency!"
				(( error_cnt++ ))
			else
				ewarn "Module \"${mod}\" requires module \"${dep}\" to be enabled, auto-enabling!"
				FREESWITCH_AUTO_USE="${FREESWITCH_AUTO_USE} freeswitch_modules_${dep}"
			fi
		fi
	done

	#
	# 4. check core dependencies
	#
	einfo "Checking core dependencies..."
	for x in ${CORE_MODULE_DEPENDS}; do
		mod="${x%:*}"
		dep="${x#*:}"

		if has "freeswitch_modules_${mod}" ${FREESWITCH_AUTO_USE} ${USE} && ! use "${dep}"; then
			# check if this core option has an external dependency
			if $(echo "${CORE_RDEPEND}" | grep -q "${dep}\?"); then
				eerror "Module \"${mod}\" requires core useflag \"${dep}\","
				eerror "can not auto-enable this feature because it has an unmet external dependency!"
				(( error_cnt++ ))
			else
				ewarn "Module \"${mod}\" requires core useflag \"${dep}\", auto-enabling!"
				FREESWITCH_AUTO_USE="${FREESWITCH_AUTO_USE} ${dep}"
			fi
		fi
	done

	if [ "${error_cnt}" != "0" ]; then
		echo
		eerror "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
		eerror "Inter-module and/or module-core dependencies not met and auto-enabling failed because of unmet"
		eerror "external dependencies! This is for your own security, sorry..."
		eerror "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
		die "Please read the error messages above and fix the listed issues"
	fi

	#
	# 5. language checks
	#
	einfo "Checking selected languages..."
	for x in ${IUSE_LINGUAS}; do
		mod="${x/+}"
		use linguas_${mod} && (( lang_cnt++ ))
	done
	if [ "${mod_cnt}" = "0" ]; then
		echo
		ewarn "No languages selected, enabling \"en\" as a fallback"

		FREESWITCH_AUTO_USE="${FREESWITCH_AUTO_USE} linguas_en"
	fi

	#
	# 6. create user + group
	#
	enewgroup freeswitch
	enewuser freeswitch -1 -1 /opt/freeswitch freeswitch

	#
	# DONE
	#
	export FREESWITCH_AUTO_USE="${FREESWITCH_AUTO_USE}"

	#
	# 7. set active python version
	#
	if use freeswitch_modules_python || use esl-python
	then
		python_set_active_version 2
		python_pkg_setup
	fi
}


###
# ABI compat safety check functions
#

fs_abi_generate_symbols_array() {
	local libfile="$1" syms

	if [ ! -f "${libfile}" ]; then
		eerror "Library ${libfile} does not exist"
		return 1
	fi

	syms="$(nm -DS -t d --defined-only "${libfile}" | sed -e 's:0\+\([1-9][0-9]*\):\1:g' | awk -v IGNORECASE=1 '/switch_.+/{ print "\tsymbols[\""$4"\"]="$2";" }')"
	if [ -z "${syms}" ]; then
		eerror "Failed to create list of exported libfreeswitch symbols"
		return 1
	fi

	echo "${syms}"
	return 0
}

fs_check_core_abi_compat() {
	local libfreeswitch libfreeswitch_syms

	if [ "${EBUILD_PHASE}" != "preinst" ]; then
		eerror "fs_check_core_abi_compat() can only be called from pkg_preinst"
		return 1
	fi

	# no need to check anything if there's no previous install...
	[ ! -e "${ROOT}"/opt/freeswitch/mod ] && return 0

	libfreeswitch="$(ls -1 "${ROOT}"/opt/freeswitch/lib/libfreeswitch.so.*.*.*)"
	if [ ! -f "${libfreeswitch}" ]; then
		eerror "Failed to locate old libfreeswitch"
		return 1
	fi

	libfreeswitch_syms="$(fs_abi_generate_symbols_array "${libfreeswitch}")"
	if [ -z "${libfreeswitch_syms}" ]; then
		eerror "Failed to create list of exported libfreeswitch symbols"
		return 1
	fi

	cat > "${T}/symbols_check_abi.awk" <<-EOF
	BEGIN{
	${libfreeswitch_syms}
	}

	/switch_.+/{
	    sym=\$4
            sym_len=\$2

	    if (! sym in symbols)
	        print sym

	    if (symbols[sym] != sym_len)
	        print sym
	}
	EOF

	libfreeswitch="$(ls -1 "${D}"/opt/freeswitch/lib/libfreeswitch.so.*.*.*)"
	if [ ! -f "${libfreeswitch}" ]; then
		eerror "Failed to locate new libfreeswitch"
		return 1
	fi

	einfo "Checking for incompatible ABI changes in FreeSWITCH core library..."
	changed_syms="$(nm -DS -t d --defined-only "${libfreeswitch}" | sed -e 's:0\+\([1-9][0-9]*\):\1:g' | awk -v IGNORECASE=1 -f "${T}/symbols_check_abi.awk")"
	if [ -n "${changed_syms}" ]; then
		einfo "Some FreeSWITCH API functions have been modified, external modules may have to be rebuild"
	fi

	export FREESWITCH_ABI_CHANGED_SYMBOLS="${changed_syms}"
}

fs_check_modules_api_compat() {
	local x mod name libfreeswitch libfreeswitch_syms
	local sym need_upgrade module_syms
	local mod_warn_list="" mod_error_list=""

	if [ "${EBUILD_PHASE}" != "preinst" ]; then
		eerror "fs_check_modules_api_compat() can only be used in pkg_preinst"
		return 1
	fi

	# no need to check anything if there's no previous install...
	[ ! -e "${ROOT}"/opt/freeswitch/mod ] && return 0

	# create an awk script with the list of "switch_*" symbols exported by libfreeswitch
	# run the script once for each module, the list of needed "switch_*" symbols is supplied via stdin
	# (raw nm output)
	#
	libfreeswitch="$(ls -1 "${ROOT}"/opt/freeswitch/lib/libfreeswitch.so.*.*.*)"
	if [ ! -f "${libfreeswitch}" ]; then
		eerror "Failed to locate libfreeswitch"
		return 1
	fi

	libfreeswitch_syms="$(fs_abi_generate_symbols_array "${libfreeswitch}")"
	if [ -z "${libfreeswitch_syms}" ]; then
		eerror "Failed to create list of exported libfreeswitch symbols"
		return 1
	fi

	cat > "${T}/symbols_check.awk" <<-EOF
	BEGIN{
	${libfreeswitch_syms}
	}

	/switch_.+/{
	    sym=\$2

	    if (! sym in symbols)
	        exit 1
	}
	EOF

	einfo "Checking for incompatible modules..."
	for x in "${ROOT}"/opt/freeswitch/mod/mod_*.so; do
		mod="$(basename "${x}")"
		name="$(echo "${mod}" | sed -e 's:^mod_\(.\+\)\.so$:\1:')"
		need_upgrade="no"

		# no need to check modules that will be overwritten
		[ -e "${D}/opt/freeswitch/mod/${mod}" ] && continue


		# skip modules that are in our list but disabled (= will be uninstalled)
		if has "${name}" $(echo "${IUSE_MODULES}" | tr -d '+') && ! useq "freeswitch_modules_${name}"; then
			continue
		fi

		# check module
		module_syms="$(nm -D --undefined-only "${x}" | sed -e 's:0\+\([1-9][0-9]*\):\1:g' | awk -v IGNORECASE=1 '/switch_.+/{ print $2 }')"
		if ! $(echo "${module_syms}" | awk -v IGNORECASE=1 -f "${T}/symbols_check.awk"); then
			# needed symbol is not in the list of available ones, mark module broken
			need_upgrade="yes"
		else
			# check if one of the used functions has been modified in the core,
			# this may be an indication that the ABI has been changed too
			# NOTE: This check isn't perfect...
			for sym in ${FREESWITCH_ABI_CHANGED_SYMBOLS}; do

				if $(echo "${module_syms}" | grep -q "^${sym}"); then
					# symbol is in the list of functions that _may_ have been changed in a
					# ABI incompatible way, mark module broken
					need_upgrade="maybe"
					break
				fi
			done
		fi

		case "${need_upgrade}" in
		maybe)
			mod_warn_list="${mod_warn_list} ${mod}"
			;;
		yes)
			mod_error_list="${mod_error_list} ${mod}"
			;;
		*)
			;;
		esac
	done

	if [ -n "${mod_warn_list}" ]; then
		ewarn "The following modules use functions that have been changed since the last version,"
		ewarn "you may need to upgrade:"
		ewarn "  ${mod_warn_list}"
		echo
	fi

	if [ -n "${mod_error_list}" ]; then
		eerror "These modules are incompatible with this FreeSWITCH version, please upgrade:"
		eerror "  ${mod_error_list}"
		echo
	fi

	return 0
}


###
# modules setup functions
#

fs_set_module() {
	local config="build/modules.conf.in"
	local mod="$2"

	[ -f "modules.conf" ] && config="modules.conf"

	case ${mod} in
	mod_freetdm)
		category="../../libs/freetdm"
		mod="mod_freetdm"
		;;
	*)
		category="$(ls -d src/mod/*/${mod} | cut -d'/' -f3)"
		;;
	esac

	[ -z "${category}" ] && die "unable to determine category for module \"${mod}\" (from: `pwd`)"

	case $1 in
	enable)
		if grep -q "/${mod}$" ${config}
		then
			einfo "  ++ Enabling ${mod}"
			sed -i -e "/\/${mod}$/s:.*:${category}/${mod}:" \
				${config} || die "Failed to enable module \"${mod}\""
		else
			# module not in list, add it
			einfo "  **  Adding ${mod}"
			echo "${category}/${mod}" >> ${config}
		fi
		;;

	disable)
		einfo "  -- Disabling ${mod}"
		sed -i -e "/\/${mod}$/s:.*:#${category}/${mod}:" \
			${config} || die "Failed to disable module \"${mod}\""
		;;
	*)
		eerror "fs_set_module <enable|disable> <module_path>"
		return 1
		;;
	esac

	return 0
}

setup_modules() {
	local x mod enablemod

	einfo "Optional modules:"
	for x in ${IUSE_MODULES}; do
		mod="${x/+}"
		enablemod=1

		[ -z "${x}" ] && continue

		fs_use freeswitch_modules_${mod} || enablemod=0

		[ ${enablemod} -eq 1 ] \
			&& fs_set_module "enable"  "mod_${mod}" \
			|| fs_set_module "disable" "mod_${mod}"
	done

	einfo "Language modules:"
	for x in ${IUSE_LINGUAS}; do
		mod="${x/+}"
		enablemod=1

		[ -z "${x}" ] && continue

		fs_use linguas_${mod} || enablemod=0

		[ ${enablemod} -eq 1 ] \
			&& fs_set_module "enable"  "mod_say_${mod}" \
			|| fs_set_module "disable" "mod_say_${mod}"
	done
}

###
# src_configure() helpers
#

fs_use() {
	if has $1 ${FREESWITCH_AUTO_USE} ${USE}; then
		return 0
	fi
	return 1
}

fs_enable() {
	local option value

	if [ -z "${1}" ]; then
		eerror "fs_enable(): Usage fs_enable <useflag> [<optname> [<optvalue>]]"
		return 1
	fi

	if [ -n "${3}" ]; then
		value="=${3}"
	fi

	option="${2}"
	if [ -z "${option}" ]; then
		option="${1}"
	fi

	if fs_use $1; then
		echo "--enable-${option}${value}"
	else
		echo "--disable-${option}"
	fi
}

fs_with() {
	local option value

	if [ -z "${1}" ]; then
		eerror "fs_with(): Usage fs_with <useflag> [<optname> [<optvalue>]]"
		return 1
	fi

	if [ -n "${3}" ]; then
		value="=${3}"
	fi

	option="${2}"
	if [ -z "${option}" ]; then
		option="${1}"
	fi

	if has $1 ${FREESWITCH_AUTO_USE} ${USE}; then
		echo "--with-${option}${value}"
	else
		echo "--without-${option}"
	fi
}

###
# other helpers
#

fs_is_upgrade() {
	# svn install is always an upgrade
	[ "${PV}" = "9999" ] && return 0

	# regular up/-downgrade
	if has_version "${CATEGORY}/${PN}" && ! has_version "~${CATEGORY}/${P}"; then
		return 0
	fi

	# not an up-/downgrade
	return 1
}

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
# Set file and directory permissions
#
fs_set_permissions() {
	local prefix="$1"

	[ -z "${prefix}" ] && {
		die "Usage: set_permissions <prefix>"
	}

	einfo "Setting file and directory permissions..."

	# sysconfdir
	chown -R root:freeswitch "${prefix}/etc/freeswitch" || die
	chmod -R u=rwX,g=rX,o=   "${prefix}/etc/freeswitch" || die

	# prefix
	chown -R root:freeswitch "${prefix}/opt/freeswitch" || die
	chmod -R u=rwX,g=rX,o=   "${prefix}/opt/freeswitch" || die
	# allow read access for things like building external modules
	chmod -R u=rwx,g=rx,o=rx "${prefix}/opt/freeswitch/"{lib*,bin,include} || die
	chmod    u=rwx,g=rx,o=rx "${prefix}/opt/freeswitch" || die

	# directories owned by the fs user
	for x in db run log cores storage recordings; do
		chown -R freeswitch:freeswitch "${prefix}/opt/freeswitch/${x}" ||  die
	done
}


###
# main ebuild functions
#

src_unpack() {
	if [ "${PV}" = "9999" ]; then
		git_src_unpack
	else
		unpack ${A}
	fi

	cd "${S}"
	#
	# 1. custom user patches
	#
	epatch_user
}

src_prepare() {
	local BOOTSTRAP_OPTS=""

	if [ "${PV}" = "9999" ]; then
		git_src_prepare

		# multi-threaded bootstrap
		[ "${MAKEOPTS}" != "${MAKEOPTS/-j}" ] && {
			einfo "Using parallel bootstrap..."
			BOOTSTRAP_OPTS="-j"
		}
		./bootstrap.sh ${BOOTSTRAP_OPTS}
	fi

	#
	# 0. create freetdm configure
	#
	if use freeswitch_modules_freetdm
	then
		( cd "${S}/libs/freetdm" ; ./bootstrap ; ) || die "Failed to bootstrap FreeTDM"
	fi

	#
	# 1. enable / disable optional modules
	#
	setup_modules

	#
	# 2. patches for esl modules (*sigh*)
	#
	sed -i -e '/^LOCAL_LDFLAGS/s:^\(.*\):\1 -lpthread:' \
		libs/esl/{ruby,python,perl,lua}/Makefile || die "failed to patch esl modules"

	if use esl-python; then
		python_get_version || die "Failed to determine current python version"

		sed -i -e "/^LOCAL_/{ s:python-2\.[0-9]:python-${PYVER}:g; s:python2\.[0-9]:python${PYVER}:g }" \
			libs/esl/python/Makefile || die "failed to change python locations in esl python module"
	fi

	#
	# 3. workarounds remove as soon as the fix has been comitted
	#
}

src_configure() {
	local java_opts config_opts

	#
	# option handling
	#
	fs_use freeswitch_modules_java && \
		java_opts="--with-java=$(/usr/bin/java-config -O)"

	fs_use libpri && \
		config_opts="--with-libpri"

	#
	# 1. filter some flags known to break things
	#

	# breaks linking freeswitch core lib (missing libdl symbols)
	filter-ldflags -Wl,--as-needed

	# breaks freetdm
	filter-flags -fvisibility-inlines-hidden

	#
	# 2. configure (can't use econf thanks to b0rked buildsystem)
	#
	einfo "Configuring FreeSWITCH..."
	./configure -C \
		--host=${CHOST} \
		${CBUILD:+--build=${CBUILD}} \
		${CTARGET:+--target=${CTARGET}} \
		--prefix=/opt/freeswitch \
		--libdir=/opt/freeswitch/lib \
		--sysconfdir=/opt/freeswitch/conf \
		--mandir=/usr/share/man \
		--infodir=/usr/share/info \
		--datadir=/usr/share \
		--enable-core-libedit-support \
		--with-pkgconfigdir=/usr/$(get_libdir)/pkgconfig \
		$(fs_enable sctp) \
		$(fs_with freeswitch_modules_python python "$(PYTHON -a)") \
		$(fs_enable resampler resample) \
		$(fs_enable odbc core-odbc-support) \
		${java_opts} ${config_opts} || die "failed to configure FreeSWITCH"

	#
	# 3. configure FreeTDM
	#
	if use freeswitch_modules_freetdm
	then
		cd "${S}/libs/freetdm"
		einfo "Configuring FreeTDM..."
		econf \
			--prefix=/opt/freeswitch \
			--libdir=/opt/freeswitch/lib \
			--sysconfdir=/opt/freeswitch/conf \
			--with-pkgconfigdir=/usr/$(get_libdir)/pkgconfig \
			${config_opts} || die "failed to configure FreeTDM"
	fi
}

src_compile() {
	local esl_lang

	#
	# 1. filter some flags known to break things
	#

	# breaks linking freeswitch core lib (missing libdl symbols)
	filter-ldflags -Wl,--as-needed

	# breaks freetdm
	filter-flags -fvisibility-inlines-hidden

	#
	# build FreeTDM
	#
	if use freeswitch_modules_freetdm
	then
		einfo "Building FreeTDM..."
		emake -j1 -C libs/freetdm || die "failed to build FreeTDM"
	fi

	#
	# 2. build everything
	#
	einfo "Building FreeSWITCH... (this can take a long time)"
	emake MONO_SHARED_DIR="${T}" || die "failed to build FreeSWITCH"

	#
	# 3. build esl modules
	#
	for esl_lang in ${IUSE_ESL}; do
		use ${esl_lang} || continue

		esl_lang="${esl_lang#*-}"

		einfo "Building esl module for ${esl_lang}..."
		emake -j1 -C libs/esl "$(esl_modname "${esl_lang}")" || die "Failed to build esl module for language \"${esl_lang}\""
	done

	if use esl; then
		einfo "Building libesl..."
		emake -j1 -C libs/esl || die "Failed to build libesl"
	fi
}


src_install() {
	local esl_lang

	#
	# 1. Install core
	#
	einfo "Installing freeswitch core and modules..."
	make -j1 install DESTDIR="${D}" MONO_SHARED_DIR="${T}" || die "Installation of freeswitch core failed"

	#
	# 2. Documentation, sample config files, ...
	#
	einfo "Installing documentation and misc files..."
	dodoc AUTHORS NEWS README ChangeLog INSTALL

	insinto /opt/freeswitch/scripts/rss
	doins scripts/rss/rss2ivr.pl

	keepdir /opt/freeswitch/{htdocs,log,log/{xml_cdr,cdr-csv},db,grammar,cores,storage,scripts,recordings}

	newinitd "${FILESDIR}"/freeswitch.rc6   freeswitch
	newconfd "${FILESDIR}"/freeswitch.confd freeswitch

	# save a copy of the default config
	einfo "Saving a copy of the default configuration..."
	find "${D}/opt/freeswitch/conf" -type f | sed -e "s:${D}/opt/freeswitch::" |\
	while read fn; do
		docinto "$(dirname "${fn}")"
		dodoc   "${D}/opt/freeswitch/${fn}"
	done

	# remove sample configuration if the user wishes so,
	# but only if this isn't a fresh installation
	if use nosamples; then
		if ! has_version "net-misc/freeswitch"; then
			einfo "No previous installation of FreeSWITCH found, installing sample configuration..."
		else
			einfo "Removing sample configuration files..."
			rm -r "${D}"/opt/freeswitch/conf/*
		fi
	fi

	# move configuration to /etc/freeswitch and
	# create symlink to /opt/freeswitch/conf
	dodir /etc
	mv "${D}/opt/freeswitch/conf" "${D}/etc/freeswitch"
	dosym /etc/freeswitch /opt/freeswitch/conf

	# keep managed subdir
	fs_use freeswitch_modules_managed && keepdir /opt/freeswitch/mod/managed

	# TODO: install contributed stuff

	# mod_skypopen sample config & helper files
	if fs_use freeswitch_modules_skypopen ; then
		docinto skypopen
		dodoc   "${S}/src/mod/endpoints/mod_skypopen/README"
		dodoc   "${S}/src/mod/endpoints/mod_skypopen/configs/"*
	fi

	#
	# 3. Remove .a and .la files
	#
	find "${D}" \( -name "mod*.la" -or -name "mod*.a" -or -name "lib*.a" \) -exec rm -f "{}" \; || die "Failed to cleanup .a and .la files"

	#
	# 4. move freeswitch and freetdm
	#    pkg-config files to /usr/lib/pkgconfig
	#    remove old pkgconfig dir(s) if empty
	#
	dodir "/usr/$(get_libdir)/pkgconfig"
	find "${D}/opt/freeswitch" \( -name "freeswitch.pc" -or -name "freetdm.pc" \) -exec \
		mv "{}" "${D}/usr/$(get_libdir)/pkgconfig" \;
	rmdir "${D}"/opt/freeswitch/lib*/pkgconfig 2>/dev/null


	#
	# 5. install esl modules
	#
	if use esl-ruby; then
		einfo "Installing esl module for ruby..."
		esl_dorubymod libs/esl/ruby/ESL.so
	fi

	if use esl-python; then
		einfo "Installing esl module for python..."
		esl_dopymod libs/esl/python/{_ESL.so,ESL.py}
	fi

	if use esl-lua; then
		einfo "Installing esl module for lua..."
		esl_doluamod libs/esl/lua/ESL.so
	fi

	if use esl-php; then
		einfo "Installing esl module for php..."
		emake DESTDIR="${D}" -C libs/esl phpmod-install || die "Failed to install esl module for php"
	fi

	if use esl-perl; then
		einfo "Installing esl module for perl..."
		esl_doperlmod libs/esl/perl/{ESL,ESL.so,ESL.pm}
	fi

	if use esl; then
		einfo "Installing libesl..."
		insinto "/opt/freeswitch/lib"
		doins libs/esl/libesl.a
	fi

	#
	# 6. Fix permissions
	#
	fs_set_permissions "${D}"
}

pkg_preinst() {
	#
	# 1. upgrade api check
	#
	if fs_is_upgrade; then
		einfo "Performing core ABI compatibility check..."

		# compare exported symbols of new and old libfreeswitch to make sure
		# external modules will still work
		fs_check_core_abi_compat

		# check if external modules will still work after upgrade
		# to new libfreeswitch
		fs_check_modules_api_compat
	fi

	#
	# 2. preserve existing config files
	#
	if use nosamples; then
		if has_version "net-misc/freeswitch"; then
			einfo "Preserving existing configuration..."
			rm -r "${D}/etc/freeswitch"
			cp -dpR "${ROOT}/etc/freeswitch" "${D}/etc"
		fi
	fi
}

pkg_postinst() {
	#
	# 1. Info
	#
	echo
	einfo "FreeSWITCH has been successfully emerged!"
	echo
	einfo "More information about FreeSWITCH and how to configure it"
	einfo "can be found on one of these sites:"
	einfo
	einfo "    http://www.freeswitch.org/"
	einfo "    http://wiki.freeswitch.org/"
	echo

	# skypopen setup guide
	if use freeswitch_modules_skypopen ; then
		einfo "To setup the Skype endpoint module mod_skypopen and the Skype client,"
		einfo "follow the instructions in the guide:"
		einfo
		einfo "  http://wiki.freeswitch.org/wiki/Skypiax"
		einfo
		echo
	fi

	einfo "A copy of the default configuration has been saved to"
	einfo "    ${ROOT}/usr/share/doc/${PF}/conf"
	echo
}

pkg_config() {
	local answer="N"

	[ "$(id -u)" != "0" ] && {
		eerror "This action needs root privileges"
		die "Can not run as non-root user"
	}

	einfo "Reset permissions to installation defaults (y/N)?"
	read answer

	if [ "${answer/y/Y}" = "Y" ]; then
		#
		# Fix permissions
		#
		fs_set_permissions "${ROOT:-/}"

		einfo "Done"
	else
		ewarn "Aborted"
	fi
}
