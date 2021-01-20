FROM ovgudrivingswarm/turtlebot:latest

ARG DEBIAN_FRONTEND=noninteractive
ARG NODE_VERSION=12.x
ARG NOVNC_VERSION=1.1.0
ARG WEBSOCKIFY_VERSION=0.8.0

USER root

# Unminimize

RUN yes | unminimize &&\
    apt-get update &&\
    apt-get install -y --no-install-recommends man-db


# Dev-Packages

#RUN apt-get update &&\
#    apt-get install -y --no-install-recommends\


# VNC Server
# novnc + websockify

RUN apt-get install -y --no-install-recommends \
      x11vnc xvfb x11-xserver-utils \
	  novnc websockify

RUN ln -s /usr/share/novnc/vnc.html /usr/share/novnc/index.html &&\
    ln -s /usr/share/novnc/ /srv/novnc


# xfce-desktop
# TODO configs & background

RUN apt-get install -y --no-install-recommends \
      jwm thunar xfce4-terminal tumbler ristretto \
      pop-icon-theme

# utilities

RUN apt-get install -y --no-install-recommends \
      dbus-x11 gnome-keyring \
      wget psmisc \
      vim-tiny \
      evince file-roller \
      htop fd-find silversearcher-ag

# Theia IDE
RUN curl -sSL https://deb.nodesource.com/gpgkey/nodesource.gpg.key | sudo apt-key add - &&\
    DISTRO="$(lsb_release -s -c)" &&\
    echo "deb https://deb.nodesource.com/node_$NODE_VERSION $DISTRO main" | sudo tee /etc/apt/sources.list.d/nodesource.list &&\
    echo "deb-src https://deb.nodesource.com/node_$NODE_VERSION $DISTRO main" | sudo tee -a /etc/apt/sources.list.d/nodesource.list &&\
    apt-get update
RUN apt-get install nodejs && npm install -g yarn
COPY development/theia.package.json /opt/theia/package.json
RUN cd /opt/theia && yarn
RUN cd /opt/theia && yarn theia build
# Required for XML files, Python etc.
RUN apt-get install -y openjdk-14-jre pylint
# Required for Chrome
ENV THEIA_WEBVIEW_EXTERNAL_ENDPOINT={{hostname}}
VOLUME /home/docker/.theia

# Setup Script

COPY development/setup-desktop.sh /usr/local/bin/setup-desktop.sh
CMD ["/usr/local/bin/setup-desktop.sh"]


# Setup User

COPY development/wallpaper.jpg /usr/share/backgrounds/wallpaper.jpg
COPY development/jwmrc /home/docker/.jwmrc
COPY development/ssh/* /etc/ssh/ssh_config.d/

# TODO xfce4-configs
# COPY ...

RUN chown -R docker /home/docker/