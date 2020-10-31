# Readme
[![Built with Spacemacs](https://cdn.rawgit.com/syl20bnr/spacemacs/442d025779da2f62fc86c2082703697714db6514/assets/spacemacs-badge.svg)](http://spacemacs.org)

<!-- markdown-toc start - Don't edit this section. Run M-x markdown-toc-refresh-toc -->
**Table of Contents**

- [Readme](#readme)
    - [Description](#description)
    - [How to install](#how-to-install)
    - [How to Run](#how-to-run)
    - [Other usefull docker stuff](#other-usefull-docker-stuff)
    - [Details](#details)
    - [Matapihi Useage](#matapihi-useage)
    - [License](#license)
    - [Contrbutions](#contrbutions)

<!-- markdown-toc end -->

## Description

matapihi is a way of setting up a docker container that hosts an Xserver and VNC 
server and SSH server, it uses the SSH server to allow the client to tunnel to
the VNC port 5900, and then use a vnc client to view the Xdisplay. 

To help with setup there is a config file (`build-vars.toml`) and a python build script
`docker_compose_with_secrets.py` that will
read this config file and pass the relevant args through to the `docker build`
command, this is a way to build with secrets without them being available in the
image layers on docker hub. In the end I didn't really use this for kainga as I
set it up to prompt for new passwords on first connection anyway, but it may be
usefull if you want to build containers locally with private secrets and host
them on Docker Hub more securely.

## How to install

The image is hosted on docker hub so you can just skip straight to the [How to
Run](#how-to-run) section if you don't require any extra build args or secrets.

check the configuration in the `build-vars.toml` and then call
`python(3) docker_compose_with_secrets [options]`, `-d` is good for testing as
without it the secret files will get wiped on termination of the build script.

## How to Run

Use the following command to start a container:
   `docker run -p <port-on-host-to-tunnel-through>:22 [--mount
   type=bind,source=<folder/to/share>,target=<place/on/container>] --name
   <conainer-name> sierraalpha/matapihi:<tag>`
   
where:
 - `<port-on-host-to-tunnel-through>` is the port on the host that will fwd to
   the SSH port on the container, I normally use 22000
 - `[]` denotes an optional field to share a host directory with the container
   ()don't include the `[]`)
 - `<folder/to/share>` is the dirctory on the host you want the contaier to have
   access too
 - `<place/on/container>` is where you want the host folder to be _mounted_ on
   the container
 - `<container-name>` is a name you want to easily identify the container in
   docker 
 - `<tag>` the latest tag avalable from docker hub check
   [here](https://hub.docker.com/repository/docker/sierraalpha/matapihi) 
   
## Other usefull docker stuff
   `docker images` list all images
   `docker rmi (docker images -a -q)` remove all unused images

## Details

We build the image using the `docker_compose_with_secrets.py` script to allow
secrets to be passed in at image build time. This uses the `build-vars.toml`
file to pass in the relevant args and prompt for any not given.

default password is `initial`

The Container: 
 - sets up the Xvnc server (and VNC Password), and the SSH server, 
 - it sets up a user, 
 - copys in and gives the correct permissions to various X related config and
 init files, 
 - voids the default user password
 - then it launches the SHH server and waits for an SSH connection to connect
   and update the password
 - then it launches the Xserver on display :0 and the related VNC server
   connected to the same display
 - once a client connects through a VNC viewer it launches the matapihi init
   scripts
 - these scripts prompt the user for an URL that points to scripts the user
   wants to run on entry and exit of the Xsession
 - subsequent launches of matapihi will load these scripts automatically without
   needing to prompt the user
   
If the scripts are incorrect they can be modified manually by inspecting the
`~/.matapihi/matapihi_start` and/or `~/.matapihi/matapihi_exit` files or you can
call `matapihi -c` to clear the files followed by a `matapihi -i` to
reinitialise the script prompt, if the init prompt will only ask for URLs to
replace files that are missing. See [Matapihi Useage](#matapihi-useage) for more
options.

It's important that whatever the `matapihi_start` script does that it launches
something blocking in the foreground, if it doesn't matapihi will continue into
the exit script and the Xserver will close.

## Matapihi Useage

```shell
Usage: matapihi [option]

only one option is supported at a time

NOTE: It works best if supplied scripts for \`matapihi_start\`
and \`matapihi_exit\` are idempotent, that is they can be executed
multiple times with the same outcome.

Options:

   -c   clear
           Clears the previously loaded \`matapihi_start\` and
           \`matapihi_exit\` scripts

   -h   help
           Launches this help and exits

   -i   initialise
           If the scripts \`matapihi_start\` or \`matapihi_exit\`
           don't exist it prompts the user for an url to wget them

   -q   quit
           Run the user defined \`matapihi_exit\` script, this should
           shut down everything and kill the session

   -r   refresh/run
           If the scripts don't exist call init then;
           This will re-run the scripts in the order of \`matapihi_exit\`
           then \`matapihi -s\` and when start closes \`matapihi -q\`

   -s   start
           This will run the \`matapihi_start\` script
```
   
## License

GPL3, see license.md for full description.

## Contrbutions

Feel free to checkout my [sponsor
link](https://github.com/sponsors/sierra-alpha), raise issues or PR's as required.
