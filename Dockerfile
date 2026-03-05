ARG FROM_IMAGE=osrf/ros:jazzy-desktop-full
FROM ${FROM_IMAGE}

# Delete default user
RUN userdel ubuntu


COPY src ./src
RUN . /opt/ros/$ROS_DISTRO/setup.sh && \
    apt-get update && rosdep install -q -y \
    --from-paths src \
    --ignore-src \
    && rm -rf /var/lib/apt/lists/*
RUN rm -rf src

# install developer dependencies
RUN apt-get update && \
    apt-get install -y \
    bash-completion \
    gdb \
    clang-format \
    clangd \
    bear \
    python3-pip \
    wget \
    sudo && \
    pip3 install --break-system-packages \
    bottle \
    glances

# Create user matching host system user to avoid permission issues
ARG USER_ID=1000
ARG GROUP_ID=1000
ARG USERNAME=dev

RUN groupadd -g ${GROUP_ID} ${USERNAME} || true && \
    useradd -l -u ${USER_ID} -g ${GROUP_ID} -m -s /bin/bash ${USERNAME} && \
    echo "${USERNAME} ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Switch to the new user
USER ${USERNAME}
WORKDIR /home/${USERNAME}
