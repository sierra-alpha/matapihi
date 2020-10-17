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

USER "$D_USER"

COPY --chown="$D_USER" Xvnc-session /home/"$D_USER"/.vnc/Xvnc-session
COPY --chown="$D_USER" .matapihi /home/"$D_USER"/.matapihi

COPY --chown="$D_USER" startup /usr/local/bin/
CMD ["startup"]

