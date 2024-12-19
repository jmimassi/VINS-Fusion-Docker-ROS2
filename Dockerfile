FROM osrf/ros:foxy-desktop

RUN apt-get update && apt-get install -y \
    python3-pip \
    python3-colcon-common-extensions \
    git \
    cmake \
    build-essential \
    nano \
    curl \
    wget \
    && rm -rf /var/lib/apt/lists/*

# Installation d'Eigen 3.3.7
RUN cd /tmp && \
    wget https://gitlab.com/libeigen/eigen/-/archive/3.3.7/eigen-3.3.7.tar.gz && \
    tar -xzvf eigen-3.3.7.tar.gz && \
    cd eigen-3.3.7 && \
    mkdir build && \
    cd build && \
    cmake .. -DCMAKE_INSTALL_PREFIX=/usr/local && \
    make install && \
    rm -rf /tmp/eigen-3.3.7*

# Installation de Ceres Solver 1.14.0
RUN apt-get update && apt-get install -y \
    libgoogle-glog-dev \
    libgflags-dev \
    libatlas-base-dev \
    libeigen3-dev \
    libsuitesparse-dev \
    && rm -rf /var/lib/apt/lists/*

RUN cd /tmp && \
    wget http://ceres-solver.org/ceres-solver-1.14.0.tar.gz && \
    tar -xzvf ceres-solver-1.14.0.tar.gz && \
    cd ceres-solver-1.14.0 && \
    mkdir build && \
    cd build && \
    cmake .. -DCMAKE_INSTALL_PREFIX=/usr/local && \
    make -j4 && \
    make install && \
    rm -rf /tmp/ceres-solver-1.14.0*

# Installation des dépendances pour OpenCV 4.2.0
RUN apt-get update && apt-get install -y \
    build-essential \
    cmake \
    git \
    libgtk2.0-dev \
    pkg-config \
    libavcodec-dev \
    libavformat-dev \
    libswscale-dev \
    python-dev \
    python-numpy \
    libtbb2 \
    libtbb-dev \
    libjpeg-dev \
    libpng-dev \
    libtiff-dev \
    libdc1394-22-dev \
    libv4l-dev \
    liblapacke-dev \
    libxvidcore-dev \
    libx264-dev \
    libatlas-base-dev \
    gfortran \
    ffmpeg \
    && rm -rf /var/lib/apt/lists/*

# # Installation d'OpenCV 4.2.0
# RUN cd /tmp && \
#     git clone https://github.com/opencv/opencv.git && \
#     cd opencv && \
#     git checkout 4.2.0 && \
#     mkdir build && \
#     cd build && \
#     cmake -D CMAKE_BUILD_TYPE=Release \
#     -D CMAKE_INSTALL_PREFIX=/usr/local .. && \
#     make -j$(nproc) && \
#     make install && \
#     rm -rf /tmp/opencv



# Télécharger et configurer OpenCV et opencv_contrib
RUN git clone https://github.com/opencv/opencv.git /tmp/opencv && \
    cd /tmp/opencv && git checkout 4.2.0 && \
    git clone https://github.com/opencv/opencv_contrib.git /tmp/opencv_contrib && \
    cd /tmp/opencv_contrib && git checkout 4.2.0

# Construire et installer OpenCV avec les modules contrib
RUN cd /tmp/opencv && mkdir build && cd build && \
    cmake -D CMAKE_BUILD_TYPE=Release \
    -D CMAKE_INSTALL_PREFIX=/usr/local \
    -D OPENCV_EXTRA_MODULES_PATH=/tmp/opencv_contrib/modules \
    -D BUILD_EXAMPLES=OFF .. && \
    make -j$(nproc) && make install && ldconfig

# Nettoyer les fichiers temporaires pour réduire la taille de l'image
# RUN rm -rf /tmp/opencv /tmp/opencv_contrib

# Configuration des chemins pour OpenCV
RUN echo "/usr/local/lib" >> /etc/ld.so.conf.d/opencv.conf && \
    ldconfig && \
    echo "export PKG_CONFIG_PATH=\$PKG_CONFIG_PATH:/usr/local/lib/pkgconfig" >> /root/.bashrc


RUN echo "source /opt/ros/foxy/setup.bash" >> /root/.bashrc

RUN pip install rosbags

# Séparation des couches pour une installation plus flexible
# RUN pip install torch
# RUN pip install torchvision
# RUN pip install numpy
# RUN pip install opencv-python==4.5.5.64
# RUN pip install matplotlib
# RUN pip install kornia==0.6.11

# Install Tkinter (python3-tk) and dependencies
RUN apt-get update && apt-get install -y \
    python3-tk tk-dev libtcl8.6 libtk8.6 \
    && rm -rf /var/lib/apt/lists/*

RUN pip install scipy

WORKDIR /workspaces/ROS2-DOCKER-VINS-MONO