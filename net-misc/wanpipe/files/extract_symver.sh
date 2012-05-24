#!/bin/sh
#
# Extract Module.symvers style information from kernel modules (*.ko)
# Copyright (C) 2010 Stefan Knoblich <s.knoblich@axsentis.de>
#

# readelf is required to extract data
[ -z "$(which readelf)" ] && {
	echo "Error: readelf not found" >&2
	exit 1
}

# check argument
[ -z "$1" -o ! -d "$1" ] && {
	echo "Usage: $0 <directory>" >&2
	exit 1
}

# special handling for installed modules
#[ "$1" != "${1#/lib/modules/*/}" ] && {
#	prefix="${1#/lib/modules/*/}/"
#}

# 
case "$2" in
GPL|gpl)
	license="_GPL"
	;;
*)
	;;
esac

find "$1" -type f -iname "*.ko" |\
while read fn; do
	elfclass="$(readelf -h "${fn}" | awk '/Class:/{ print $2 }')"

	# calculate prefix for modules
	prefix="$(dirname "${fn}")/"

	[ "${prefix}" != "${prefix#/lib/modules/*/}" ] && \
		prefix="${prefix#/lib/modules/*/}"

	# extract version information from non-GPL symbols (__kcrctab + .rela__kcrctab)	
	readelf -W -r "$fn" |\
	awk -v sym_module="${prefix}`basename ${fn/.ko}`" -v sym_license="${license}" '
		#
		# sample readelf output:
		#
		/__crc_/{
			sym_crc  = strtonum("0x"$4);
			sym_name = substr($5, length("__crc_") + 1);

			printf "0x%08x\t%s\t%s\tEXPORT_SYMBOL%s\n", sym_crc, sym_name, sym_module, sym_license
		}
	'

	# extract regular version information
	readelf -x __versions "$fn" |\
	awk -v sym_module="${prefix}`basename ${fn/.ko}`" -v sym_license="${license}" -v elf_class="${elfclass}" '
		#
		# sample readelf output:
		#
		# Hex dump of section '__versions':
		#  0x00000000 f6664954 6d6f6475 6c655f6c 61796f75 .fITmodule_layou
		#  0x00000010 74000000 00000000 00000000 00000000 t...............
		#  0x00000020 00000000 00000000 00000000 00000000 ................
		#  0x00000030 00000000 00000000 00000000 00000000 ................
		#  0x00000040 c0fbc36b 5f5f756e 72656769 73746572 ...k__unregister
		#  ...
		#
		function read_hex32(inp) {
			tmp = substr(inp, 7, 2) "" substr(inp, 5, 2) "" substr(inp, 3, 2) "" substr(inp, 1, 2);
			return strtonum("0x"tmp);
		}

		BEGIN{
			# offset of symbol name in entries first line,
			# different for 32 and 64bit
			if (elf_class == "ELF64") {
				name_offset = 58;
			} else {
				name_offset = 54;
			}
		}

		# skip padding lines
		#
		$6 ~ /^\.{16}$/{ next }

		# extract data 
		#
		/0x[0-9a-f]+/{
			sym_crc  = read_hex32($2);
			sym_name = "";
			line = "";
			off  = 1;

			# extract from $0 to avoid problems with space ('0x20')
			# chars in ascii output of crc checksum
			line = substr($0, name_offset);

			# filter (imported) symbols with emtpy crc
			if (sym_crc == 0) {
				next
			}

			# sym_name can span multiple lines
			do {
				if ((off = index(line, ".")) == 0) {
					sym_name = sym_name line;
					getline;
					line = $6;
					continue;
				} else if (off == 1) {
					break;
				} else {
					sym_name = sym_name substr(line, 1, off - 1);
					break;
				}
			} while (1);

			# output symvers format line
			printf "0x%08x\t%s\t%s\tEXPORT_SYMBOL%s\n", sym_crc, sym_name, sym_module, sym_license

			next
		}
	'
done
