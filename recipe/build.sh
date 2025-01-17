#!/usr/bin/env bash

if [[ "$CONDA_BUILD_CROSS_COMPILATION" == 1 ]]; then
  (
    mkdir -p native-build
    pushd native-build

    export CC=$CC_FOR_BUILD
    export AR=($CC_FOR_BUILD -print-prog-name=ar)
    export NM=($CC_FOR_BUILD -print-prog-name=nm)
    export LDFLAGS=${LDFLAGS//$PREFIX/$BUILD_PREFIX}
    export PKG_CONFIG_PATH=${BUILD_PREFIX}/lib/pkgconfig

    # Unset them as we're ok with builds that are either slow or non-portable
    unset CFLAGS
    unset CPPFLAGS

    cmake \
      -GNinja \
      -DCMAKE_INSTALL_PREFIX=$BUILD_PREFIX \
      -DCMAKE_PREFIX_PATH=$BUILD_PREFIX \
      -DCMAKE_INSTALL_LIBDIR=lib \
      -DBUILD_TESTS=OFF \
      ..
    ninja -j${CPU_COUNT}
  )
  CMAKE_ARGS="${CMAKE_ARGS} -DNATIVE_BUILD_DIR=$PWD/native-build"
fi

mkdir build
cd build

if [[ "$target_platform" == "osx-arm64" ]]; then
    # clang 11.0.0 segfaults. So same on Apple's clang 12.0.0 
    # so disable for now crashing code ...
    CMAKE_ARGS="${CMAE_ARGS} -DDISABLE_SVE:BOOL=ON"
fi

if [[ "$target_platform" == linux-* ]]; then
    LDFLAGS="-lrt ${LDFLAGS}"
fi

cmake ${CMAKE_ARGS} \
    -GNinja \
    -DCMAKE_INSTALL_PREFIX=$PREFIX \
    -DCMAKE_PREFIX_PATH=$PREFIX \
    -DCMAKE_INSTALL_LIBDIR=lib \
    -DBUILD_TESTS=OFF \
    ..

cmake --build . --target install
