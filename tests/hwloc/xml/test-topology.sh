#!/bin/sh
#-*-sh-*-

#
# Copyright © 2009 CNRS
# Copyright © 2009-2013 Inria.  All rights reserved.
# Copyright © 2009-2012 Université Bordeaux
# Copyright © 2010-2014 Cisco Systems, Inc.  All rights reserved.
# See COPYING in top-level directory.
#

# Check the conformance of `lstopo' for all the XML
# hierarchies available here.  Return true on success.

HWLOC_top_builddir="/home/laso/bii_lasote/hwloc/blocks/lasote/hwloc"
HWLOC_top_srcdir="/home/laso/bii_lasote/hwloc/blocks/lasote/hwloc"
lstopo="$HWLOC_top_builddir/utils/lstopo/lstopo-no-graphics"

HWLOC_PLUGINS_PATH=${HWLOC_top_builddir}/hwloc
export HWLOC_PLUGINS_PATH

HWLOC_DEBUG_CHECK=1
export HWLOC_DEBUG_CHECK

if test x0 = x1; then
  # make sure we use default numeric formats
  LANG=C
  LC_ALL=C
  export LANG LC_ALL
fi

error()
{
    echo $@ 2>&1
}

if [ ! -x "$lstopo" ]
then
    error "Could not find executable file \`$lstopo'."
    exit 1
fi


: ${TMPDIR=/tmp}
{
  tmp=`
    (umask 077 && mktemp -d "$TMPDIR/fooXXXXXX") 2>/dev/null
  ` &&
  test -n "$tmp" && test -d "$tmp"
} || {
  tmp=$TMPDIR/foo$$-$RANDOM
  (umask 077 && mkdir "$tmp")
} || exit $?
file="$tmp/lstopo_xml.output.xml"

set -e

dirname=`dirname $1`
basename=`basename $1 .xml`

source="${dirname}/${basename}.xml"
source_file="${dirname}/${basename}.source"
test -f "$source_file" && source="${dirname}/"`cat $source_file`

options_file="${dirname}/${basename}.options"
test -f "$options_file" && opts=`cat $options_file`

test -f "${dirname}/${basename}.env" && . "${dirname}/${basename}.env"

do_run()
{
  echo $lstopo --if xml --input "$source" --of xml "$file" $opts
  $lstopo --if xml --input "$source" --of xml "$file" $opts

  if [ "$HWLOC_UPDATE_TEST_TOPOLOGY_OUTPUT" != 1 ]
  then
    diff -u -w "${dirname}/${basename}.xml" "$file"
  else
    if ! diff "${dirname}/${basename}.xml" "$file" >/dev/null
    then
	cp -f "$file" "${dirname}/${basename}.xml"
	echo "Updated ${basename}.xml"
    fi
  fi

  if [ -n "xmllint" ]
  then
    cp -f "$HWLOC_top_srcdir"/hwloc/hwloc.dtd "$tmp/"
    ( cd $tmp ; xmllint --valid lstopo_xml.output.xml ) > /dev/null
  fi

  rm "$file"
}

export HWLOC_NO_LIBXML_IMPORT
export HWLOC_NO_LIBXML_EXPORT

echo "Importing with default parser and reexporting with minimalistic implementation..."
HWLOC_NO_LIBXML_IMPORT=0
HWLOC_NO_LIBXML_EXPORT=1
do_run "$dirname" "$basename"
echo "Importing with minimalistic parser and reexporting with default implementation..."
HWLOC_NO_LIBXML_IMPORT=1
HWLOC_NO_LIBXML_EXPORT=0
do_run "$dirname" "$basename"

rm -rf "$tmp"
