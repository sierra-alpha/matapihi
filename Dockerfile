# syntax = docker/dockerfile:1.0-experimental
FROM debian:latest

LABEL maintainer="shaun@sierraalpha.co.nz"

# Check all of these are required
RUN apt-get update \
    && apt-get install -y \
    less \
    moreutils \
    sudo \
    tigervnc-standalone-server \
    wget \
    xterm

ARG D_USER
RUN useradd -U --uid 1000 --shell /bin/bash --create-home "$D_USER"
RUN usermod -aG sudo "$D_USER"

RUN --mount=type=secret,id=vnc_password \
    export TMP=$(cat /run/secrets/vnc_password) \
    && printf "$TMP\n$TMP\n\n" | sudo -u "$D_USER" vncpasswd \
    && unset TMP

RUN --mount=type=secret,id=user_password \
    printf $D_USER":"$(cat /run/secrets/user_password) | chpasswd

WORKDIR /home/"$D_USER"

COPY Xvnc-session /home/"$D_USER"/.vnc/Xvnc-session
COPY .Xresources /home/"$D_USER"/.Xresources
COPY .matapihi /home/"$D_USER"/.matapihi
COPY startup /usr/local/bin/

RUN chown -R "$D_USER":"$D_USER" \
    /home/"$D_USER"/.vnc/Xvnc-session \
    /home/"$D_USER"/.matapihi \
    /home/"$D_USER"/.matapihi/* \
    /usr/local/bin/startup

USER "$D_USER"
CMD ["startup"]

