# syntax = docker/dockerfile:1.0-experimental
FROM debian:latest

MAINTAINER Shaun Alexander <shaun@sierra-alpha.co.nz>

ENV LANG en_US.UTF-8
RUN echo $LANG UTF-8 > /etc/locale.gen \
    && apt-get update \
    && apt-get install -y locales \
    && update-locale --reset LANG=$LANG

RUN apt-get update \
    && apt-get install -y --no-install-recomends \
    xorg \
    lxqt-core \
    tigervnc-standalone-server

RUN apt-get update \
    apt-get install \
    git \
    python \
    emacs

RUN --mount=type=secret,id=vnc_password \
    export TMP=$(cat /run/secrets/vnc_password) \
    && printf $TMP"\n"$TMP"\n\n" | vncpasswd \
    && unset TMP

RUN git clone https://github.com/syl20bnr/spacemacs ~/.emacs.d

CMD bash