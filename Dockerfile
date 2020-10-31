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

# This doesn't really matter because it gets called so rarely and it gets cached
# and we can update in our user supplied matapihi start script
FROM debian:latest

LABEL maintainer="shaun@sierraalpha.co.nz"

# Install less, moreutils (for ts to get nice timestamped logs), openssh-server
# so we can tunnel through, sudo so we can run things as root,
# tigervnc-standalone-server this contains the Xvnc and other vnc utilities,
# wget to download the user specified scripts, xterm to have a terminal when we
# log in 
RUN apt-get update \
    && apt-get install -y \
    less \
    moreutils \
    openssh-server \
    sudo \
    tigervnc-standalone-server \
    wget \
    xterm

# Set up a user (normally Docker runs as root)
ARG D_USER
RUN useradd -U --uid 1000 --shell /bin/bash --create-home "$D_USER"
RUN usermod -aG sudo "$D_USER"

# Set up vnc password
RUN --mount=type=secret,id=vnc_password \
    export TMP=$(cat /run/secrets/vnc_password) \
    && printf "$TMP\n$TMP\n\n" | sudo -u "$D_USER" vncpasswd \
    && unset TMP

# Set up user directory
WORKDIR /home/"$D_USER"

# copy in required files
COPY Xvnc-session /home/"$D_USER"/.vnc/Xvnc-session
COPY .Xresources /home/"$D_USER"/.Xresources
COPY .matapihi /home/"$D_USER"/.matapihi
COPY startup /usr/local/bin/

# Set correct permissions
RUN chown -R "$D_USER":"$D_USER" \
    /home/"$D_USER"/.vnc/Xvnc-session \
    /home/"$D_USER"/.Xresources \
    /home/"$D_USER"/.matapihi \
    /home/"$D_USER"/.matapihi/* \
    /usr/local/bin/startup

# Set an env variable to be able to use the Docker User in other scripts 
ENV D_USER="$D_USER"

# Set initial password and then expire it immediatly so user gets prompted for
# new password on first SSh login
RUN printf "$D_USER:initial" | chpasswd \
    && passwd -e "$D_USER"

# run the start up script where we launch the SSH server and the VNC server
CMD ["startup"]
