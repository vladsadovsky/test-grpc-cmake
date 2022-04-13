#!/bin/bash 

# galacell Build script for Debian Linux

case "$1" in 
  "clean")
    echo Cleaning up all build artifacts, both release and debug
    rm -fr build/lnx
    ;;

  "info")
    echo ==== Build tools information ====
    echo == CMAKE 
    which cmake
    cmake --version

    echo == NINJA 
    which ninja
    ninja --version

    echo == OS
    uname -a
    ;;

  "prereq")
    echo Installing prerequisites
    sudo apt -y install ninja-build cmake build-essential clang libc++-dev pkg-config
    ;;

  "debug")
    echo Building debug in build/lnx/debug
    mkdir -p build/lnx/debug
    cmake -G "Ninja" -B build/lnx/debug -S . -DCMAKE_BUILD_TYPE=Debug  
    ninja -v -C build/lnx/debug package
    ls -la build/lnx/debug
    ;;

  "release")
    echo Building release in build/lnx/release
    cmake -G "Ninja" -B build/lnx/release -S . -DCMAKE_BUILD_TYPE=Release -DUSE_EXPRTK=ON
    ninja -v -C build/lnx/release package
    ;;  
  *)
    echo $"Usage: $0 {help|info|prereq|debug|release|clean}"
    exit 1
    ;;
esac

exit 0

