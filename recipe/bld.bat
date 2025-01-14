mkdir build
cd build

cmake ^
    -DBUILD_TESTS=no ^
    -DCMAKE_BUILD_TYPE=Release ^
    -DCMAKE_PREFIX_PATH=%LIBRARY_PREFIX% ^
    -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
    -DBUILD_TESTS=OFF ^
    ..

cmake --build . --target install --config Release
