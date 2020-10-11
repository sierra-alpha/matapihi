# syntax = docker/dockerfile:1.0-experimental
FROM debian:latest

MAINTAINER Shaun Alexander <shaun@sierra-alpha.co.nz>

# Check all of these are required
RUN apt-get update \
    && apt-get install -y \
    less \
    sudo \
    wget \
    x11vnc \
    x11-xserver-utils \
    xinit \
    xvfb

RUN mkdir ~/.vnc

RUN --mount=type=secret,id=vnc_password \
    export TMP=$(cat /run/secrets/vnc_password) \
    && x11vnc -storepasswd $TMP ~/.vnc/passwd \
    && unset TMP

# RUN mkdir /usr/share/fonts/source \
#     && cd /usr/share/fonts/source \
#     && wget \
#     https://github.com/adobe-fonts/source-code-pro/archive/2.030R-ro/1.050R-it.tar.gz \
#     && tar -xzvf 1.050R-it.tar.gz \
#     && rm 1.050R-it.tar.gz \
#     && fc-cache -f -v \
#     && cd ~

# Use Command Line Args for name
ARG D_USER
RUN useradd -U --uid 1000 --shell /bin/bash --create-home "$D_USER"
RUN usermod -aG sudo "$D_USER"

RUN --mount=type=secret,id=user_password \
    printf $D_USER":"$(cat /run/secrets/user_password) | chpasswd

WORKDIR /home/"$D_USER"

# Use Commandline Args for name
USER "$D_USER"

# So pull at run time to get first config and then it's faster each time?

## Probably xserver settings
# DONE: start directly to emacs when xserver vnc starts
# Kinda Done, deafaulted to something nice. set up screnn resolutions for viewing
# pass through autorepeating keystrokes

## Dev GH options
# Done do git hub key copy in an easy way (maybe use www in emacs?)

# DONE: figure out the emacs .dotfile situation with stow

# Use User variable
ADD .xinitrc /home/"$D_USER"/
ADD .matapihi_run /home/"$D_USER"/


ADD startup /usr/local/bin/

CMD ["startup"]
