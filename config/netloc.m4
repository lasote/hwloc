dnl -*- Autoconf -*-
dnl
dnl Copyright © 2014 Cisco Systems, Inc.  All rights reserved.
dnl
dnl Copyright © 2014 Inria.  All rights reserved.
dnl See COPYING in top-level directory.

# Main hwloc m4 macro, to be invoked by the user
#
# Expects:
# 1. Configuration prefix
# 2. What to do upon success
# 3. What to do upon failure
# 4. If non-empty, print the announcement banner
#
AC_DEFUN([NETLOC_SETUP_CORE],[
    AC_REQUIRE([HWLOC_SETUP_CORE])
    AC_REQUIRE([AC_PROG_CC])

    AS_IF([test "x$4" != "x"],
          [cat <<EOF

###
### Configuring netloc core
###
EOF])

    # If no prefix was defined, set a good value
    m4_ifval([$1],
             [m4_define([netloc_config_prefix],[$1/])],
             [m4_define([netloc_config_prefix], [])])

    # These flags are specific to netloc, and should not be redundant
    # with hwloc.  I.e., if the flag already exists in hwloc, there's
    # no need to put it here.
    NETLOC_CFLAGS=
    NETLOC_CPPFLAGS=$JANSSON_CPPFLAGS
    NETLOC_LDFLAGS=
    NETLOC_LIBS=
    NETLOC_LIBS_PRIVATE=

    # Setup the individual parts of Netloc
    netloc_happy=yes
    AS_IF([test "$netloc_happy" = "yes"],
          [NETLOC_CHECK_PLATFORM([netloc_happy])])
    AS_IF([test "$netloc_happy" = "yes"],
          [NETLOC_SETUP_JANSSON([netloc_happy])])

    AC_SUBST(NETLOC_CFLAGS)
    AC_SUBST(NETLOC_CPPFLAGS)
    AC_SUBST(NETLOC_LDFLAGS)
    AC_SUBST(NETLOC_LIBS)
    AC_SUBST(NETLOC_LIBS_PRIVATE)

    # Set these values explicitly for embedded builds.  Exporting
    # these values through *_EMBEDDED_* values gives us the freedom to
    # do something different someday if we ever need to.  There's no
    # need to fill these values in unless we're in embedded mode.
    # Indeed, if we're building in embedded mode, we want NETLOC_LIBS
    # to be empty so that nothing is linked into libnetloc_embedded.la
    # itself -- only the upper-layer will link in anything required.

    AS_IF([test "$hwloc_mode" = "embedded"],
          [NETLOC_EMBEDDED_CFLAGS=$NETLOC_CFLAGS
           NETLOC_EMBEDDED_CPPFLAGS=$NETLOC_CPPFLAGS
           NETLOC_EMBEDDED_LDADD='$(HWLOC_top_builddir)/netloc/libnetloc_embedded.la'
           NETLOC_EMBEDDED_LIBS=$NETLOC_LIBS
           NETLOC_LIBS=])
    AC_SUBST(NETLOC_EMBEDDED_CFLAGS)
    AC_SUBST(NETLOC_EMBEDDED_CPPFLAGS)
    AC_SUBST(NETLOC_EMBEDDED_LDADD)
    AC_SUBST(NETLOC_EMBEDDED_LIBS)

    AC_CONFIG_FILES(
        netloc_config_prefix[netloc/Makefile]
    )

    AS_IF([test "$netloc_happy" = "yes"],
          [$2],
          [$3])
])dnl

AC_DEFUN([NETLOC_CHECK_PLATFORM], [
    AC_CHECK_DECLS([_DIRENT_HAVE_D_TYPE],,[:],[[#include <dirent.h>]])
    AC_MSG_CHECKING([if netloc supports this platform])
    AS_IF([test "$ac_cv_have_decl__DIRENT_HAVE_D_TYPE" != "yes"],
          [$1=no netloc_missing_reason=" (dirent->d_type missing)"])
    AS_IF([test "$hwloc_windows" = "yes"],
          [$1=no netloc_missing_reason=" (Windows platform)"])
    AC_MSG_RESULT([$$1$netloc_missing_reason])
])dnl

#
# Setup Jansson
#
# For the moment, we can only build with the internal Jansson.  It may
# be useful to also add the ability to build with an external Jansson,
# too.
#
AC_DEFUN([NETLOC_SETUP_JANSSON],[
    JANSSON_CONFIG

    # Set a few flags that are used in various Makefile.am's to
    # compile/link against Jansson.
    JANSSON_CPPFLAGS='-I$(HWLOC_top_srcdir)/netloc/jansson/src -I$(HWLOC_top_builddir)/netloc/jansson/src'
    AC_SUBST(JANSSON_CPPFLAGS)
    # For the embedded Jansson, we don't need any LDFLAGS
    JANSSON_LDFLAGS=
    AC_SUBST(JANSSON_LDFLAGS)
    JANSSON_LIBS='$(HWLOC_top_builddir)/netloc/jansson/src/libjansson.la'
    AC_SUBST(JANSSON_LIBS)

    $1=yes
])dnl

AC_DEFUN([NETLOC_DO_AM_CONDITIONALS], [
    AM_CONDITIONAL([BUILD_NETLOC], [test "$netloc_happy" = "yes"])

    JANSSON_DO_AM_CONDITIONALS
])dnl
