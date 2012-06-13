# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: This ebuild is from freeswitch overlay; Bumped by mva; $

EAPI="4"

inherit linux-mod versionator

MY_P="${PN}-${PV/_p/.}"
DESCRIPTION="Wanpipe driver for Sangoma PCI/PCIe Telephony Cards"
HOMEPAGE="http://www.sangoma.com/"

if [ "${PV/_p/}" = "${PV}" ]; then
	# release version
	SRC_URI="ftp://ftp.sangoma.com/linux/current_wanpipe/${MY_P}.tgz"
else
	# post-release (patched) version
	SRC_URI="ftp://ftp.sangoma.com/linux/custom/$(get_version_component_range 1-2)/${MY_P}.tgz"
fi

IUSE="+dahdi vanilla"
KEYWORDS="~x86 ~amd64"
LICENSE=""
SLOT="0"

RDEPEND="dahdi? ( net-misc/dahdi )
	sys-devel/gcc[cxx]"
DEPEND="${RDEPEND}
	sys-devel/bison
	sys-devel/flex"

S="${WORKDIR}/${P/_p/.}"
S_DAHDI="${WORKDIR}/dahdi"
S_KERNEL="${WORKDIR}/kernel"

src_prepare() {
	###
	# DAHDI: copy includes
	#
	if use dahdi; then
		mkdir -p "${S_DAHDI}"/{include,drivers/dahdi} || die "Failed to create directory for dahdi includes"
		cp -R "${ROOT}/usr/include/dahdi" "${S_DAHDI}/include" || die "Failed to copy dahdi headers"

		###
		# !!! HACK Alert !!!
		#
		# wanpipe-3.5.25 needs include/dahdi/version.h, which (of course) is not part of the public API
		# (not installed by DAHDI install-includes target), so create a fake version.h as a "workaround".
		#
		# !!! HACK Alert !!!
		#
		DAHDI_VER="$(best_version net-misc/dahdi)"
		DAHDI_VER="$(get_version_component_range 1-4 "${DAHDI_VER#*dahdi-}")"

		[ -z "${DAHDI_VER}" ] && die "Failed to create fake ${S_DAHDI}/include/dahdi/version.h"

		cat ->"${S_DAHDI}/include/dahdi/version.h" <<-EOF
		/*
		 * Fake DAHDI version.h created by ${PF} ebuild
		 */
		#define DAHDI_VERSION "${DAHDI_VER}"
		EOF


		if linux_chkconfig_builtin MODVERSIONS; then
			# extract symbol version
			/bin/sh "${FILESDIR}/extract_symver.sh" \
				"/lib/modules/${KV_FULL}/dahdi" > "${S_DAHDI}/drivers/dahdi/Module.symvers" || die "Failed to extract dahdi modules symbol version"
		else
			# shut up bogus wanpipe error message and modpost warnings,
			# create a fake Module.symvers for dahdi.ko
			#
			cat - >"${S_DAHDI}/drivers/dahdi/Module.symvers" <<-EOF
			0x00000000	dahdi_rbsbits	dahdi/dahdi	EXPORT_SYMBOL_GPL
			0x00000000	dahdi_ec_chunk	dahdi/dahdi	EXPORT_SYMBOL_GPL
			0x00000000	dahdi_alarm_channel	dahdi/dahdi	EXPORT_SYMBOL_GPL
			0x00000000	dahdi_unregister	dahdi/dahdi	EXPORT_SYMBOL_GPL
			0x00000000	dahdi_ec_span	dahdi/dahdi	EXPORT_SYMBOL_GPL
			0x00000000	dahdi_receive	dahdi/dahdi	EXPORT_SYMBOL_GPL
			0x00000000	dahdi_hooksig	dahdi/dahdi	EXPORT_SYMBOL_GPL
			0x00000000	dahdi_qevent_lock	dahdi/dahdi	EXPORT_SYMBOL_GPL
			0x00000000	dahdi_register	dahdi/dahdi	EXPORT_SYMBOL_GPL
			0x00000000	dahdi_transmit	dahdi/dahdi	EXPORT_SYMBOL_GPL
			0x00000000	dahdi_hdlc_getbuf	dahdi/dahdi	EXPORT_SYMBOL_GPL
			0x00000000	dahdi_alarm_notify	dahdi/dahdi	EXPORT_SYMBOL_GPL
			EOF
		fi
	fi

	###
	# Kernel: create a local copy, so wanpipe doesn't
	#         mess up things in /usr/src/...
	#
	# Credits: based on the wanpipe-3.1.4 ebuild in http://bugs.gentoo.org/show_bug.cgi?id=188939
	#
	mkdir -p "${S_KERNEL}" || die "Failed to create create ${S_KERNEL}"
	cp -dPR "${KERNEL_DIR}/include" "${S_KERNEL}" || die "Failed to copy ${KV_FULL} includes to ${S_KERNEL}"
	ln -s "${KERNEL_DIR}/Makefile"  "${S_KERNEL}/Makefile" || die "Failed to symlink ${KV_FULL} Makefile"
	ln -s "${KERNEL_DIR}/scripts"   "${S_KERNEL}/scripts"  || die "Failed to symlink ${KV_FULL} scripts"
	ln -s "${KERNEL_DIR}/arch"      "${S_KERNEL}/arch"     || die "Failed to symlink ${KV_FULL} arch"
	ln -s "${KERNEL_DIR}/.config"   "${S_KERNEL}/.config"  || die "Failed to symlink ${KV_FULL} .config"

	[ -f "${KERNEL_DIR}/Module.symvers" ] && \
		ln -s "${KERNEL_DIR}/Module.symvers" "${S_KERNEL}/Module.symvers"

	# Remove kernel's (old) wanrouter.h,
	# so we're really only using wanpipe's version
	#
	rm -f "${S_KERNEL}/include/linux/wanrouter.h" || die "Failed to remove ${KV_FULL} old linux/wanrouter.h"

	###
	# Wanpipe: disable header cleaning script,
	#          disable depmod call
	#
	epatch "${FILESDIR}/${PN}-3.5.27-Makefile.patch"

	if ! use vanilla ; then
		# Silence "jobserver unavailable" messages and QA warnings
		epatch "${FILESDIR}/${PN}-3.5.27-QA-fix-parallel-make.patch"

		# Silence gcc-4.4 "warning: format not a string literal and no format arguments"
		epatch "${FILESDIR}/${PN}-3.5.27-QA-fix-format-literal-warnings.patch"

		# Silence gcc-4.4 "warning: deprecated conversion from string constant to 'char*'"
		epatch "${FILESDIR}/${PN}-3.5.27-QA-fix-const-char-warnings.patch"

		# Silence "ignoring return value of 'XXXX', declared with attribute warn_unused_result"
		epatch "${FILESDIR}/${PN}-3.5.27-QA-fix-warn_unused_result.patch"
		epatch "${FILESDIR}/${PN}-3.5.27-QA-fix-warn_unused_result-legacy.patch"
	else
		ewarn "Vanilla wanpipe build, all non-mandatory patches are disabled!"
	fi

#	# Remove some include paths
#	sed -i -e "s:-I\$(INSTALLPREFIX)/include::; s:-I\$(INSTALLPREFIX)/usr/include::" \
#		Makefile
}

src_compile() {
	# DEBUG: deny write access to linux source
	addread "${KERNEL_DIR}"

	use dahdi && \
		build_target="all_src_dahdi"

	# Build everything
	# Use LDCONFIG="/bin/true" to avoid sandbox violation
	emake ${build_target:-all_src} all_lib \
		ARCH="$(tc-arch-kernel)" \
		WARCH="$(tc-arch-kernel)" \
		DAHDI_DIR="${S_DAHDI}" \
		KVER="${KV_FULL}" \
		KDIR="${S_KERNEL}" \
		LDCONFIG="/bin/true" \
		DESTDIR="${D}" || die "Failed to build wanpipe"
}

src_install() {
	# Install drivers, tools, headers and libs
	# Use LDCONFIG="/bin/true" to avoid sandbox violation
	emake -j1 install \
		ARCH="$(tc-arch-kernel)" \
		WARCH="$(tc-arch-kernel)" \
		DAHDI_DIR="${S_DAHDI}" \
		KVER="${KV_FULL}" \
		KDIR="${S_KERNEL}" \
		LDCONFIG="/bin/true" \
		DESTDIR="${D}" || die "Failed to install wanpipe"

	# remove bogus symlink
	rm "${D}/usr/include/wanpipe/linux"

	# remove trixbox setup script
	rm -r "${D}/usr/local"

	# fixup permissions
	find "${D}/usr/include/wanpipe" -type f -exec chmod 644 {} \;

	# empty, but used by wanpipe/-router scripts
	keepdir /etc/wanpipe/{interfaces,scripts}

	# remove duplicate wan_aftup binary from /etc/wanpipe...
	# TODO: fixup Makefile
	sed -i -e 's:\(\./\)\?wan_aftup:/usr/sbin/wan_aftup:g' \
		"${D}/etc/wanpipe/util/wan_aftup/update_aft_firm.sh" || die "Failed to update update_aft_firm.sh"
	rm "${D}/etc/wanpipe/util/wan_aftup/wan_aftup"

	# find leftover files in /etc/wanpipe
	find "${D}/etc/wanpipe" -type f -iname "Makefile" -exec rm {} \;

	# remove .svn directories...
	find "${D}" -type d -name ".svn" -exec rm -rf {} \;

	# clean up /etc/wanpipe/wancfg_zaptel
	# (all these are already in /usr/sbin or useless)
	for x in setup-sangoma wancfg_{zaptel,dahdi,tdmapi,openzap,fs,smg,hp_tdmapi} {clean,install,uninstall}.sh; do
		rm "${D}/etc/wanpipe/wancfg_zaptel/${x}" || die "Failed to remove /etc/wanpipe/wancfg_zaptel/${x}"
	done

	# fix WAN_LOCK(_DIR)
	sed -i -e '/^WAN_LOCK\(_DIR\)\?=/s:/var/lock/subsys:/var/lock:' \
		"${D}/etc/wanpipe/wanrouter.rc" \
		"${D}/etc/wanpipe/wancfg_zaptel/templates/wanrouter.rc.template" \
		|| die "Failed to update WAN_LOCK(_DIR)"

	# ugh, this shouldn't be there, really...
	if ! use vanilla ; then
		rm -rf "${D}/etc/wanpipe/api" || die "Failed to remove api folder"
	fi

	# move samples to /usr/share/doc/...
	dodir "/usr/share/doc/${PF}"
	rm "${D}/etc/wanpipe/samples/clean.sh"
	mv "${D}/etc/wanpipe/samples" "${D}/usr/share/doc/${PF}" || die "Failed to move samples to /usr/share/doc/${PF}"

	# install udev rules
	insinto "/etc/udev/rules.d"
	doins "${FILESDIR}/wanpipe.rules"

	# install wanrouter init script
	newinitd "${FILESDIR}/wanrouter.rc6" wanrouter
}

pkg_preinst() {
	#
	# Newer wanpipe versions use a symlink for oct6100_api, while older used
	# a directory (duplicating a lot of files)
	#
	# Remove the directory to avoid a conflict during package installation
	#
	if [ -d "${ROOT}/usr/include/wanpipe/oct6100_api" ]
	then
		einfo "Removing old ${ROOT}/usr/include/wanpipe/oct6100_api, new wanpipe version will use a symlink here"
		rm -rf "${ROOT}/usr/include/wanpipe/oct6100_api" || die "Failed to remove directory"
	fi
}
