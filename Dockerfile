FROM ubuntu:20.04
CMD bash

# Install Ubuntu packages.
# Please add packages in alphabetical order.
ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get -y update 
RUN apt-get -y install sudo
COPY script/installation/packages.sh install-script.sh 
RUN echo y | ./install-script.sh all

COPY . /repo
RUN sed -i '1iset(CMAKE_C_COMPILER "/usr/bin/clang-8")' /repo/CMakeLists.txt
RUN sed -i '1iset(CMAKE_CXX_COMPILER "/usr/bin/clang++-8")' /repo/CMakeLists.txt
RUN cd /repo && \
 mkdir build && \
 cd build && \
 cmake -GNinja -DCMAKE_BUILD_TYPE=Release -DNOISEPAGE_USE_JEMALLOC=ON -DNOISEPAGE_UNITY_BUILD=ON .. && \
 ninja noisepage

RUN apt-get -y install openssh-server rsync
RUN useradd -rm -d /home/noise -s /bin/bash -g root -G sudo -u 1000 noise
RUN echo 'noise:noise' | chpasswd
RUN service ssh start
EXPOSE 22
RUN chmod -R a+rwx /repo
WORKDIR /repo
CMD ["/usr/sbin/sshd", "-D"]

