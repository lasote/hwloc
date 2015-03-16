#!/bin/sh
#-*-sh-*-

#
# Copyright © 2013 Inria.  All rights reserved.
# Copyright © 2014 Cisco Systems, Inc.  All rights reserved.
# See COPYING in top-level directory.
#

HWLOC_top_srcdir="/home/laso/bii_lasote/hwloc/blocks/lasote/hwloc"
HWLOC_top_builddir="/home/laso/bii_lasote/hwloc/blocks/lasote/hwloc"
srcdir="$HWLOC_top_srcdir/utils/hwloc"
builddir="$HWLOC_top_builddir/utils/hwloc"
compress="$builddir/hwloc-compress-dir"

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

set -e

(cd "$tmp" && gunzip -c $srcdir/test-hwloc-compress-dir.input.tar.gz | tar xf -)
(cd "$tmp" && gunzip -c $srcdir/test-hwloc-compress-dir.output.tar.gz | tar xf -)
(cd "$tmp" && mkdir test-hwloc-compress-dir.newoutput)
(cd "$tmp" && mkdir test-hwloc-compress-dir.newoutput2)

$compress "$tmp/test-hwloc-compress-dir.input" "$tmp/test-hwloc-compress-dir.newoutput"

diff -u -r "$tmp/test-hwloc-compress-dir.output" "$tmp/test-hwloc-compress-dir.newoutput"

$compress -R "$tmp/test-hwloc-compress-dir.newoutput" "$tmp/test-hwloc-compress-dir.newoutput2"

diff -u -r "$tmp/test-hwloc-compress-dir.input" "$tmp/test-hwloc-compress-dir.newoutput2"

rm -rf "$tmp"
