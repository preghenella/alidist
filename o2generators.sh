package: O2generators
version: "%(tag_basename)s"
tag: master
source: https://github.com/preghenella/O2generators.git
requires:
  - O2
  - pythia
  - HepMC3
build_requires:
  - CMake
  - "GCC-Toolchain:(?!osx)"
---
#!/bin/sh
cmake ${SOURCEDIR}                           \
      -DCMAKE_INSTALL_PREFIX=${INSTALLROOT}

make ${JOBS+-j$JOBS}
make install

# Modulefile
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
module load BASE/1.0                                                         \\
            ${O2_REVISION:+O2/$O2_VERSION-$O2_REVISION}                      \\
            ${PYTHIA_REVISION:+pythia/$PYTHIA_VERSION-$PYTHIA_REVISION}      \\
            ${HEPMC3_REVISION:+HepMC3/$HEPMC3_VERSION-$HEPMC3_REVISION}

# O2generators environment:
set O2GENERATORS_ROOT \$::env(BASEDIR)/$PKGNAME/\$version
setenv O2GENERATORS_ROOT \$O2GENERATORS_ROOT
prepend-path LD_LIBRARY_PATH \$O2GENERATORS_ROOT/lib
prepend-path LD_LIBRARY_PATH \$O2GENERATORS_ROOT/lib64

# prepend-path PATH \$DATADISTRIBUTION_ROOT/bin

# Not used for now:
# prepend-path LD_LIBRARY_PATH \$DATADISTRIBUTION_ROOT/lib
# prepend-path LD_LIBRARY_PATH \$DATADISTRIBUTION_ROOT/lib64
# prepend-path ROOT_INCLUDE_PATH \$DATADISTRIBUTION_ROOT/include

EoF
mkdir -p $INSTALLROOT/etc/modulefiles && rsync -a --delete etc/modulefiles/ $INSTALLROOT/etc/modulefiles
