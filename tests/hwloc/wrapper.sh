#!/bin/sh
#-*-sh-*-

#
# Copyright © 2012-2013 Inria.  All rights reserved.
# See COPYING in top-level directory.
#

HWLOC_top_builddir="/home/laso/bii_lasote/hwloc/blocks/lasote/hwloc"

HWLOC_PLUGINS_PATH=${HWLOC_top_builddir}/src
export HWLOC_PLUGINS_PATH

HWLOC_DEBUG_CHECK=1
export HWLOC_DEBUG_CHECK

"$@"
