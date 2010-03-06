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
[ "$1" != "${1#/lib/modules/*/}" ] && {
	prefix="${1#/lib/modules/*/}/"
}

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


		# skip padding lines
		#
		$6 ~ /[.]+$/{ next }

		# extract data 
		#
		/0x[0-9a-f]+/{
			sym_crc  = read_hex32($2);
			sym_name = "";
			line = "";
			off  = 1;

			# 64bit has a different offset
			if (elf_class == "ELF64") {
				line = substr($6, 9);
			} else {
				line = substr($6, 5);
			}

			# filter (imported) symbols with emtpy crc
			if (sym_crc == 0) {
				next
			}

			# sym_name can span multiple lines
			do {
				ptr  = substr(line, off, 1);
				off += 1;
				if (ptr == ".") {
					break;
				}
				sym_name = sym_name""ptr;

				if (off > length(line)) {
					getline
					off  = 1;
					line = $6;
				}
			} while (1);

			# output symvers format line
			printf "0x%08x\t%s\t%s\tEXPORT_SYMBOL%s\n", sym_crc, sym_name, sym_module, sym_license

			next
		}
	'
done
