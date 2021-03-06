FROM ros:kinetic

# Arguments
ARG user
ARG uid
ARG home
ARG workspace
ARG shell

RUN apt-get -y update

RUN apt-get install -y \
      # Basic Utilities
      zsh screen tree sudo ssh synaptic nano inetutils-ping git \
      # Latest X11 / mesa GL
      xserver-xorg-dev-lts-xenial\
      libegl1-mesa-dev-lts-xenial\
      libgl1-mesa-dev-lts-xenial\
      libgbm-dev-lts-xenial\
      mesa-common-dev-lts-xenial\
      libgles2-mesa-lts-xenial\
      libwayland-egl1-mesa-lts-xenial\
      # Dependencies required to build rviz
      qt4-dev-tools \
      libqt5core5a libqt5dbus5 libqt5gui5 libwayland-client0 \
      libwayland-server0 libxcb-icccm4 libxcb-image0 libxcb-keysyms1 \
      libxcb-render-util0 libxcb-util1 libxcb-xkb1 libxkbcommon-x11-0 \
      libxkbcommon0 \
      # The rest of ROS-desktop
      ros-kinetic-desktop-full \
      # Additional development tools
      x11-apps \
      python-pip \
      build-essential

RUN sudo pip install catkin_tools

# Make SSH available
EXPOSE 22

# Mount the user's home directory
VOLUME "${home}"

# Clone user into docker image and set up X11 sharing
RUN  \
  echo "${user}:x:${uid}:${uid}:${user},,,:${home}:${shell}" >> /etc/passwd && \
  echo "${user}:x:${uid}:" >> /etc/group && \
  echo "${user} ALL=(ALL) NOPASSWD: ALL" > "/etc/sudoers.d/${user}" && \
  chmod 0440 "/etc/sudoers.d/${user}"

# Switch to user
USER "${user}"
# This is required for sharing Xauthority
ENV QT_X11_NO_MITSHM=1
ENV CATKIN_TOPLEVEL_WS="${workspace}/devel"
# Switch to the workspace
WORKDIR ${workspace}
