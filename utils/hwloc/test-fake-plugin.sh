#!/bin/sh
#-*-sh-*-

#
# Copyright © 2009-2014 Inria.  All rights reserved.
# Copyright © 2009, 2011 Université Bordeaux
# Copyright © 2014 Cisco Systems, Inc.  All rights reserved.
# See COPYING in top-level directory.
#

HWLOC_top_builddir="/home/laso/bii_lasote/hwloc/blocks/lasote/hwloc"
builddir="$HWLOC_top_builddir/utils/lstopo"
lstopo="$builddir/lstopo-no-graphics"

HWLOC_PLUGINS_PATH=${HWLOC_top_builddir}/hwloc
export HWLOC_PLUGINS_PATH

HWLOC_DEBUG_FAKE_COMPONENT=1
export HWLOC_DEBUG_FAKE_COMPONENT

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
file="$tmp/test-fake-plugin.output"

set -e

$lstopo > $file

grep "fake component initialized" $file \
&& grep "fake component instantiated" $file \
&& grep "fake component finalized" $file

rm -rf "$tmp"
