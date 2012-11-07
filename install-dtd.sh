#!/bin/bash
# Copyright (C) 2001 by SuSE GmbH.
# Copyright (C) 2002 by SuSE Linux AG.
# Author: Karl Eichwalder <ke@suse.de>, 2001-2002.
# GPL

package=sgml-skel
version=0.6

LANGUAGE=C; export LANGUAGE
LC_ALL=C; export LC_ALL

# debug=yes

progname=${0##*/}
usage="\
Usage: $progname

  -d, --debug
  -f, --filename FILENAME
  -h, --help
  -i, --identifier STRING
  -p, --packagedir DIR
  -s, --sgmldir DIR          default: usr/share/sgml

Example:

    $progname -p website-xml-dtd --sgmldir /usr/share/sgml \\
              --identifier '-//Norman Walsh//DTD Website V1.9//EN' \\
              --filename website.dtd

Version info: $progname ($package) $version

Please, report bugs to Karl Eichwalder <feedback@suse.de>."

while test $# -gt 0; do
  case $1 in
    -d | --debug) debug=yes; shift 1; ;;
    -p | --packagedir)  if test $# -gt 1; then pkgdir=$2; shift 2;
                 else echo "$usage"; exit 1; fi ;;
    -s | --sgmldir)  if test $# -gt 1; then sgmldir=$2; shift 2;
                 else echo "$usage"; exit 1; fi ;;
    -h | --h* ) echo "$usage"; exit 0 ;;
    -i | --id*)   if test $# -gt 1; then identifier=$2; shift 2;
                 else echo "$usage"; exit 1; fi ;;
    -f | --file*)   if test $# -gt 1; then filename=$2; shift 2;
                 else echo "$usage"; exit 1; fi ;;
    -*) echo "Try '$progname --help' for more information."; exit 1 ;;
    *) break
  esac
done

_debug(){
  [ x$debug = xyes ] && echo -e $1
}

# identifier=$1
sgmldir=${sgmldir-usr/share/sgml}

_debug $sgmldir

[ -d $sgmldir/$pkgdir ] || { \
  echo "no such directory: $sgmldir/$pkgdir"; exit 1;
}
[ -f $sgmldir/$pkgdir/$filename ]  || { \
  echo "no such file: $sgmldir/$pkgdir/$filename"; exit 1;
}

id_split_old() {
  # identifier='-//Norman Walsh//DTD Website V1.9//EN'
  identifier=$1
  id=${identifier// /_}
  rest=${id#*//}
  owner=${rest%%//*}
  rest=${rest#*//}
  class=$(echo ${rest%%_*} | tr [[:upper:]] [[:lower:]])
  rest=${rest#*_}
  desc=${rest%%//*}
}

id_split() {
  # identifier='-//Norman Walsh//DTD Website V1.9//EN//XML'
  # id          indicator
  #                owner         class
  #                                  description   language
  #                                                    version
  if [ "${1:0:4}" = 'ISO ' ]; then
    id=$1
  else
    if [ ${1:0:3} = '-//' -o ${1:0:3} = '-//' ]; then
      id=${1#*//}
    else
      echo "$1 is not a valid identifier" ; exit 1
    fi
  fi
  _debug "id: $id"
  id=${id// /_}
  _debug "id: $id"
  owner=${id%%//*}
  _debug $owner
  id=${id#*//}
  _debug "id: $id"
  class=$(echo ${id%%_*} | tr [[:upper:]] [[:lower:]])
  _debug $class
  id=${id#*_}
  _debug "id: $id"
  desc=${id%%//*}
  _debug $desc
  id=${id/$desc/}
  _debug "id: $id"
  [ -n "$id" ] && {
    if [ ${id:0:2} = '//' ]; then
      id=${id#//}
      _debug "id: $id"
      lang=${id%%//*}
      id=${id/$lang/}
      lang=$(echo $lang | tr [[:upper:]] [[:lower:]])
      _debug "lang: $lang"
    else
      echo "$id is not a valid language part" ; exit 1
    fi
  }
  _debug "id: $id"
  [ -n "$id" ] && {
    if [ ${id:0:2} = '//' ]; then
      ver=${id#//}
      _debug "version: $ver"
    else
      echo "$id is not a valid version part" ; exit 1
    fi
  }
}

id_split "$identifier"
_debug "\
identifier: $identifier\n
owner: $owner\n
class: $class\n
desc: $desc\n
lang: $lang\n
version: $ver"

pushd $sgmldir >/dev/null
  classdir=$owner/$class
  [ -d $classdir ] || mkdir -p $classdir
  if [ -n "$ver" ]; then
    linkname=$classdir/${desc}_${ver}
  else
    linkname=$classdir/${desc}
  fi
  [ -L $linkname ] && rm -f $linkname
  ln -s ../../$pkgdir/$filename $linkname
popd >/dev/null

# eof
