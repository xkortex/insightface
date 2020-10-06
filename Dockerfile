## Ubuntu base for python CV/ML
ARG BASE_REGISTRY=nvidia/
ARG BASE_IMAGE=cuda
ARG BASE_TAG=10.1-cudnn8-runtime-ubuntu18.04
FROM ${BASE_REGISTRY}${BASE_IMAGE}:${BASE_TAG} as base

ARG BASE_IMAGE
ARG BASE_TAG
ENV BASE_IMAGE=$BASE_IMAGE
ENV BASE_TAG=$BASE_TAG

###  ===   ===   Configure Timezone Data ===  === ###
###  Install and configure tzdata so we don't get prompted for it later
###  This can happen if a later layer apt install requires tzdata and isn't set noninteractive
ARG ZONEINFO=America/New_York
RUN     export DEBIAN_FRONTEND=noninteractive \
    &&  echo 'Etc/UTC' > /etc/timezone \
    &&  ln -sf /usr/share/zoneinfo/${ZONEINFO} /etc/localtime \
    &&  apt-get update -q && apt-get install -q -y tzdata ca-certificates \
    &&  update-ca-certificates \
    &&  rm -rf /var/lib/apt/lists/* \
    &&  dpkg-reconfigure --frontend noninteractive tzdata
###  ===   ===   ===   ===   end tzdata configuration  ===   ===   ===   ===   === ###

## Bootstrap packages, these seem to always be needed
RUN     apt-get update -qq && apt-get install -qq \
            curl \
            apt-transport-https \
            ca-certificates \
            gpg-agent \
            git \
    && rm -rf /var/lib/apt/lists/*


## Python and pip
RUN     apt-get update -qq && apt-get install -y --no-install-recommends \
            python3-dev \
            python3-setuptools \
    && rm -rf /var/lib/apt/lists/*

RUN curl --silent --show-error \
    https://bootstrap.pypa.io/get-pip.py | python3

RUN     apt-get update -qq && apt-get install -y --no-install-recommends \
            libc++abi-dev \
            libopenblas-dev \
            liblapack-dev \
            libavcodec-dev \
            libavformat-dev \
            libgl1-mesa-dev \
            libswscale-dev \
            libtbb2 \
            libtbb-dev \
            libjpeg-dev \
            libpng-dev \
            libtiff-dev \
    && rm -rf /var/lib/apt/lists/*

## =================================================================
FROM base as deps

RUN     pip install --no-cache-dir \
            easydict \
            ipython \
            matplotlib \
            numpy \
            pandas \
            Pillow \
            pyyaml \
            requests \
            scipy \
            scikit-learn \
            six \
            scikit-image \
            tqdm

RUN     pip install --no-cache-dir 'opencv-python-headless<5.0'

RUN     pip install --no-cache-dir \
            mxnet-cu$(echo $CUDA_VERSION | grep -Po '\d\d?\.\d' | sed 's/\.//g')


WORKDIR /src/insightface

COPY . /src/insightface

RUN pip install --no-cache-dir /src/insightface/python-package