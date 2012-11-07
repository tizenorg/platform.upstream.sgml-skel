AC_INIT(sgml-skel, [0.6], [keichwa@gmx.net])
AC_CONFIG_SRCDIR([install-dtd.sh])

AC_PREREQ(2.56)

AC_CANONICAL_HOST

AM_INIT_AUTOMAKE([check-news gnu 1.7.1 dist-bzip2 readme-alpha])

dnl part of libxml2
AC_CHECK_PROG([xmlcatalog], [xmlcatalog], yes)
if test ! x$xmlcatalog = "xyes"; then
  AC_MSG_ERROR(xmlcatalog is missing.)
fi
unset xmlcatalog

AC_CONFIG_FILES([Makefile install-dtd.sh parse-sgml-catalog.sh
                 sgml2xmlcat.sh sgml-register-catalog])
AC_OUTPUT

dnl configure.ac ends here
