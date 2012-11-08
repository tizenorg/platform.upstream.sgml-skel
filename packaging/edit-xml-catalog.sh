#!/bin/bash

# $0 $for_root_catalog add|del
export LC_ALL=C

usage="\
$0 [-a|-d] [--add|--del] [-c|--catalog /etc/xml/CATALOG] CATALOG_FRAGMENT_FILE"
# TEMP=$(getopt -o ac:dghv \
#   --long add,cat:,catalog:,del,delete,group,help,verbose \
#   -n "$0" -- "$@")
# # Note the quotes around `$TEMP': they are essential!
# eval set -- "$TEMP"

ROOTCATALOG=/etc/xml/catalog
mode=add
echo=true
while test $# -gt 0; do
# while true ; do
  case "$1" in
    -h|--help) echo "$usage"; exit 0 ;;
    -a|--add) mode=add; shift ;;
    -c|--cat*) if test $# -gt 1; then ROOTCATALOG="$2"; shift 2;
      else echo "$usage"; exit 1; fi ;;
    -d|--del*) mode=del; shift ;;
    -g|--group) marker=group; shift ;;
    -v|--verbose) verbose="-v"; echo=echo; shift ;;
    --) shift ; break ;;
    *) break ;;
    # *) echo "Internal error!" ; exit 1 ;;
  esac
done
FOR_ROOT_CAT=$1

[ -z "$FOR_ROOT_CAT" ] && { echo $usage; exit 1; }

xmlcat=/usr/bin/xmlcatalog
xmllint=/usr/bin/xmllint

for b in $xmlcat $xmllint; do
  [ -x $b ] || { echo "error: $b does not exist" ; exit 1; }
done

prep_catalog () {
  local cat=$1
  [ -s $cat ] || rm -f $cat
  if [ -r $cat ]; then
    if grep -q '"urn:oasis:names:tc:entity:xmlns:xml:catalog"/>' $cat; then
      rm -f $cat
    fi
  fi
  if [ ! -r $cat ] ; then
    $xmlcat --create | sed 's:/>:>\
</catalog>:' >$cat
  # echo Failed creating XML Catalog root $1
  fi
}

# Check /etc/xml/catalog
prep_catalog /etc/xml/catalog

if [ "$ROOTCATALOG" != /etc/xml/catalog ]; then
  root=${ROOTCATALOG#/etc/xml/}
  if ! grep -q "nextCatalog.*catalog=\"${root}\"" /etc/xml/catalog; then
    sed -i "/<\/catalog>/i\\
<nextCatalog catalog=\"${root}\"/>" /etc/xml/catalog
  fi
  prep_catalog "$ROOTCATALOG"
fi

add_entry () {
  {
    sed '/<\/catalog>/d' $ROOTCATALOG
    $xmllint --nocatalogs --format ${FOR_ROOT_CAT} \
      | awk '\
/<\/catalog>/{next}
s == 1 {print}
/<catalog/{s=1}
END{print "</catalog>"}'
  } >$ROOTCATALOG.tmp
  if [ -x /bin/chmod ]; then
    /bin/chmod --reference=$ROOTCATALOG $ROOTCATALOG.tmp
  fi
  $xmllint --nocatalogs --noout $ROOTCATALOG.tmp \
    && mv $ROOTCATALOG.tmp $ROOTCATALOG
}

del_entry () {
  pattern=$FOR_ROOT_CAT
  $echo $pattern
  if [ -r $ROOTCATALOG ]; then
    # Either delete <group>...</group>
    # or  <!-- pac_start: ... -->...<!-- pac_end: ... -->
    if [ "$marker" = "group" ]; then
      $xmllint --nocatalogs --format $ROOTCATALOG \
        | awk "\
/<\/group>/ && s == 1 {s=0;next}
s == 1 {next}
/<group id=\"$pattern\">/{s=1;next}
{print}" > $ROOTCATALOG.tmp
    else
    $xmllint --nocatalogs --format $ROOTCATALOG \
      | awk "\
/<!-- pac_end: $pattern do not remove! -->/{s=0;next}
s == 1 {next}
/<!-- pac_start: $pattern do not remove! -->/{s=1;next}
{print}" > $ROOTCATALOG.tmp
    fi
    if [ -x /bin/chmod ]; then
      /bin/chmod --reference=$ROOTCATALOG $ROOTCATALOG.tmp
    fi
    $xmllint --nocatalogs --noout $ROOTCATALOG.tmp \
      && mv $ROOTCATALOG.tmp $ROOTCATALOG
  fi
}

case "$mode" in
  del)
    del_entry
    ;;
  add)
    [ -r ${FOR_ROOT_CAT} ] || { echo \"$FOR_ROOT_CAT\" does not exist; exit 1; }
    add_entry
    ;;
  *)
esac

exit
