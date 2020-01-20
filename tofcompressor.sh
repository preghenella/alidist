package: TOFCompressor
version: "%(tag_basename)s"
tag: rdev
requires:
  - boost
  - O2
build_requires:
  - CMake
  - "Xcode:(osx.*)"
source: https://github.com/preghenella/TOFdecomp.git
prepend_path:
  LD_LIBRARY_PATH: "$O2_ROOT/lib"
  DYLD_LIBRARY_PATH: "$O2_ROOT/lib"
  ROOT_INCLUDE_PATH: "$O2_ROOT/include"
---
#!/bin/bash -e
cmake $SOURCEDIR -DCMAKE_INSTALL_PREFIX=$INSTALLROOT       \
                 ${CMAKE_GENERATOR:+-G "$CMAKE_GENERATOR"} \
                 -DCMAKE_BUILD_TYPE=$CMAKE_BUILD_TYPE      \
                 -DCMAKE_SKIP_RPATH=TRUE
cmake --build . -- ${JOBS:+-j$JOBS} install

# Modulefile
MODULEDIR="$INSTALLROOT/etc/modulefiles"
MODULEFILE="$MODULEDIR/$PKGNAME"
mkdir -p "$MODULEDIR"
cat > "$MODULEFILE" <<EoF
#%Module1.0
proc ModulesHelp { } {
  global version
  puts stderr "ALICE Modulefile for $PKGNAME $PKGVERSION-@@PKGREVISION@$PKGHASH@@"
}
set version $PKGVERSION-@@PKGREVISION@$PKGHASH@@
module-whatis "ALICE Modulefile for $PKGNAME $PKGVERSION-@@PKGREVISION@$PKGHASH@@"
# Dependencies
module load BASE/1.0 O2/$O2_VERSION-$O2_REVISION 
# Our environment
setenv TOFCOMPRESSOR_ROOT \$::env(BASEDIR)/$PKGNAME/\$version
prepend-path PATH \$::env(TOFCOMPRESSOR_ROOT)/bin
prepend-path LD_LIBRARY_PATH \$::env(TOFCOMPRESSOR_ROOT)/lib
$([[ ${ARCHITECTURE:0:3} == osx ]] && echo "prepend-path DYLD_LIBRARY_PATH \$::env(TOFCOMPRESSOR_ROOT)/lib")
EoF
