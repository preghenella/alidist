package: TOFCommissioning
version: "%(tag_basename)s"
tag: master
requires:
  - boost
  - FairLogger
  - FairMQ
  - O2
build_requires:
  - CMake
  - "GCC-Toolchain:(?!osx)"
source: https://github.com/alicetof/Commissioning
#prepend_path:
#  LD_LIBRARY_PATH: "$O2_ROOT/lib"
#  DYLD_LIBRARY_PATH: "$O2_ROOT/lib"
#  ROOT_INCLUDE_PATH: "$O2_ROOT/include"
---
#!/bin/bash -ex
cmake $SOURCEDIR -DCMAKE_INSTALL_PREFIX=$INSTALLROOT       \
                 ${CMAKE_GENERATOR:+-G "$CMAKE_GENERATOR"} \
                 -DCMAKE_BUILD_TYPE=$CMAKE_BUILD_TYPE      \
                 -DCMAKE_SKIP_RPATH=TRUE
cmake --build . -- ${JOBS:+-j$JOBS} install

#ModuleFile
mkdir -p etc/modulefiles
cat > etc/modulefiles/$PKGNAME <<EoF
#%Module1.0
proc ModulesHelp { } {
  global version
  puts stderr "ALICE Modulefile for $PKGNAME $PKGVERSION-@@PKGREVISION@$PKGHASH@@"
}
set version $PKGVERSION-@@PKGREVISION@$PKGHASH@@
module-whatis "ALICE Modulefile for $PKGNAME $PKGVERSION-@@PKGREVISION@$PKGHASH@@"
# Dependencies
module load BASE/1.0                                                                                \\
            ${BOOST_REVISION:+boost/$BOOST_VERSION-$BOOST_REVISION}                                 \\
            ${GCC_TOOLCHAIN_REVISION:+GCC-Toolchain/$GCC_TOOLCHAIN_VERSION-$GCC_TOOLCHAIN_REVISION} \\
            ${FAIRLOGGER_REVISION:+FairLogger/$FAIRLOGGER_VERSION-$FAIRLOGGER_REVISION}             \\
            ${FAIRMQ_REVISION:+FairMQ/$FAIRMQ_VERSION-$FAIRMQ_REVISION}                             \\
            ${O2_REVISION:+O2/$O2_VERSION-$O2_REVISION}                                             \\

# TOFCommissioning environment:
set TOFCOMMISSIONING_ROOT \$::env(BASEDIR)/$PKGNAME/\$version

prepend-path PATH \$TOFCOMMISSIONING_ROOT/bin
# prepend-path LD_LIBRARY_PATH \$TOFCOMMISSIONING_ROOT/lib
# prepend-path LD_LIBRARY_PATH \$TOFCOMMISSIONING_ROOT/lib64
# prepend-path ROOT_INCLUDE_PATH \$TOFCOMMISSIONING_ROOT/include

EoF
mkdir -p $INSTALLROOT/etc/modulefiles && rsync -a --delete etc/modulefiles/ $INSTALLROOT/etc/modulefiles
