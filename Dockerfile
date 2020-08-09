# syntax = docker/dockerfile:1.0-experimental
FROM debian:latest

MAINTAINER Shaun Alexander <shaun@sierra-alpha.co.nz>

RUN apt-get update \
    && apt-get install -y \
    curl \
    emacs \
    git \
    python \
    stow \
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

RUN mkdir /usr/share/fonts/source \
    && cd /usr/share/fonts/source \
    && wget \
    https://github.com/adobe-fonts/source-code-pro/archive/2.030R-ro/1.050R-it.tar.gz \
    && tar -xzvf 1.050R-it.tar.gz \
    && rm 1.050R-it.tar.gz \
    && fc-cache -f -v \
    && cd ~

RUN --mount=type=secret,id=root_password \
    printf "root:"$(cat /run/secrets/root_password) | chpasswd

# Use Command Line Args for name
RUN export USER=shaun \
    && useradd -U --uid 1000 --shell /bin/bash --create-home $USER \
    && unset USER

WORKDIR /home/shaun

# Use Commandline Args for name
USER shaun

# Use Commandline Args for dotfiles repo, comment outs allow overwiriting system files
RUN git clone https://github.com/Sierra-Alpha/dotfiles.git ~/dotfiles \
    && cd ~/dotfiles \
    # && stow --adopt -t ~ * \
    && stow -t ~ * \
    # && git reset HEAD --hard

# Use Command line args for key email
RUN printf "\n\n\n" | ssh-keygen -t rsa -b 4096 -C shaun@sierraalpha.com \
    && eval "$(ssh-agent -s)" \
    && ssh-add ~/.ssh/id_rsa

# So pull at run time to get first config and then it's faster each time?

## Probably xserver settings
# DONE: start directly to emacs when xserver vnc starts
# Kinda Done, deafaulted to something nice. set up screnn resolutions for viewing
# pass through autorepeating keystrokes

## Dev GH options
# Done do git hub key copy in an easy way (maybe use www in emacs?)

# DONE: figure out the emacs .dotfile situation with stow

# Use User variable
ADD .xinitrc /home/shaun/

ADD startup /usr/local/bin/
CMD ["bash", "-c", "startup"]
