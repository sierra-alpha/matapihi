# syntax = docker/dockerfile:1.0-experimental

#     matapihi the window that looks into and Xserver through SSH tunels and VNC
#     Copyright (C) 2020 Shaun Alexander

#     This program is free software: you can redistribute it and/or modify
#     it under the terms of the GNU General Public License as published by
#     the Free Software Foundation, either version 3 of the License, or
#     (at your option) any later version.

#     This program is distributed in the hope that it will be useful,
#     but WITHOUT ANY WARRANTY; without even the implied warranty of
#     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#     GNU General Public License for more details.

#     You should have received a copy of the GNU General Public License
#     along with this program.  If not, see <https://www.gnu.org/licenses/>.

FROM debian:latest

LABEL maintainer="shaun@sierraalpha.co.nz"

# Check all of these are required
RUN apt-get update \
    && apt-get install -y \
    less \
    moreutils \
    openssh-server \
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

WORKDIR /home/"$D_USER"

COPY Xvnc-session /home/"$D_USER"/.vnc/Xvnc-session
COPY .Xresources /home/"$D_USER"/.Xresources
COPY .matapihi /home/"$D_USER"/.matapihi
COPY startup /usr/local/bin/

RUN chown -R "$D_USER":"$D_USER" \
    /home/"$D_USER"/.vnc/Xvnc-session \
    /home/"$D_USER"/.Xresources \
    /home/"$D_USER"/.matapihi \
    /home/"$D_USER"/.matapihi/* \
    /usr/local/bin/startup

ENV D_USER="$D_USER"
RUN printf "$D_USER:initial" | chpasswd \
    && passwd -e "$D_USER"
CMD ["startup"]
