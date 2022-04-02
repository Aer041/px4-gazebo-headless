FROM ubuntu:18.04

ENV WORKSPACE_DIR /root
ENV FIRMWARE_DIR ${WORKSPACE_DIR}/Firmware
ENV SITL_RTSP_PROXY ${WORKSPACE_DIR}/sitl_rtsp_proxy

ENV DEBIAN_FRONTEND=noninteractive
#ENV DISPLAY :99
#ENV LANG C.UTF-8

RUN apt-get update && \
    apt-get install -y bc \
                       cmake \
                       curl \
                       gazebo9 \
                       git \
                       gcc \
                       gcc-arm-none-eabi \
                       g++ \
                       gstreamer1.0-plugins-bad \
                       gstreamer1.0-plugins-base \
                       gstreamer1.0-plugins-good \
                       gstreamer1.0-plugins-ugly \
                       iproute2 \
                       libeigen3-dev \
                       libgazebo9-dev \
                       libgstreamer-plugins-base1.0-dev \
                       libgstrtspserver-1.0-dev \
                       libopencv-dev \
                       libroscpp-dev \
                       protobuf-compiler \
                       python-pip \
                       python-jinja2 \
                       python-empy \
                       python3-jsonschema \
                       python3-numpy \
                       python3-pip \
                       unzip \
                       xvfb && \
    apt-get -y autoremove && \
    apt-get clean autoclean && \
    rm -rf /var/lib/apt/lists/{apt,dpkg,cache,log} /tmp/* /var/tmp/*

RUN pip install numpy \
                toml \
                pyyaml

RUN pip3 install empy \
                 jinja2 \
                 packaging \
                 pyros-genmsg \
                 toml \
                 pyyaml

RUN git clone https://github.com/Aer041/PX4-Autopilot.git ${FIRMWARE_DIR}
RUN git -C ${FIRMWARE_DIR} checkout a41-hotfix_usb_disconnected
RUN git -C ${FIRMWARE_DIR} submodule update --init --recursive
RUN git fetch --all
RUN git checkout tags/v1.10.1-0.2.0

#COPY edit_rcS.bash ${WORKSPACE_DIR}
#COPY entrypoint.sh /root/entrypoint.sh
#RUN chmod +x /root/entrypoint.sh

RUN cd ${FIRMWARE_DIR} && make px4_fmu-v5_default
RUN mkdir /drone
RUN mkdir /drone/firmware
RUN cp /root/Firmware/build/px4_fmu-v5_default/px4_fmu-v5_default.px4 /root/Firmware

#RUN ["/bin/bash", "-c", " \
#    cd ${FIRMWARE_DIR} && \
#    DONT_RUN=1 make px4_sitl gazebo && \
#    DONT_RUN=1 make px4_sitl gazebo \
#"]

#COPY sitl_rtsp_proxy ${SITL_RTSP_PROXY}
#RUN cmake -B${SITL_RTSP_PROXY}/build -H${SITL_RTSP_PROXY}
#RUN cmake --build ${SITL_RTSP_PROXY}/build

#ENTRYPOINT ["/root/entrypoint.sh"]
