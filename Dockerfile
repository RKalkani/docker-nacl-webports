FROM ubuntu:16.04

ARG SETUP_DIR="/home/setup"

## Install dependencies

RUN sudo apt-get update -qq && \
    sudo apt-get install -y -qq \
    unzip libc6-i386 git \
    build-essential lib32stdc++6 \
    cmake curl

RUN mkdir -p $SETUP_DIR
RUN cd $SETUP_DIR

#  Install NaCl SDK
RUN curl -O https://storage.googleapis.com/nativeclient-mirror/nacl/nacl_sdk/nacl_sdk.zip && \
	unzip nacl_sdk.zip && \
	cd nacl_sdk/ && \
	./naclsdk list && \
	./naclsdk update pepper_49 && \
	rm ../nacl_sdk.zip

RUN	cd $SETUP_DIR/nacl_sdk && \
	echo 'export NACL_SDK_ROOT="`pwd`/pepper_49/"' >> ~/.bashrc

# Install depo-tools needed to install webports
RUN cd $SETUP_DIR && \
	git clone https://chromium.googlesource.com/chromium/tools/depot_tools.git

RUN cd $SETUP_DIR/depot_tools && \
	echo 'export PATH="`pwd`":"$PATH"' >>  ~/.bashrc

RUN gclient

# Install NaCl Port
RUN cd $SETUP_DIR
	mkdir naclports && \
	cd naclports && \
	gclient config --name=src https://chromium.googlesource.com/webports && \
	gclient sync

# Compile OpenCV port for NaCl

RUN cd $SETUP_DIR/naclports/src &&
	NACL_ARCH=pnacl make opencv



