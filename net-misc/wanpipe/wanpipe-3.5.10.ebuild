#
#
#
EAPI="2"

inherit linux-mod

DESCRIPTION="Wanpipe driver for Sangoma PCI/PCIe Telephony Cards"
HOMEPAGE="http://www.sangoma.com/"
SRC_URI="ftp://ftp.sangoma.com/linux/current_wanpipe/${P}.tgz"

IUSE=""
KEYWORDS="~x86"
LICENSE=""
SLOT="0"

RDEPEND="net-misc/dahdi"
DEPEND="${RDEPEND}"

S="${WORKDIR}/${P}"
S_DAHDI="${WORKDIR}/dahdi"
S_KERNEL="${WORKDIR}/kernel"

#pkg_setup() {
#	linux-mod_pkg_setup
#}

src_prepare() {
	###
	# DAHDI: copy includes
	#
	if true; then
		mkdir -p "${S_DAHDI}"/{include,drivers/dahdi} || die "Failed to create directory for dahdi includes"
		cp -R "${ROOT}/usr/include/dahdi" "${S_DAHDI}/include" || die "Failed to copy dahdi headers"

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
	#          do not install headers during "make all_util"
	#
	epatch "${FILESDIR}/${P}-Makefile.patch"

	# Silence memset/memcpy implicit declaration QA warnings
	epatch "${FILESDIR}/${P}-silence-QA-warnings.patch"

	# Silence "jobserver unavailable" messages and QA warnings
	epatch "${FILESDIR}/${P}-QA-fix-parallel-make.patch"

#	# Remove some include paths
#	sed -i -e "s:-I\$(INSTALLPREFIX)/include::; s:-I\$(INSTALLPREFIX)/usr/include::" \
#		Makefile
}

src_compile() {
	# DEBUG: deny write access to linux source
	addread "${KERNEL_DIR}"

	# Build everything
	emake dahdi DAHDI_DIR="${S_DAHDI}" KVER="${KV_FULL}" KDIR="${S_KERNEL}" DESTDIR="${D}" || "Failed to build wanpipe"
}

src_install() {
	emake install DESTDIR="${D}" || die "Failed to install wanpipe"

	# remove bogus symlink
	rm "${D}/usr/include/wanpipe/linux"

	# remove trixbox setup script
	rm -r "${D}/usr/local"

	# fixup permissions
	find "${D}/usr/include/wanpipe" -type f -exec chmod 644 {} \;
}
