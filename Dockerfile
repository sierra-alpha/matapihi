# syntax = docker/dockerfile:1.0-experimental
FROM debian:latest

MAINTAINER Shaun Alexander <shaun@sierra-alpha.co.nz>

RUN apt-get update \
    && apt-get install -y \
    x11vnc \
    libxrandr2 \
    xvfb \ 
    git \
    python \
    emacs \
    wget \
    stow \
    xclip

RUN mkdir ~/.vnc

RUN --mount=type=secret,id=vnc_password \
    export TMP=$(cat /run/secrets/vnc_password) \
    && x11vnc -storepasswd $TMP ~/.vnc/passwd \
    && unset TMP

RUN mkdir /usr/share/fonts/opentype \
    && cd /usr/share/fonts/opentype \
    && wget \
    https://github.com/adobe-fonts/source-code-pro/releases/download/variable-fonts/SourceCodeVariable-Roman.otf \
    && cd ~ \
    && fc-cache -f -v

RUN --mount=type=secret,id=root_password \
    printf "root:"$(cat /run/secrets/root_password) | chpasswd

# Use Command Line Args for name
RUN export USER=shaun \
    && useradd -U --uid 1000 --shell /bin/bash --create-home $USER \
    && unset USER

WORKDIR /home/shaun

# Use Commandline Args for name
USER shaun

RUN git clone https://github.com/syl20bnr/spacemacs ~/.emacs.d \
    && cd ~/.emacs.d \
    && git checkout develop \
    && cd ~

# Use Commandline Args for dotfiles repo
RUN git clone https://github.com/Sierra-Alpha/dotfiles.git ~/dotfiles \
    && cd ~/dotfiles \
    && stow -t ~ *

# Use Command line args for key email
RUN printf "\n\n\n" | ssh-keygen -t rsa -b 4096 -C shaun@sierraalpha.com \
    && eval "$(ssh-agent -s)" \
    && ssh-add ~/.ssh/id_rsa

CMD ["/bin/bash", "emacs"]
