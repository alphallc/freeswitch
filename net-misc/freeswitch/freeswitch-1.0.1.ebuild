#
# Copyright (C) 2008 Stefan Knoblich <s.knoblich@axsentis.de>
#
# Distributed under the terms of the GNU General Public License 2
# see http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt for
# more information
#

EAPI="1"

inherit flag-o-matic

IUSE="alsa debug cepstral +h26x iax java jingle javascript +lua openzap perl portaudio python sctp +xml +xmlrpc"

MY_PV="${PV/_/.}"

DESCRIPTION="FreeSWITCH telephony platform"
HOMEPAGE="http://www.freeswitch.org/"
SRC_URI="http://files.freeswitch.org/freeswitch-${MY_PV}.tar.bz2"

SLOT="0"

LICENSE="MPL-1.1"
KEYWORDS="~amd64 ~x86"

RDEPEND="virtual/libc
	 alsa?   ( media-libs/alsa-lib )
	 java? ( >=virtual/jdk-1.5 )
	 python? ( >=dev-lang/python-2.4 )"

DEPEND="${RDEPEND}
	!net-misc/freeswitch-svn
	~sys-devel/autoconf-2.61
	=sys-devel/automake-1.9*
	sctp? ( kernel_linux? ( net-misc/lksctp-tools ) )"

PDEPEND="net-misc/freeswitch-sounds
	 net-misc/freeswitch-music"

S="${WORKDIR}/${PN}-${MY_PV}"

#
# list of useflags and modules
#
FS_MODULES="
	alsa:endpoints/mod_alsa
	iax:endpoints/mod_iax
	jingle:endpoints/mod_dingaling
	portaudio:endpoints/mod_portaudio
	openzap:endpoints/mod_openzap

	java:languages/mod_java
	python:languages/mod_python
	lua:languages/mod_lua
	perl:languages/mod_perl
	javascript:languages/mod_spidermonkey
	javascript:languages/mod_spidermonkey_curl
	javascript:languages/mod_spidermonkey_socket
	javascript:languages/mod_spidermonkey_teletone
	javascript:languages/mod_spidermonkey_core_db

	cepstral:asr_tts/mod_cepstral

	h26x:codecs/mod_h26x

	curl:xml_int/mod_xml_curl
	xmlrpc:xml_int/mod_xml_rpc
	xml:xml_int/mod_xml_cdr
	"


pkg_setup() {
	local error_cnt=0

	ewarn "--- Work-In-Progress ebuild ---"
	epause 5

	#
	# 1. check prerequisites
	#
	if use cepstral; then
		einfo "Checking for cepstral installation..."
		if [ -z "${SWIFT_HOME}" ]; then
			SWIFT_HOME="/opt/swift"
		fi

		if [ ! -d "${SWIFT_HOME}" ]; then
			eerror "No cepstral installation found in \"${SWIFT_HOME}\""
			die "No cepstral installation found in \"${SWIFT_HOME}\""
		fi

		if [ ! -e "${SWIFT_HOME}/lib/libceplex_us.so" ]; then
			error "Only US English cepstral voices can be used at the moment!"
			die "No supported cepstral voices found!"
		fi

		einfo "Cepstral installation found in \"${SWIFT_HOME}\""

		export SWIFT_HOME
	fi

	if use python && built_with_use python nothreads; then
		echo
		eerror "python: FreeSWITCH needs python with threads support"
		eerror "python: please reemerge python with \"nothreads\" useflag disabled"
		echo

		(( error_cnt++ ))
	fi

	if use perl && ! built_with_use perl ithreads; then
		echo
		eerror "perl: FreeSWITCH needs perl with threads support"
		eerror "perl: please reemerge libperl and perl with \"ithreads\" useflag enabled"
		echo

		(( error_cnt++ ))
	fi

	if [ "${error_cnt}" != "0" ]; then
		eerror "Build-time requirements not met!"
		eerror "Please correct above error messages or disable the useflags and reemerge ${PN}"
		die "Build-time requirements not met: ${error_cnt} errors"
	fi

	#
	# 2. create user + group
	#
	enewgroup freeswitch
	enewuser freeswitch -1 -1 /opt/freeswitch freeswitch
}

fs_set_module() {
	local config="build/modules.conf.in"
	local mod="$2"

	[ -f "modules.conf" ] && config="modules.conf"

	case $1 in
	enable)
		if grep -q "${mod}" ${config}
		then
			einfo "  Enabling ${mod}"
			sed -i -e "s:^#\(${mod}\)$:\1:" \
				${config} || die "Failed to enable module \"${mod}\""
		else
			# module not in list, add it
			einfo "   Adding ${mod}"
			echo "${mod}" >> ${config}
		fi
		;;

	disable)
		einfo "  Disabling ${mod}"
		sed -i -e "s:^\(${mod}\)$:#\1:" \
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
	local x modpath modflag

	einfo "Optional modules:"
	for x in ${FS_MODULES}; do
		modflag="${x%:*}"
		modpath="${x#*:}"

		[ -z "${x}" ] && continue

		if use ${modflag}; then
			fs_set_module "enable" "${modpath}"
		else
			fs_set_module "disable" "${modpath}"
		fi
	done
}

src_unpack() {
	unpack ${A}
	cd "${S}"

	#
	# 1. enable / disable optional modules
	#
	setup_modules

	#
	# 2. workarounds remove as soon as the fix has been comitted
	#
}

src_compile() {
	local java_opts

	#
	# filter some flags known to break things
	#

	# breaks linking freeswitch core lib (missing libdl symbols)
	filter-ldflags -Wl,--as-needed

	# breaks openzap
	filter-flags -fvisibility-inlines-hidden


	#
	# option handling
	#
	use java && \
		java_opts="--with-java=$(/usr/bin/java-config -O)"

	#
	# 1. configure
	#
	einfo "Configuring freeswitch..."
	econf \
		--prefix=/opt/freeswitch \
		$(use_enable sctp) \
		$(use_with python) \
		$(use_enable debug) \
		${java_opts} || die "configure failed"

	#
	# 2. build everything
	#
	einfo "Building freeswitch... (this can take a long time)"
	emake -j1 || die "building freeswitch failed"
}


src_install() {
	#
	# 1. Install core
	#
	einfo "Installing freeswitch core and modules..."
	make install DESTDIR="${D}" || die "Installation of freeswitch core failed"

	#
	# 2. Documentation, sample config files, ...
	#
	einfo "Installing documentation and misc files..."
	dodoc AUTHORS NEWS README ChangeLog INSTALL

	insinto /opt/freeswitch/scripts/rss
	doins scripts/rss/rss2ivr.pl

	insinto /opt/freeswitch/scripts/multicast
	doins scripts/multicast/*.pl

	keepdir /opt/freeswitch/{htdocs,log,log/xml_cdr,db,grammar}

	newinitd "${FILESDIR}"/freeswitch.rc6   freeswitch
	newconfd "${FILESDIR}"/freeswitch.confd freeswitch

	# move configuration to /etc/freeswitch and
	# create symlink to /opt/freeswitch/conf
	dodir /etc
	mv "${D}/opt/freeswitch/conf" "${D}/etc/freeswitch"
	dosym /etc/freeswitch /opt/freeswitch/conf

	# TODO: install contributed stuff

	#
	# 3. Remove .a and .la files
	#
	find "${D}" \( -name "*.la" -or -name "*.a" \) -exec rm -f {} \; || die "Failed to cleanup .a and .la files"

	#
	# 4. Fix permissions
	#
	einfo "Setting file and directory permissions..."

	# sysconfdir
	chown -R root:freeswitch "${D}/etc/freeswitch"
	chmod -R u=rwX,g=rX,o=   "${D}/etc/freeswitch"

	# prefix
	chown -R root:freeswitch "${D}/opt/freeswitch"
	chmod -R u=rwX,g=rX,o=   "${D}/opt/freeswitch"
	# allow read access for things like building external modules
	chmod -R u=rwx,g=rx,o=rx "${D}/opt/freeswitch/"{lib*,bin,include}
	chmod    u=rwx,g=rx,o=rx "${D}/opt/freeswitch"

	for x in db log; do
		chown -R freeswitch:freeswitch "${D}/opt/freeswitch/${x}"
	done
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

	#
	# 2. Something noteworthy
	#
	echo
	ewarn "NOTE: FreeSWITCH will be running as freeswitch user from now on,"
	ewarn "      either change conf.d/freeswitch (comment FREESWITCH_USER)"
	ewarn "      to run as root (not recommended) or add the freeswitch user"
	ewarn "      to the appropriate groups (and leave FREESWITCH_GROUP commented!)."
}
