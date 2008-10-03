#!/bin/sh
. ../util/util.sh

LIBNAME=jpeg
VERSION=6.2

svnGetPS2DEV $LIBNAME

cd $LIBNAME
make || { echo "Error building $LIBNAME"; exit 1; }

mkdir -p ../target/psp/include ../target/psp/lib ../target/doc
cp jconfig.h jpeglib.h jmorecfg.h jerror.h ../target/psp/include
cp libjpeg.a  ../target/psp/lib
cp libjpeg.doc  ../target/doc
cd ..

makeInstaller $LIBNAME $VERSION

echo "Run the NSIS script now!"
