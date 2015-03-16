#!/bin/sh
#-*-sh-*-

#
# Copyright © 2009 CNRS
# Copyright © 2009-2014 Inria.  All rights reserved.
# Copyright © 2009 Université Bordeaux
# Copyright © 2014 Cisco Systems, Inc.  All rights reserved.
# See COPYING in top-level directory.
#

VERSION="2.0.0a1-git"
HWLOC_top_srcdir="/home/laso/bii_lasote/hwloc/blocks/lasote/hwloc"
HWLOC_top_builddir="/home/laso/bii_lasote/hwloc/blocks/lasote/hwloc"
srcdir="$HWLOC_top_srcdir/utils/hwloc"
builddir="$HWLOC_top_builddir/utils/hwloc"
info="$builddir/hwloc-info"

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
file="$tmp/test-hwloc-info.output"

set -e
(
  $info --if synthetic --input "node:2 core:3 pu:4"
  echo
  $info --if synthetic --input "node:2 core:3 pu:4" core:2-4
  echo
  $info --if synthetic --input "node:2 core:3 pu:4" -n --ancestors pu:10-11
  echo
  $info --if synthetic --input "node:2 core:3 pu:4" --ancestor node pu:7-9
  echo
  $info --if synthetic --input "node:2 core:2 ca:2 ca:2 pu:2" --ancestor l2 pu:12
  echo
  $info --if synthetic --input "node:2 core:2 ca:2 ca:2 pu:2" --ancestor l1 -s pu:7-10
) \
 | grep -v " info hwlocVersion = $VERSION" \
 | grep -v " info ProcessName = hwloc-info" \
 | grep -v " info ProcessName = lt-hwloc-info" \
 > "$file"
# filtered hwlocVersion since it often changes
# filtered ProcessName since it may be hwloc-info or lt-hwloc-info
diff -u $srcdir/test-hwloc-info.output "$file"
rm -rf "$tmp"
