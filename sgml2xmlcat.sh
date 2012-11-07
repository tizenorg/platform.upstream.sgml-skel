#!/bin/bash
# Copyright (C) 2002 by SuSE Linux AG.
# Author: Karl Eichwalder <ke@suse.de>, 2002.
# GPL
#
# usage:
#        $0 -i SGML-CAT [-l -s SGML-DIR -p PACKAGE-DIR] [-x XML-CAT]
# Create SGML links (used by psgml)
# Convert a normalized SGML catalog to an XML catalog.

package=sgml-skel
version=0.6

export LC_ALL=C; export LANG=C; export LANGUAGE=C

# Note that we use `"$@"' to let each command-line parameter expand to a 
# separate word. The quotes around `$@' are essential!
# We need TEMP as the `eval set --' would nuke the return value of getopt.
TEMP=`getopt -o c:di:lp:s:x: --long debug:xmlcatalog:,create-links,packagedir:,sgmlcat:,sgmldir: \
     -n 'example.bash' -- "$@"`

if [ $? != 0 ] ; then echo "Terminating..." >&2 ; exit 1 ; fi

# Note the quotes around `$TEMP': they are essential!
eval set -- "$TEMP"

while true ; do
  case "$1" in
    -d|--debug) set -x; shift ;;
    -i|--sgmlcat*) sgmlcat="$2"; shift 2 ;;
    -l|--create-links) links=yes ; shift ;;
    -s|--sgmldir) sgmldir="$2" ; shift 2 ;;
    -p|--packagedir) packagedir="$2" ; shift 2 ;;
    -x|-c|--xmlcat*) 
			# c has an optional argument. As we are in quoted mode,
			# an empty parameter will be generated if its optional
			# argument is not found.
      case "$2" in
	-*) catalog=yes ; { echo "$1: missing argument" ; exit 1; } ;;
	*)  catalog=yes ; xmlcat="$2" ; shift 2 ;;
      esac ;;
    --) shift ; break ;;
    *) echo "Internal error!" ; exit 1 ;;
  esac
done

# sed -n -e '
# /^\(OVERRIDE\|SGMLDECL\)/d
# /^ /d
# /^$/d
# /^--/d
# s:^\([A-Za-z]*\).*"\(.*\)"[ ]*"\?\(.*\)"\?:\1|\2|\3:p' $1

if [ -z "$sgmlcat" -o ! -r "$sgmlcat" ]; then
  echo "-i not set or SGML catalog file \"$sgmlcat\" not found"; exit 1;
fi
[ -n "$catalog" -a ! -r "$xmlcat" ] && xmlcatalog --noout --create $xmlcat
if [ -n "$links" ]; then
  [ -z "$sgmldir" ] && { echo "-s not set"; exit 1; }
  [ -z "$packagedir" ] && { echo "-p not set"; exit 1; }
fi

while read line; do
  OLDIFS=$IFS; IFS='|'
  set -- $(echo "$line")
  IFS=$OLDIFS
  # echo $3 $2 $1
  if [ -n "$catalog" ]; then
    [ "public" = $(tr [:upper:] [:lower:] < <(echo $1)) ] && {
      xmlcatalog --noout --add "public" \
        "$2" "file://$3" "$xmlcat"
    }
  fi
  if [ -n "$links" ]; then
    # echo install-dtd.sh -s "$sgmldir" -p "$packagedir" -f "${3##*/}" -i "$2"
    install-dtd.sh -s "$sgmldir" -p "$packagedir" -f "${3##*/}" -i "$2"
  fi
done < <(sed -n -e '
/^\(OVERRIDE\|SGMLDECL\|CATALOG\|DTDDECL\)/d
/^ /d
/^$/d
/^--/d
s:^\([A-Za-z]*\)[ 	]*"\([^"]*\)"[ 	]*"\?\([^"]*\)"\?:\1|\2|\3:p' \
"$sgmlcat")

# s:^\([A-Za-z]*\).*"\(.*\)".*"\(.*\)":\1|\2|\3:p' $1)

exit
