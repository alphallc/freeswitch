# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: This ebuild is from freeswitch overlay; Bumped by mva; $

EAPI="4"

inherit eutils flag-o-matic python

DESCRIPTION="FreeSWITCH telephony platform"
HOMEPAGE="http://www.freeswitch.org/"

KEYWORDS=""
LICENSE="MPL-1.1"
SLOT="0"

case ${PV} in
	9999*)
		EGIT_REPO_URI="git://git.freeswitch.org/freeswitch.git"
		EGIT_BOOTSTRAP="./bootstrap.sh"
		inherit git-2
		;;
	*_rc*)
		MY_P="${PN}-${PV/.?_/.}"	# 1.2.0_rcX -> 1.2.rcX
		SRC_URI="http://files.freeswitch.org/${MY_P}.tar.bz2"
		S="${WORKDIR}/${MY_P}"
		;;
	*)
		SRC_URI="http://files.freeswitch.org/${P/_/}.tar.bz2"
		S="${WORKDIR}/${P/_/}"
		;;
esac

IUSE="esl odbc +resampler sctp +zrtp debug"

LANGS="de en es fa fr he hr hu it ja nl pt ru th zh"

FREETDM_MODULES="
	+libpri misdn r2 sng_isdn sng_ss7 wanpipe
"

ESL="ruby php perl python lua java managed"

FM_APPLICATIONS="
	abstraction avmd blacklist callcenter cidlookup cluechoo
	+commands +conference curl +db directory distributor +dptools
	easyroute +enum +esf esl +expr +fifo fsk fsv +hash +httapi
	http_cache ladspa lcr +limit memcache mongo mp4 nibblebill
	osp rad_auth random redis rss skel +sms snapshot snipe_hunt
	snom soundtouch +spandsp spy stress +valet_parking vmd
	+voicemail voicemail_ivr
"
FM_TTS="
	cepstral flite pocketsphinx tts_commandline unimrcp
"
FM_CODECS="
	+amr amrwb +bv celt codec2 com_g729 dahdi_codec +g723_1 +g729
	+h26x +ilbc isac mp4v opus sangoma_codec silk siren skel_codec
	+speex theora voipcodecs
"
FM_DIALPLANS="
	dialplan_asterisk +dialplan_directory +dialplan_xml
"
FM_DIRECTORIES="
	ldap
"
FM_ENDPOINTS="
	alsa dingaling freetdm gsmopen h323 khomp +loopback opal
	portaudio reference rtmp skinny skypopen +sofia unicall
"
FM_EVENT_HANDLERS="
	+cdr_csv cdr_mongodb cdr_pg_csv cdr_sqlite erlang_event
	event_multicast +event_socket event_test event_zmq json_cdr
	radius_cdr snmp
"
FM_FORMATS="
	+local_stream +native_file portaudio_stream shell_stream
	shout +sndfile +tone_stream vlc
"
FM_LANGUAGES="
	java +lua managed perl python spidermonkey yaml
"
FM_LOGGERS="
	+console +logfile +syslog
"
FM_TIMERS="
	posix_timer timerfd
"
FM_XML="
	xml_cdr xml_curl xml_ldap xml_rpc xml_scgi
"
FM_EXTERNAL="
	squirrelfish ssh
"
FM="
	${FM_APPLICATIONS}
	${FM_TTS}
	${FM_CODECS}
	${FM_DIALPLANS}
	${FM_DIRECTORIES}
	${FM_ENDPOINTS}
	${FM_EVENT_HANDLERS}
	${FM_FORMATS}
	${FM_LANGUAGES}
	${FM_LOGGERS}
	${FM_TIMERS}
	${FM_XML}
"

FM_BROKEN="
	esl_php
	freeswitch_modules_osp
	freeswitch_modules_http_cache
	freeswitch_modules_yaml
"
#- http_cache -> error in for declaration, ask for -std=c99
#- osp -> undefined vars
#- yaml -> ?
#- esl_php -> errors in esl_wrap.cpp

#? h323 -> want ptlib
#? mp4{,v} -> want mp4

REQUIRED_USE="
	|| ( linguas_de linguas_en linguas_es linguas_fa linguas_fr linguas_he linguas_hr linguas_hu linguas_it linguas_ja linguas_nl linguas_pt linguas_ru linguas_th linguas_zh )
	esl? ( freeswitch_modules_esl )
	freeswitch_modules_esl? ( esl )
	freeswitch_modules_limit? ( freeswitch_modules_db freeswitch_modules_hash )
	freeswitch_modules_nibblebill? ( odbc )
	freeswitch_modules_easyroute? ( odbc )
	freeswitch_modules_lcr? ( odbc )
	freeswitch_modules_gsmopen? ( freeswitch_modules_spandsp )
	freeswitch_modules_portaudio_stream? ( freeswitch_modules_portaudio )
"

RDEPEND="virtual/libc
	odbc? ( dev-db/unixODBC )
	esl_lua? ( || ( dev-lang/lua dev-lang/luajit:2 ) )
	esl_perl? ( dev-lang/perl )
	esl_ruby? ( dev-lang/ruby )
	esl_python? ( dev-lang/python:2.7 )
	freeswitch_modules_alsa? ( media-libs/alsa-lib )
	freeswitch_modules_radius_cdr? ( net-dialup/freeradius-client )
	freeswitch_modules_xml_curl? ( net-misc/curl )
	freeswitch_modules_xml_ldap? ( net-nds/openldap )
	freeswitch_modules_ldap? ( net-nds/openldap )
	freeswitch_modules_java? ( >=virtual/jdk-1.5 )
	freeswitch_modules_h323? ( net-libs/ptlib )
	freeswitch_modules_opal? ( >=net-libs/opal-9999[h323,iax]
				   >=net-libs/ptlib-9999 )
	freeswitch_modules_perl? ( dev-lang/perl[ithreads] )
	freeswitch_modules_python? ( dev-lang/python:2.7[threads] )
	freeswitch_modules_managed? ( >=dev-lang/mono-1.9 )
	freeswitch_modules_skypopen? ( x11-base/xorg-server x11-apps/xhost net-im/skype media-fonts/font-misc-misc media-fonts/font-cursor-misc )
	freeswitch_modules_memcache? ( net-misc/memcached )
	freeswitch_modules_erlang_event? ( dev-lang/erlang )
	freeswitch_modules_shout? ( media-libs/libogg )
	freeswitch_modules_spandsp? ( virtual/jpeg )
	freeswitch_modules_redis? ( dev-db/redis )
	freeswitch_modules_mp4? ( media-libs/libmp4v2 )
	freeswitch_modules_cdr_pg_csv? ( dev-db/postgresql-base )
	freeswitch_modules_gsmopen? ( net-libs/ctb app-mobilephone/gsmlib )
	freeswitch_modules_xml_ldap? ( net-nds/openldap[sasl] )
	freeswitch_modules_ladspa? ( media-libs/ladspa-sdk )
	freeswitch_modules_freetdm? (
		freetdm_modules_misdn? ( >=net-dialup/misdnuser-2.0.0 )
		freetdm_modules_libpri? ( >=net-libs/libpri-1.4.0 )
		freetdm_modules_wanpipe? ( net-misc/wanpipe )
		freetdm_modules_sng_isdn? ( net-libs/libsng-isdn )
		freetdm_modules_sng_ss7? ( net-libs/libsng-ss7 )
		freetdm_modules_r2? ( net-misc/openr2 )
	)
"
#	esl_php? ( dev-lang/php )
#	freeswitch_modules_osp? ( >=net-libs/osptoolkit-3.5.0 )
#	esl_java? ( >=virtual/jdk-1.5 )
#	esl_managed? ( >=dev-lang/mono-1.9 )

DEPEND="${RDEPEND}
	>=sys-devel/autoconf-2.60
	>=sys-devel/automake-1.10
	sctp? ( kernel_linux? ( net-misc/lksctp-tools ) )"

PDEPEND="media-sound/freeswitch-sounds
	media-sound/freeswitch-sounds-music
	freeswitch_modules_squirrelfish? ( net-voip/freeswitch-mod_squirrelfish )
	freeswitch_modules_ssh? ( net-voip/freeswitch-mod_ssh )
"

for x in ${FM} ${FM_EXTERNAL}; do
	IUSE="${IUSE} ${x//[^+]/}freeswitch_modules_${x/+}"
done
for x in ${FREETDM_MODULES}; do
	IUSE="${IUSE} ${x//[^+]/}freetdm_modules_${x/+}"
done
for x in ${ESL}; do
	IUSE="${IUSE} esl_${x}"
done
for x in ${LANGS}; do
	IUSE="${IUSE} linguas_${x}"
done
for x in ${FM_BROKEN}; do
	IUSE="${IUSE//${x}}"
done

FREESWITCH_USER=${FREESWITCH_USER:-voip}
FREESWITCH_GROUP=${FREESWITCH_GROUP:-voip}
QA_TEXTRELS="usr/lib/freeswitch/mod/mod_shout.so"

pkg_setup() {
	if use freeswitch_modules_cepstral; then
		SWIFT_HOME="${SWIFT_HOME:-/opt/swift}"

		if [ ! -d "${SWIFT_HOME}" ]; then
			eerror "No cepstral installation found in \"${SWIFT_HOME}\""
			eerror 'Try to set SWIFT_HOME="/path/to/swift_tts_engine" in your make.conf'
			die "No cepstral installation found in \"${SWIFT_HOME}\""
		fi

		if [ ! -e "${SWIFT_HOME}/lib/libswift.so" ]; then
			eerror "Cepstral library not found in \"${SWIFT_HOME}\""
			die "Cepstral library not found!"
		fi

		einfo "Cepstral installation found in \"${SWIFT_HOME}\""

		export SWIFT_HOME
	fi
#	python_set_active_version 2
	python_pkg_setup
}

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
	[ ! -e "${ROOT}/usr/$(get_libdir)/${PN}/mod" ] && return 0
	libfreeswitch="$(ls -1 "${ROOT}"/usr/$(get_libdir)/libfreeswitch.so.*.*.*)"
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
	libfreeswitch="$(ls -1 "${D}"/usr/$(get_libdir)/libfreeswitch.so.*.*.*)"
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
	[ ! -e "${ROOT}/usr/$(get_libdir)/${PN}"/mod ] && return 0
	libfreeswitch="$(ls -1 "${ROOT}"/usr/$(get_libdir)/libfreeswitch.so.*.*.*)"
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
	for x in "${ROOT}/usr/$(get_libdir)/${PN}"/mod/mod_*.so; do
		mod="$(basename "${x}")"
		name="$(echo "${mod}" | sed -e 's:^mod_\(.\+\)\.so$:\1:')"
		need_upgrade="no"
		[ -e "${D}/usr/$(get_libdir)/${PN}/mod/${mod}" ] && continue
		if has "${name}" $(echo "${IUSE_MODULES}" | tr -d '+') && ! use "freeswitch_modules_${name}"; then
			continue
		fi
		module_syms="$(nm -D --undefined-only "${x}" | sed -e 's:0\+\([1-9][0-9]*\):\1:g' | awk -v IGNORECASE=1 '/switch_.+/{ print $2 }')"
		if ! $(echo "${module_syms}" | awk -v IGNORECASE=1 -f "${T}/symbols_check.awk"); then
			need_upgrade="yes"
		else
			for sym in ${FREESWITCH_ABI_CHANGED_SYMBOLS}; do

				if $(echo "${module_syms}" | grep -q "^${sym}"); then
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
		ewarn ""
	fi
	if [ -n "${mod_error_list}" ]; then
		eerror "These modules are incompatible with this FreeSWITCH version, please upgrade:"
		eerror "  ${mod_error_list}"
		eerror ""
	fi
	return 0
}

fs_set_module() {
	local config="modules.conf"
	local mod="$2"

	case ${mod} in
	mod_freetdm)
		category="../../libs/freetdm"
		;;
	*)
		category="$(ls -d src/mod/*/${mod} | cut -d'/' -f3)"
		;;
	esac

	[ -z "${category}" ] && {
		die "Unable to determine category for module \"${mod}\"."
	}

	case $1 in
	enable)
		einfo "  ++ Enabling ${mod}"
		echo "${category}/${mod}" >> "${config}"
		;;

	disable)
		einfo "  -- Disabling ${mod}"
		echo "#${category}/${mod}" >> "${config}"
		;;
	*)
		eerror "fs_set_module <enable|disable> <module_path>"
		return 1
		;;
	esac

	return 0
}

setup_modules() {
	local x mod action

	[ -f "modules.conf" ] && {
		rm -f "modules.conf" || die "Failed to remove existing modules.conf"
	}
	einfo "Optional modules:"
	for x in ${FM}; do
		mod="${x/+}"
		action="enable"

		[ -n "${mod}" ] && {
			use freeswitch_modules_${mod} || action="disable"
			fs_set_module "${action}" "mod_${mod}"
		}
	done

	einfo "Language modules:"
	for x in ${LANGS}; do
		mod="${x/+}"
		action="enable"

		[ -n "${mod}" ] && {
			use linguas_${mod} || action="disable"
			fs_set_module "${action}" "mod_say_${mod}"
		}
	done
}

fs_is_upgrade() {
	[ -n "${EGIT_REPO_URI}" ] && return 0
	if has_version "${CATEGORY}/${PN}" && ! has_version "~${CATEGORY}/${P}"; then
		return 0
	fi
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
	(
		insinto $(${RUBY:-/usr/bin/ruby} -r rbconfig -e 'print Config::CONFIG["sitearchdir"]')
		insopts -m755
		doins "$@"
	) || die "failed to install $@"
}

esl_dopymod() {
	(
		insinto $(python_get_sitedir)

		for x in ${@}; do
			insopts -m644

			[ "${x}" != "${x%.so}" ] && insopts -m755

			doins "${x}" || die "failed to install ${x}"
		done
	) || die "failed to install $@"
}

esl_doluamod() {
	(
		insinto /usr/$(get_libdir)/lua/$(${LUA:-/usr/bin/lua} -e 'print(_VERSION:match("%d.%d"))')
		insopts -m755
		doins "$@"
	) || die "failed to install $@"
}

esl_doperlmod() {
	(
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

src_unpack() {
	if [ -n "${EGIT_REPO_URI}" ]; then
		git-2_src_unpack
	else
		unpack ${A}
	fi
	epatch_user
}

src_prepare() {
	if use freeswitch_modules_freetdm
	then
		( cd "${S}/libs/freetdm" ; ./bootstrap ; ) || die "Failed to bootstrap FreeTDM"
	fi

	sed -i -e '/^LOCAL_LDFLAGS/s:^\(.*\):\1 -lpthread:' \
		libs/esl/{ruby,python,perl,lua}/Makefile || die "failed to patch esl modules"

	if use esl_python; then
		python_get_version &>/dev/null && PYVER=$(python_get_version) || die "Failed to determine current python version"
		sed -i -e "/^LOCAL_/{ s:python-2\.[0-9]:python-${PYVER}:g; s:python2\.[0-9]:python${PYVER}:g }" \
			libs/esl/python/Makefile || die "failed to change python locations in esl python module"
	fi
}

src_configure() {
	local java_opts config_opts
	use freeswitch_modules_java && \
		java_opts="--with-java=$(/usr/bin/java-config -O)"
	use freetdm_modules_libpri && \
		config_opts="--with-libpri"
	use freetdm_modules_misdn && \
		config_opts="--with-misdn"

	use debug || config_opts="${config_opts} --disable-debug"

#	# breaks freetdm
#	filter-flags -fvisibility-inlines-hidden
	einfo "Configuring FreeSWITCH..."
		touch noreg
		FREESWITCH_HTDOCS="${FREESWITCH_HTDOCS:-/var/www/localhost/htdocs/${PN}}"
		econf \
		--disable-option-checking \
		${CTARGET:+--target=${CTARGET}} \
		--enable-core-libedit-support \
		--localstatedir="/var" \
		--sysconfdir="/etc/${PN}" \
		--with-modinstdir="/usr/$(get_libdir)/${PN}/mod" \
		--with-rundir="/var/run/${PN}" \
		--with-logfiledir="/var/log/${PN}" \
		--with-dbdir="/var/lib/${PN}/db" \
		--with-htdocsdir="/usr/share/${PN}/htdocs" \
		--with-soundsdir="/usr/share/${PN}/sounds" \
		--with-grammardir="/usr/share/${PN}/grammar" \
		--with-scriptdir="/usr/share/${PN}/scripts" \
		--with-recordingsdir="/var/lib/${PN}/recordings" \
		--with-pkgconfigdir="/usr/$(get_libdir)/pkgconfig" \
		$(use_enable sctp) \
		$(use_enable zrtp) \
		$(use_with freeswitch_modules_python python "$(PYTHON -a)") \
		$(use_enable resampler resample) \
		$(use_enable odbc core-odbc-support) \
		${java_opts} ${config_opts} || die "failed to configure FreeSWITCH"

	if use freeswitch_modules_freetdm; then
		cd "${S}/libs/freetdm"
		einfo "Configuring FreeTDM..."
		econf \
			--with-modinstdir="/usr/$(get_libdir)/${PN}/mod" \
			--with-pkgconfigdir=/usr/$(get_libdir)/pkgconfig \
			${config_opts} || die "failed to configure FreeTDM"
	fi
	setup_modules
}

src_compile() {
	local esl_lang
#	filter-ldflags -Wl,--as-needed

	# breaks freetdm:
	filter-flags -fvisibility-inlines-hidden
	if use freeswitch_modules_freetdm; then
		einfo "Building FreeTDM..."
		emake -C libs/freetdm || die "failed to build FreeTDM"
	fi
	einfo "Building FreeSWITCH... (this can take a long time)"
	emake MONO_SHARED_DIR="${T}" || die "failed to build FreeSWITCH"
	for esl_lang in ${ESL}; do
		use esl_${esl_lang} || continue

		esl_lang="${esl_lang#*_}"

		einfo "Building esl module for ${esl_lang}..."
		emake -C libs/esl "$(esl_modname ${esl_lang})" || die "Failed to build esl module for language \"${esl_lang}\""
	done
	if use esl; then
		einfo "Building libesl..."
		emake -C libs/esl || die "Failed to build libesl"
	fi
}

src_install() {
	local esl_lang
	einfo "Installing freeswitch core and modules..."
	emake install DESTDIR="${D}" MONO_SHARED_DIR="${T}" || die "Installation of freeswitch core failed"
	einfo "Installing documentation and misc files..."
	dodoc AUTHORS NEWS README ChangeLog INSTALL

	insinto "/usr/share/${PN}/scripts/rss"
	doins scripts/rss/rss2ivr.pl

	keepdir /var/lib/"${PN}"/{cores,storage}

	newinitd "${FILESDIR}"/freeswitch.rc6   freeswitch
	newconfd "${FILESDIR}"/freeswitch.confd freeswitch

	use freeswitch_modules_managed && keepdir "/usr/$(get_libdir)/${PN}/mod/managed"
#	# TODO: install contributed stuff

	if use freeswitch_modules_skypopen ; then
		docinto skypopen
		dodoc   "${S}/src/mod/endpoints/mod_skypopen/README"
		dodoc   "${S}/src/mod/endpoints/mod_skypopen/configs/"*
	fi

	find "${D}" -name "*.la" -delete || die "Failed to cleanup .a and .la files"

	if use esl_ruby; then
		einfo "Installing esl module for ruby..."
		esl_dorubymod libs/esl/ruby/ESL.so
	fi

	if use esl_python; then
		einfo "Installing esl module for python..."
		esl_dopymod libs/esl/python/{_ESL.so,ESL.py}
	fi

	if use esl_lua; then
		einfo "Installing esl module for lua..."
		esl_doluamod libs/esl/lua/ESL.so
	fi

#	if use esl_php; then
#		einfo "Installing esl module for php..."
#		emake DESTDIR="${D}" -C libs/esl phpmod-install || die "Failed to install esl module for php"
#	fi

	if use esl_perl; then
		einfo "Installing esl module for perl..."
		esl_doperlmod libs/esl/perl/{ESL,ESL.so,ESL.pm}
	fi

#	if use esl_java; then
#		#einfo "Installing esl module for java..."
#		# TODO
#	fi

#	if use esl_managed; then
#		#einfo "Installing esl module for managed (mono, .NET)..."
#		# TODO
#	fi

	if use esl; then
		einfo "Installing libesl..."
		insinto "/usr/$(get_libdir)"
		doins libs/esl/libesl.a
	fi

	fowners -Rf ${FREESWITCH_USER}:${FREESWITCH_GROUP} "/etc/${PN}"
	fowners -Rf ${FREESWITCH_USER}:${FREESWITCH_GROUP} "/usr/$(get_libdir)/${PN}"
	fowners -Rf ${FREESWITCH_USER}:${FREESWITCH_GROUP} "/var/run/${PN}"
	fowners -Rf ${FREESWITCH_USER}:${FREESWITCH_GROUP} "/var/log/${PN}"
	fowners -Rf ${FREESWITCH_USER}:${FREESWITCH_GROUP} "/usr/share/${PN}"
	fowners -Rf ${FREESWITCH_USER}:${FREESWITCH_GROUP} "/var/lib/${PN}"
}

pkg_preinst() {
	if fs_is_upgrade; then
		einfo "Performing core ABI compatibility check..."
		fs_check_core_abi_compat
		fs_check_modules_api_compat
	fi
}

pkg_postinst() {
	enewgroup "${FREESWITCH_GROUP}"
	enewuser "${FREESWITCH_USER}" -1 -1 "/var/lib/${PN}" "${FREESWITCH_GROUP}"

	einfo
	einfo "FreeSWITCH has been successfully emerged!"
	einfo
	einfo "More information about FreeSWITCH and how to configure it"
	einfo "can be found on one of these sites:"
	einfo
	einfo "    http://www.freeswitch.org/"
	einfo "    http://wiki.freeswitch.org/"
	einfo

	if use freeswitch_modules_skypopen ; then
		einfo "To setup the Skype endpoint module mod_skypopen and the Skype client,"
		einfo "follow the instructions in the guide:"
		einfo
		einfo "  http://wiki.freeswitch.org/wiki/Skypiax"
		einfo
		einfo
	fi
}
