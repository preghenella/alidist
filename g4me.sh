package: g4me
version: "%(tag_basename)s"
tag: master
requires:
  - ROOT
  - pythia
  - GEANT4
  - HepMC3
build_requires:
  - CMake
  - "GCC-Toolchain:(?!osx)"
source: https://github.com/preghenella/g4me.git
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
            ${GCC_TOOLCHAIN_REVISION:+GCC-Toolchain/$GCC_TOOLCHAIN_VERSION-$GCC_TOOLCHAIN_REVISION} \\
            ${PYTHIA_REVISION:+pythia/$PYTHIA_VERSION-$PYTHIA_REVISION}                             \\
            ${ROOT_REVISION:+ROOT/$ROOT_VERSION-$ROOT_REVISION}                                     \\
            ${ROOT_REVISION:+GEANT4/$GEANT4_VERSION-$GEANT4_REVISION}				    \\
            ${ROOT_REVISION:+HepMC3/$HEPMC3_VERSION-$HEPMC3_REVISION}

# g4me environment:
set G4ME_ROOT \$::env(BASEDIR)/$PKGNAME/\$version
setenv G4ME_ROOT \$G4ME_ROOT

prepend-path PATH \$G4ME_ROOT/bin
prepend-path LD_LIBRARY_PATH \$G4ME_ROOT/lib
prepend-path LD_LIBRARY_PATH \$G4ME_ROOT/lib64
prepend-path ROOT_INCLUDE_PATH \$G4ME_ROOT/include

EoF
mkdir -p $INSTALLROOT/etc/modulefiles && rsync -a --delete etc/modulefiles/ $INSTALLROOT/etc/modulefiles
