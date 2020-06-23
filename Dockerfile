# syntax = docker/dockerfile:1.0-experimental
FROM debian:latest

MAINTAINER Shaun Alexander <shaun@sierra-alpha.co.nz>


RUN apt-get update \
    && apt-get install -y \
    x11vnc \
    xvfb \
    git \
    python \
    emacs \
    wget

RUN mkdir ~/.vnc

RUN --mount=type=secret,id=vnc_password \
    export TMP=$(cat /run/secrets/vnc_password) \
    && x11vnc -storepasswd $TMP ~/.vnc/passwd \
    && unset TMP

RUN mkdir /usr/share/fonts/opentype \
    && cd /usr/share/fonts/opentype \
    && wget \
    https://github.com/adobe-fonts/source-code-pro/releases/download/variable-fonts/SourceCodeVariable-Roman.otf \
    && fc-cache -f -v

RUN --mount=type=secret,id=root_password \
    printf "root:"$(cat /run/secrets/root_password) | chpasswd

RUN export USER=shaun \
    && useradd -U --uid 1000 --shell /bin/bash --create-home $USER \
    && unset USER

USER shaun

RUN chage -d 0 shaun

RUN git clone https://github.com/syl20bnr/spacemacs ~/.emacs.d

RUN echo emacs >> ~/.bashrc