AC_PREREQ([2.65])
AC_INIT([berp],[1.0],[chebizarro@gmail.com])
AC_CONFIG_MACRO_DIR([m4])
AM_INIT_AUTOMAKE

AC_CONFIG_FILES([Makefile
		src/Makefile
		src/Berp/Makefile])

LT_INIT
AC_PROG_CC
AM_PROG_VALAC

pkg_modules="glib-2.0 >= 2.24.1
             gobject-2.0 >= 2.24.1
             gio-2.0
             gee-0.8
             libdotnet-0.1"

PKG_CHECK_MODULES(BERP, [$pkg_modules])
AC_SUBST(BERP_CFLAGS)
AC_SUBST(BERP_LIBS)

AC_OUTPUT
