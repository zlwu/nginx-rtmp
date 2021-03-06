#!/bin/bash

set -euo pipefail

export MAKEFLAGS="-j$[$(nproc) + 1]"

apt-get -q -y update && \
DEBIAN_FRONTEND=noninteractive apt-get -q -y install autoconf automake libtool build-essential g++ nasm cmake perl libssl-dev git && \
apt-get -q -y clean && rm -rf /var/cache/apt/archives/* /var/lib/apt/lists/*

# yasm
DIR=$(mktemp -d) && cd ${DIR} && \
              curl -s http://www.tortall.net/projects/yasm/releases/yasm-${YASM_VERSION}.tar.gz | \
              tar zxvf - -C . && \
              cd ${DIR}/yasm-${YASM_VERSION} && \
              ./configure --docdir=${DIR} -mandir=${DIR}&& \
              make && \
              make install && \
              make distclean && \
              rm -rf ${DIR}

# x264  TODO : pin version, at least we use stable branch
DIR=$(mktemp -d) && cd ${DIR} && \
              git clone -b stable  --single-branch --depth 1 git://git.videolan.org/x264 && \
              cd x264 && \
              ./configure --enable-static && \
              make && \
              make install && \
              make distclean && \
              rm -rf ${DIR}

# x265
DIR=$(mktemp -d) && cd ${DIR} && \
              curl -s https://bitbucket.org/multicoreware/x265/get/${X265_VERSION}.tar.gz | tar zxvf - -C . && \
              cd multicoreware-*/source && \
              cmake -G "Unix Makefiles" . && \
              cmake . && \
              make && \
              make install && \
              rm -rf ${DIR}

# libogg
DIR=$(mktemp -d) && cd ${DIR} && \
              curl -s http://downloads.xiph.org/releases/ogg/libogg-${OGG_VERSION}.tar.gz | tar zxvf - -C . && \
              cd libogg-${OGG_VERSION} && \
              ./configure --disable-shared --docdir=/dev/null && \
              make && \
              make install && \
              make distclean && \
              rm -rf ${DIR}

# libopus
DIR=$(mktemp -d) && cd ${DIR} && \
              curl -s http://downloads.xiph.org/releases/opus/opus-${OPUS_VERSION}.tar.gz | tar zxvf - -C . && \
              cd opus-${OPUS_VERSION} && \
              autoreconf -fiv && \
              ./configure --disable-shared && \
              make && \
              make install && \
              make distclean && \
              rm -rf ${DIR}

# libvorbis
DIR=$(mktemp -d) && cd ${DIR} && \
              curl -s http://downloads.xiph.org/releases/vorbis/libvorbis-${VORBIS_VERSION}.tar.gz | tar zxvf - -C . && \
              cd libvorbis-${VORBIS_VERSION} && \
              ./configure --disable-shared --datadir=${DIR} && \
              make && \
              make install && \
              make distclean && \
              rm -rf ${DIR}

# libtheora
DIR=$(mktemp -d) && cd ${DIR} && \
              curl -s http://downloads.xiph.org/releases/theora/libtheora-${THEORA_VERSION}.tar.bz2 | tar jxvf - -C . && \
              cd libtheora-${THEORA_VERSION} && \
              ./configure --disable-shared --datadir=${DIR} && \
              make && \
              make install && \
              make distclean && \
              rm -rf ${DIR}

# libvpx
DIR=$(mktemp -d) && cd ${DIR} && \
              curl -s https://codeload.github.com/webmproject/libvpx/tar.gz/v${VPX_VERSION} | tar zxvf - -C . && \
              cd libvpx-${VPX_VERSION} && \
              ./configure --enable-vp8 --enable-vp9 --disable-examples && \
              make && \
              make install && \
              make clean && \
              rm -rf ${DIR}

# libmp3lame
DIR=$(mktemp -d) && cd ${DIR} && \
              curl -L -s http://downloads.sourceforge.net/project/lame/lame/${LAME_VERSION%.*}/lame-${LAME_VERSION}.tar.gz | tar zxvf - -C . && \
              cd lame-${LAME_VERSION} && \
              ./configure --disable-shared --enable-nasm && \
              make && \
              make install && \
              make distclean&& \
              rm -rf ${DIR}

# faac + http://stackoverflow.com/a/4320377
DIR=$(mktemp -d) &&  cd ${DIR} && \
              curl -L -s http://downloads.sourceforge.net/faac/faac-${FAAC_VERSION}.tar.gz | tar zxvf - -C . && \
              cd faac-${FAAC_VERSION} && \
              sed -i '126d' common/mp4v2/mpeg4ip.h && \
              ./bootstrap && \
              ./configure && \
              make && \
              make install &&\
              rm -rf ${DIR}

# xvid
DIR=$(mktemp -d) && cd ${DIR} && \
              curl -L -s  http://downloads.xvid.org/downloads/xvidcore-${XVID_VERSION}.tar.gz | tar zxvf - -C .&& \
              cd xvidcore/build/generic && \
              ./configure && \
              make && \
              make install&& \
              rm -rf ${DIR}

# fdk-aac
DIR=$(mktemp -d) && cd ${DIR} && \
              curl -s https://codeload.github.com/mstorsjo/fdk-aac/tar.gz/v${FDKAAC_VERSION} | tar zxvf - -C . && \
              cd fdk-aac-${FDKAAC_VERSION} && \
              autoreconf -fiv && \
              ./configure --disable-shared && \
              make && \
              make install && \
              make distclean && \
              rm -rf ${DIR}

# ffmpeg
DIR=$(mktemp -d) && cd ${DIR} && \
              curl -s http://ffmpeg.org/releases/ffmpeg-${FFMPEG_VERSION}.tar.gz | tar zxvf - -C . && \
              cd ffmpeg-${FFMPEG_VERSION} && \
              ./configure \
              --extra-libs=-ldl --enable-version3 --enable-libfaac --enable-libmp3lame \
              --enable-libx264 --enable-libxvid --enable-gpl \
              --enable-postproc --enable-nonfree --enable-avresample --enable-libfdk_aac \
              --disable-debug --enable-small --enable-openssl --enable-libtheora \
              --enable-libx265 --enable-libopus --enable-libvorbis --enable-libvpx && \
              make && \
              make install && \
              make distclean && \
              hash -r && \
              rm -rf ${DIR}

