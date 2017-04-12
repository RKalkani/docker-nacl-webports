FROM ubuntu:16.04

ARG SETUP_DIR="/home/setup"

## Install dependencies

RUN apt-get update -qq
RUN dpkg --add-architecture arm

RUN apt-get update -qq && \
    apt-get install -y -qq \
    unzip libc6-i386 git \
    build-essential lib32stdc++6 \
    cmake curl python libc6*

RUN mkdir -p $SETUP_DIR
RUN cd $SETUP_DIR

# Install depo-tools needed to install webports
RUN cd $SETUP_DIR && \
	git clone https://chromium.googlesource.com/chromium/tools/depot_tools.git

RUN cd $SETUP_DIR/depot_tools && \
	echo "export PATH=\"${SETUP_DIR}/depot_tools\":\"$PATH\"" >>  ~/.bashrc && \
	export PATH="${SETUP_DIR}/depot_tools":"$PATH"

ENV PATH="${SETUP_DIR}/depot_tools":"$PATH"

RUN export
# RUN cat ~/.bashrc

RUN gclient

#  Install NaCl SDK
RUN cd $SETUP_DIR && \
	curl -O https://storage.googleapis.com/nativeclient-mirror/nacl/nacl_sdk/nacl_sdk.zip && \
	unzip nacl_sdk.zip && \
	cd nacl_sdk/ && \
	./naclsdk list && \
	./naclsdk update pepper_49 && \
	rm ../nacl_sdk.zip

RUN	cd $SETUP_DIR/nacl_sdk && \
	echo "export NACL_SDK_ROOT=\"$SETUP_DIR/nacl_sdk/pepper_49/\"" >> ~/.bashrc && \
	export NACL_SDK_ROOT="$SETUP_DIR/nacl_sdk/pepper_49/"

ENV NACL_SDK_ROOT="$SETUP_DIR/nacl_sdk/pepper_49/"

RUN apt-get update -qq && \
    apt-get install -y -qq \
    python-pip 

# Install NaCl Port
RUN cd $SETUP_DIR && \
	mkdir naclports && \
	cd naclports && \
	gclient config --name=src https://chromium.googlesource.com/webports && \
	gclient sync

# Compile OpenCV port for NaCl
RUN apt-get update -qq && \
    apt-get install -y -qq \
    libglib2.0-0 libglib2.0-dev \
    gcc-arm-linux-gnueabihf libc6-dev-armhf-cross \
    qemu

RUN apt-get update -qq && \
    apt-get install -y -qq \
    texinfo gettext pkg-config \
    autoconf automake libtool libglib2.0-dev \
    xsltproc zlib1g-dev libssl-dev \
    lib32z1-dev libssl1.0.0 libstdc++6 \
    libglib2.0-0

RUN apt-get update -qq && \
    apt-get install -y -qq \
    libc6-dev-armhf-cross linux-libc-dev-armhf-cross \
    g++-arm-linux-gnueabihf

RUN cd $SETUP_DIR/naclports/src && \
	git config --global user.email "me@example.com" && \
	git config --global user.name "Me Example" && \
	sed -i 's/.*RunMinigzip[ ]*$/#&/' ports/zlib/build.sh && \
	NACL_ARCH=pnacl make opencv


ARG PROJECT_DIR="/home/project"
RUN mkdir -p $PROJECT_DIR
WORKDIR $PROJECT_DIR

