# Base image
FROM nvidia/cudagl:10.2-devel-ubuntu16.04

# Setup basic packages
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    git \
    curl \
    vim \
    ca-certificates \
    libjpeg-dev \
    libpng-dev \
    libglfw3-dev \
    libglm-dev \
    libx11-dev \
    libomp-dev \
    libegl1-mesa-dev \
    pkg-config \
    wget \
    zip \
    mesa-utils \
    unzip &&\
    rm -rf /var/lib/apt/lists/*
ENV GIT_SSL_NO_VERIFY=1

# Install conda
RUN curl -L -o ~/miniconda.sh -O  https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh  &&\
    chmod +x ~/miniconda.sh &&\
    ~/miniconda.sh -b -p /opt/conda &&\
    rm ~/miniconda.sh &&\
    /opt/conda/bin/conda install numpy pyyaml scipy ipython mkl mkl-include &&\
    /opt/conda/bin/conda clean -ya
ENV PATH /opt/conda/bin:$PATH

# Install cmake
RUN wget https://github.com/Kitware/CMake/releases/download/v3.14.0/cmake-3.14.0-Linux-x86_64.sh
RUN mkdir /opt/cmake
RUN sh /cmake-3.14.0-Linux-x86_64.sh --prefix=/opt/cmake --skip-license
RUN ln -s /opt/cmake/bin/cmake /usr/local/bin/cmake
RUN cmake --version

# Conda environment
RUN conda create -n habitat python=3.9 cmake=3.14.0 cudatoolkit=10.2
RUN /bin/bash -c ". activate habitat; pip install IPython"
# Setup habitat-sim
# RUN git clone --branch v0.3.0 https://github.com/facebookresearch/habitat-sim.git
# RUN /bin/bash -c ". activate habitat; cd habitat-sim; pip install -r requirements.txt; python setup.py install --bullet"

# Install challenge specific habitat-lab
#RUN git clone --branch v0.3.0 https://github.com/facebookresearch/habitat-lab.git
#RUN /bin/bash -c ". activate habitat; cd habitat-lab; pip install -e habitat-lab/"
RUN conda install -y pytorch torchvision torchaudio pytorch-cuda=12.1 -c pytorch -c nvidia
#RUN /bin/bash -c ". activate habitat; cd habitat-lab; pip install -e habitat-baselines/"
# RUN curl -s https://packagecloud.io/install/repositories/github/git-lfs/script.deb.sh | bash
# RUN apt-get update && apt-get install -y git-lfs && apt-get clean all
RUN apt-get update && apt-get install -y lsb-release && apt-get clean all

RUN conda create -n robostackenv python=3.9 -c conda-forge
RUN /bin/bash -c ". activate robostackenv; conda config --env --add channels conda-forge; conda config --env --add channels robostack-experimental; conda config --env --add channels robostack; conda config --env --set channel_priority strict"
RUN /bin/bash -c ". activate robostackenv; conda install -y ros-noetic-desktop"
RUN /bin/bash -c ". activate robostackenv; conda install -y ros-noetic-map-server"
RUN /bin/bash -c ". activate robostackenv; conda install -y ros-noetic-move-base"
RUN /bin/bash -c ". activate robostackenv; conda install -y ros-noetic-amcl"


# RUN sh -c 'echo "deb http://packages.ros.org/ros/ubuntu $(lsb_release -sc) main" > /etc/apt/sources.list.d/ros-latest.list'
# RUN curl -s https://raw.githubusercontent.com/ros/rosdistro/master/ros.asc | apt-key add -


# RUN apt-get update && apt-get install -y \
#     python-tk \
#     ros-kinetic-desktop-full \
#     ros-kinetic-move-base \
#     ros-kinetic-tf2-sensor-msgs \
#     python-rosdep \
#     python-rosinstall \
#     python-rosinstall-generator \
#     build-essential

RUN /bin/bash -c ". activate habitat; pip install pygame==2.0.1; pip install pybullet==3.0.4"
WORKDIR /home
RUN mkdir catkin_ws && cd catkin_ws && mkdir src && cd src
# RUN rosdep init && rosdep update 
WORKDIR /home/catkin_ws
# RUN pip install rospkg
# RUN catkin_make
# RUN echo "source /home/catkin_ws/devel/setup.bash" >> ~/.bashrc
# RUN echo "source /opt/ros/kinetic/setup.bash" >> ~/.bashrc
ENV ROS_MASTER_URI=http://172.17.0.1:11311
ENV ROS_IP=172.17.0.1

RUN git config --global user.email "tribhi@umich.edu"
RUN git config --global user.name "tribhi"
# Silence habitat-sim logs
ENV GLOG_minloglevel=2
ENV MAGNUM_LOG="quiet"
