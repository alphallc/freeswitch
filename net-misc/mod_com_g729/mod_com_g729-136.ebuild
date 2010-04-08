#
# Copyright (C) 2010 Stefan Knoblich <s.knoblich@axsentis.de>
#
# Distributed under the terms of the GNU General Public License 2
# see http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt for
# more information
#

EAPI="1"

IUSE=""

DESCRIPTION="G.729 codec module for FreeSWITCH"
HOMEPAGE="http://www.freeswitch.org/node/235"
SRC_URI="http://files.freeswitch.org/g729/fsg729-${PV}-installer"
PROPERTIES="interactive"

SLOT="0"

LICENSE="MPL-1.1"
KEYWORDS="~amd64 ~x86"

RDEPEND="virtual/libc
	 net-misc/freeswitch"

DEPEND="${RDEPEND}"

S="${WORKDIR}"

src_unpack() {
	cd "${WORKDIR}"

	# 1. custom unpack function, we do not want to run the installer
	sed -e '0,/^__ARCHIVE_BELOW__/d' "${DISTDIR}/fsg729-${PV}-installer" \
		| tar -xz || die "Failed to unpack installer archive"

	# 2. unpack architecture specific part
	if use x86 ; then
		tar -xzf fsg729_i386.tar.gz || die "Failed to unpack x86 codec archive"
	elif use amd64 ; then
		tar -xzf fsg729_x86_64.tar.gz || die "Failed to unpack amd64 codec archive"
	else
		die "Unsupported architecture"
	fi
}

src_compile() {
	local response cnt=0

	# display EULA
	less EULA.txt || die "Failed to display EULA"

	while [ $cnt -lt 4 ] ; do
		echo "Do You accept the license [y/N]?"
		read -n1 response
		case "${response}" in 
		y|Y)
			break;
			;;
		n|N)
			die "License has not been accepted"
			;;
		*)
			echo "Invalid response, press \"y\" or \"n\""
			;;
		esac
		(( cnt++ ))
	done
	if [ $cnt -ge 4 ]; then
		die "Failed to accept the license"
	fi
}

src_install() {
	into /opt/freeswitch
	dobin fsg729/validator
	dobin fsg729/freeswitch_licence_server

	insinto /opt/freeswitch/lib
	doins fsg729/libg729.so.1.0.0
	dosym libg729.so.1.0.0 /opt/freeswitch/lib/libg729.so.1

	insinto /opt/freeswitch/mod
	doins   fsg729/mod_com_g729.so

	newinitd "${FILESDIR}"/freeswitch_license.rc6 freeswitch_license

        einfo "Setting file and directory permissions..."
        # prefix
        chown -R root:freeswitch "${D}/opt/freeswitch"
        chmod -R u=rwX,g=rX,o=   "${D}/opt/freeswitch"
        # allow read access for things like building external modules
        chmod -R u=rwx,g=rx,o=rx "${D}/opt/freeswitch/"{lib*,bin}
        chmod    u=rwx,g=rx,o=rx "${D}/opt/freeswitch"
}

pkg_postinst() {
	echo
	einfo "See \"http://files.freeswitch.org/g729/INSTALL.txt\" for instructions"
	einfo "on how to buy licenses and install them"
}
