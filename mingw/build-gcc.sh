#!/bin/sh

if [ "$WITH_MINGW_GCC43" == "yes" ]; then
	GDB_EXTRA_FLAGS="--disable-werror"
fi

mkdir -p psp/binutils
cd psp/binutils

if [ ! -f configured-binutils ]
then
	../../$BINUTILS_SRCDIR/configure \
		--prefix=$INSTALLDIR --target=psp \
		--enable-install-libbfd \
		--with-gmp=/usr/local --with-mpfr=/usr/local \
			|| { echo "Error configuring binutils"; exit 1; }
	touch configured-binutils
fi

if [ ! -f built-binutils ]
then
	$MAKE || { echo "Error building binutils"; exit 1; }
	touch built-binutils
fi

if [ ! -f installed-binutils ]
then
	$MAKE install || { echo "Error installing binutils"; exit 1; }
	touch installed-binutils
fi

cd $BUILDSCRIPTDIR

#---------------------------------------------------------------------------------
# build and install just the c compiler
#---------------------------------------------------------------------------------
mkdir -p psp/gcc
cd psp/gcc

if [ ! -f configured-gcc ]
then
	CFLAGS="-D__USE_MINGW_ACCESS" \
	CXXFLAGS="-mthreads -D__USE_MINGW_ACCESS" \
	CFLAGS_FOR_TARGET="-G0" \
	../../$GCC_SRCDIR/configure \
		--enable-languages="c,c++" \
		--disable-win32-registry \
		--enable-threads=posix \
		--enable-cxx-flags="-G0" \
		--target=psp \
		--with-newlib \
		--prefix=$INSTALLDIR \
		--with-gmp=/usr/local --with-mpfr=/usr/local \
			|| { echo "Error configuring gcc"; exit 1; }
	touch configured-gcc
fi

if [ ! -f built-gcc ]
then
	$MAKE all-gcc || { echo "Error building gcc"; exit 1; }
	touch built-gcc
fi

if [ ! -f installed-gcc ]
then
	$MAKE install-gcc || { echo "Error installing gcc"; exit 1; }
	touch installed-gcc
fi

cd $BUILDSCRIPTDIR

if [ ! -d pspsdk ]
then
	svn checkout $PS2DEV_SVN/pspsdk || { echo "ERROR GETTING PSPSDK"; exit 1; }
else
	svn update pspsdk
fi

cd pspsdk
if [ ! -f bootstrap-sdk ]
then
	./bootstrap || { echo "ERROR RUNNING PSPSDK BOOTSTRAP"; exit 1; }
	touch bootstrap-sdk
fi

if [ ! -f configure-sdk ]
then
	./configure --with-pspdev="$INSTALLDIR" || { echo "ERROR RUNNING PSPSDK CONFIGURE"; exit 1; }
	touch configure-sdk
fi

if [ ! -f install-sdk-data ]
then
	$MAKE install-data || { echo "ERROR INSTALLING PSPSDK HEADERS"; exit 1; }
	touch install-sdk-data
fi

cd $BUILDSCRIPTDIR

#---------------------------------------------------------------------------------
# build and install newlib
#---------------------------------------------------------------------------------
mkdir -p psp/newlib
cd psp/newlib

if [ ! -f configured-newlib ]
then
	$BUILDSCRIPTDIR/$NEWLIB_SRCDIR/configure \
		--target=psp \
		--prefix=$INSTALLDIR \
		--with-gmp=/usr/local --with-mpfr=/usr/local \
			|| { echo "Error configuring newlib"; exit 1; }
	touch configured-newlib
fi

if [ ! -f built-newlib ]
then
	$MAKE || { echo "Error building newlib"; exit 1; }
	touch built-newlib
fi

if [ ! -f installed-newlib ]
then
	$MAKE install || { echo "Error installing newlib"; exit 1; }
	touch installed-newlib
fi

cd $BUILDSCRIPTDIR


#---------------------------------------------------------------------------------
# build and install the final compiler
#---------------------------------------------------------------------------------

cd psp/gcc

if [ ! -f built-g++ ]
then
	$MAKE || { echo "Error building g++"; exit 1; }
	touch built-g++
fi

if [ ! -f installed-g++ ]
then
	$MAKE install || { echo "Error installing g++"; exit 1; }
	touch installed-g++
fi

cd $BUILDSCRIPTDIR

#---------------------------------------------------------------------------------
# build and install the psp sdk
#---------------------------------------------------------------------------------
cd pspsdk

if [ ! -f built-sdk ]
then
	$MAKE || { echo "ERROR BUILDING PSPSDK"; exit 1; }
	touch built-sdk
fi

if [ ! -f installed-sdk ]
then
	$MAKE install || { echo "ERROR INSTALLING PSPSDK"; exit 1; }
	touch installed-sdk
fi

cd $BUILDSCRIPTDIR

#---------------------------------------------------------------------------------
# build and install the debugger
#---------------------------------------------------------------------------------
mkdir -p psp/gdb
cd psp/gdb

if [ ! -f configured-gdb ]
then
	../../$GDB_SRCDIR/configure \
		--prefix=$INSTALLDIR --target=psp \
		--with-gmp=/usr/local --with-mpfr=/usr/local \
		$GDB_EXTRA_FLAGS \
			|| { echo "Error configuring gdb"; exit 1; }
	touch configured-gdb
fi

if [ ! -f built-gdb ]
then
	$MAKE || { echo "Error building gdb"; exit 1; }
	touch built-gdb
fi

if [ ! -f installed-gdb ]
then
	$MAKE install || { echo "Error installing gdb"; exit 1; }
	touch installed-gdb
fi
