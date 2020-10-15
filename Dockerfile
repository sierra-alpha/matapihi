# syntax = docker/dockerfile:1.0-experimental
FROM debian:latest

MAINTAINER Shaun Alexander <shaun@sierraalpha.co.nz>

# Check all of these are required
RUN apt-get update \
    && apt-get install -y \
    less \
    moreutils \
    sudo \
    wget \
    tigervnc-standalone-server

ARG D_USER
RUN useradd -U --uid 1000 --shell /bin/bash --create-home "$D_USER"
RUN usermod -aG sudo "$D_USER"

RUN --mount=type=secret,id=user_password \
    printf $D_USER":"$(cat /run/secrets/user_password) | chpasswd

WORKDIR /home/"$D_USER"

RUN --mount=type=secret,id=vnc_password \
    export TMP=$(cat /run/secrets/vnc_password) \
    && printf "$TMP\n$TMP\n\n" | vncpasswd \
    && unset TMP

USER "$D_USER"

ADD .xinitrc /home/"$D_USER"/
ADD .matapihi_init /home/"$D_USER"/

ADD startup /usr/local/bin/
CMD ["startup"]

