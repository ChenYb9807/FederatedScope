# The federatedscope image includes all runtime stuffs of federatedscope,
# with customized miniconda and required packages installed.

# based on the nvidia-docker
# NOTE: please pre-install the NVIDIA drivers and `nvidia-docker2` in the host machine,
# see details in https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/install-guide.html
FROM nvidia/cuda:11.3.1-runtime-ubuntu20.04

# change bash as default
SHELL ["/bin/bash", "-c"]

# shanghai zoneinfo
ENV TZ=Asia/Shanghai
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# install basic tools
RUN apt-get -y update \
    && apt-get -y install vim curl git gcc g++ make openssl libssl-dev libbz2-dev libreadline-dev libsqlite3-dev python-dev libmysqlclient-dev

# install miniconda,  in batch (silent) mode, does not edit PATH or .bashrc or .bash_profile
RUN apt-get update -y \
    && apt-get install -y wget
RUN wget https://repo.anaconda.com/miniconda/Miniconda3-py39_23.1.0-1-Linux-x86_64.sh \
    && bash Miniconda3-py39_23.1.0-1-Linux-x86_64.sh -b \
    && rm Miniconda3-py39_23.1.0-1-Linux-x86_64.sh

ENV PATH=/root/miniconda3/bin:${PATH}
RUN source activate

# install packages required by federatedscope
RUN conda update -y conda \
    && conda config --add channels conda-forge

# basic machine learning env
RUN conda install -y numpy=1.21.2 scikit-learn=1.0.2 scipy=1.7.3 pandas=1.4.1 -c scikit-learn \
    && conda clean -a -y

# basic torch env
RUN conda install -y pytorch=1.10.1 torchvision=0.11.2 torchaudio=0.10.1 cudatoolkit=11.3 -c pytorch -c conda-forge \
    && conda clean -a -y

# torch helper package
RUN conda install -y fvcore iopath -c fvcore -c iopath -c conda-forge \
    && conda clean -a -y

# auxiliaries (communications, monitoring, etc.)
RUN conda install -y wandb tensorboard tensorboardX pympler -c conda-forge \
    && pip install grpcio grpcio-tools protobuf==3.19.4 setuptools==61.2.0 \
    && conda clean -a -y
