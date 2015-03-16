#!/bin/sh
#-*-sh-*-

#
# Copyright © 2009 CNRS
# Copyright © 2009-2014 Inria.  All rights reserved.
# Copyright © 2009 Université Bordeaux
# Copyright © 2014 Cisco Systems, Inc.  All rights reserved.
# See COPYING in top-level directory.
#

HWLOC_top_srcdir="/home/laso/bii_lasote/hwloc/blocks/lasote/hwloc"
HWLOC_top_builddir="/home/laso/bii_lasote/hwloc/blocks/lasote/hwloc"
srcdir="$HWLOC_top_srcdir/utils/hwloc"
builddir="$HWLOC_top_builddir/utils/hwloc"
distrib="$builddir/hwloc-distrib"

HWLOC_PLUGINS_PATH=${HWLOC_top_builddir}/hwloc
export HWLOC_PLUGINS_PATH

HWLOC_DEBUG_CHECK=1
export HWLOC_DEBUG_CHECK

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
file="$tmp/test-hwloc-distrib.output"

set -e
(
  $distrib --if synthetic --input "2 2 2" 2
  echo
  $distrib --if synthetic --input "2 2 2" 4
  echo
  $distrib --if synthetic --input "2 2 2" 8
  echo
  $distrib --if synthetic --input "2 2 2" 13
  echo
  $distrib --if synthetic --input "2 2 2" 16
  echo
  $distrib --if synthetic --input "3 3 3" 4
  echo
  $distrib --if synthetic --input "3 3 3" 4 --single
  echo
  $distrib --if synthetic --input "3 3 3" 4 --reverse
  echo
  $distrib --if synthetic --input "3 3 3" 4 --reverse --single
  echo
  $distrib --if synthetic --input "4 4" 2
  echo
  $distrib --if synthetic --input "4 4" 2 --single
  echo
  $distrib --if synthetic --input "4 4" 2 --reverse --single
  echo
  $distrib --if synthetic --input "4 4 4 4" 19
) > "$file"
diff -u $srcdir/test-hwloc-distrib.output "$file"
rm -rf "$tmp"
