# FROM nvidia/cuda:12.4.1-cudnn-devel-ubuntu22.04
FROM nvcr.io/nvidia/tensorrt:23.12-py3


# Thiết lập biến để tránh tương tác trong quá trình cài đặt
ARG DEBIAN_FRONTEND=noninteractive

# Thiết lập biến môi trường
ENV TZ=Asia/Shanghai \
    PATH="${PATH}:/usr/local/tensorrt/bin" \
    LD_LIBRARY_PATH="${LD_LIBRARY_PATH}:/usr/local/tensorrt/lib"

# Thiết lập thư mục làm việc và khai báo volume
WORKDIR /workspace
VOLUME /workspace

# Cài đặt các thư viện và công cụ cần thiết
RUN apt-get update && apt-get install -y --no-install-recommends \
    software-properties-common \
    && add-apt-repository ppa:ubuntu-toolchain-r/test \
    && apt-get update && apt-get install -y --no-install-recommends \
    libcurl4-openssl-dev \
    wget \
    zlib1g-dev \
    git \
    pkg-config \
    sudo \
    ssh \
    libssl-dev \
    pbzip2 \
    pv \
    bzip2 \
    unzip \
    devscripts \
    lintian \
    fakeroot \
    dh-make \
    build-essential \
    python3 \
    python3-pip \
    python3-dev \
    python3-wheel \
    && rm -rf /var/lib/apt/lists/*

# Thiết lập symbolic link cho Python
RUN ln -sf /usr/bin/python3 /usr/local/bin/python && \
    ln -sf /usr/bin/pip3 /usr/local/bin/pip

# Cài đặt các gói Python
COPY requirements.txt /tmp/requirements.txt
RUN pip3 install --upgrade pip \
    && pip3 install setuptools>=41.0.0 "pybind11[global]" -r /tmp/requirements.txt \
    && rm /tmp/requirements.txt

# Cài đặt CMake phiên bản 3.30.5
RUN wget -O /tmp/cmake.sh https://www.ghproxy.cn/https://github.com/Kitware/CMake/releases/download/v3.30.5/cmake-3.30.5-linux-x86_64.sh && \
    chmod +x /tmp/cmake.sh && \
    /tmp/cmake.sh --prefix=/usr/local --exclude-subdir --skip-license && \
    rm /tmp/cmake.sh

# Cài đặt các thư viện phụ thuộc cho OpenCV
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential cmake git pkg-config libgtk-3-dev \
    libavcodec-dev libavformat-dev libswscale-dev libv4l-dev \
    libxvidcore-dev libx264-dev libjpeg-dev libpng-dev libtiff-dev \
    gfortran openexr libatlas-base-dev python3-dev python3-numpy \
    libtbb2 libtbb-dev libdc1394-dev nano \
    && rm -rf /var/lib/apt/lists/*

 
# # Install TensorRT
# RUN axel --insecure -o /tmp/tensorrt.tar.gz https://developer.nvidia.com/downloads/compute/machine-learning/tensorrt/10.4.0/tars/TensorRT-10.4.0.26.Linux.x86_64-gnu.cuda-12.6.tar.gz \
#     && tar -xvf /tmp/tensorrt.tar.gz -C /usr/local --transform 's/^TensorRT-10.4.0.26/tensorrt/' \
#     && rm -f /tmp/tensorrt.tar.gz


# Build và cài đặt OpenCV từ source
RUN mkdir /workspace/opencv_build && \
    cd /workspace/opencv_build && \
    git clone https://github.com/opencv/opencv.git && \
    git clone https://github.com/opencv/opencv_contrib.git && \
    cd opencv && mkdir build && cd build && \
    cmake -D CMAKE_BUILD_TYPE=RELEASE \
        -D CMAKE_INSTALL_PREFIX=/usr/local \
        -D INSTALL_C_EXAMPLES=ON \
        -D INSTALL_PYTHON_EXAMPLES=ON \
        -D OPENCV_GENERATE_PKGCONFIG=ON \
        -D OPENCV_EXTRA_MODULES_PATH=/workspace/opencv_build/opencv_contrib/modules \
        -D BUILD_EXAMPLES=ON .. && \
    make -j$(nproc) && \
    make install && \
    rm -rf /workspace/opencv_build

# Sao chép và thiết lập script install.sh
COPY install.sh /usr/local/bin/install.sh
RUN chmod +x /usr/local/bin/install.sh

# Thiết lập lệnh mặc định khi container khởi chạy
# RUN /usr/local/bin/install.sh




