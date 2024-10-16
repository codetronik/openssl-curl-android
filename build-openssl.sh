#!/bin/bash

if [[ "$OSTYPE" == "darwin"* ]]; then
    export CORES=$((`sysctl -n hw.logicalcpu`+1))
else
    export CORES=$((`nproc`+1))
fi

export TOOLCHAIN=$NDK/toolchains/llvm/prebuilt/$HOST_TAG
export ANDROID_NDK_HOME=$NDK
PATH=$TOOLCHAIN/bin:$PATH

mkdir -p build/openssl
cd openssl

# arm64 release
export CFLAGS="-O3"
export TARGET_HOST=aarch64-linux-android
export ANDROID_ARCH=arm64-v8a
export AR=$TOOLCHAIN/bin/llvm-ar
export CC=$TOOLCHAIN/bin/$TARGET_HOST$MIN_SDK_VERSION-clang
export AS=$CC
export CXX=$TOOLCHAIN/bin/$TARGET_HOST$MIN_SDK_VERSION-clang++
export LD=$TOOLCHAIN/bin/ld
export RANLIB=$TOOLCHAIN/bin/llvm-ranlib
export STRIP=$TOOLCHAIN/bin/llvm-strip

./Configure android-arm64 no-shared \
 --prefix=$PWD/build/$ANDROID_ARCH --release

make -j$CORES
make install_sw
make clean
mkdir -p ../build/openssl/release/$ANDROID_ARCH
cp -R $PWD/build/$ANDROID_ARCH ../build/openssl/release/arm64-v8a

# arm64 debug
export CFLAGS="-O0"
./Configure android-arm64 no-shared \
 --prefix=$PWD/build/$ANDROID_ARCH --debug

make -j$CORES
make install_sw
make clean
mkdir -p ../build/openssl/debug/$ANDROID_ARCH
cp -R $PWD/build/$ANDROID_ARCH ../build/openssl/debug/arm64-v8a

# arm release
export CFLAGS="-O3"
export TARGET_HOST=arm-linux-androideabi
export ANDROID_ARCH=armeabi-v7a

./Configure android-arm no-shared --prefix=$PWD/build/$ANDROID_ARCH --release

make -j$CORES
make install_sw
make clean
mkdir -p ../build/openssl/release/$ANDROID_ARCH
cp -R $PWD/build/$ANDROID_ARCH ../build/openssl/release/armeabi-v7a

# arm debug
export CFLAGS="-O0"
./Configure android-arm no-asm no-shared --prefix=$PWD/build/$ANDROID_ARCH --debug

make -j$CORES
make install_sw
make clean
mkdir -p ../build/openssl/debug/$ANDROID_ARCH
cp -R $PWD/build/$ANDROID_ARCH ../build/openssl/debug/armeabi-v7a

cd ..
