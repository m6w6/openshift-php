#!/bin/awk -f
BEGIN {
	FS="[[:space:]]*,[[:space:]]*"
}
/^[[:space:],]*(#|$)/ {
	next
}
{
	extname = $1
	version = $2
	if (NF >= 3 && length($3) > 0) {
		libname = $3
	} else {
		libname = $1
	}
	printf "%s\t%s\t%s\n", extname, version, libname
}
