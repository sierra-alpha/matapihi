#!/usr/bin/env python3

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

import argparse
import getpass
import os
import subprocess
import toml


# Check all args required are supplied, prompt for them otherwise also validate
# secret files contain passwords greater than 6 chars
def check_args(build_vars):
    if '' in build_vars["build-args"].values():
        for key in build_vars["build-args"].keys():
            if build_vars["build-args"][key] == '':
               build_vars["build-args"][key] = prompt_for_value(key, build_vars)

    for key,value in build_vars["secrets"].items():
        if not os.path.exists(value) or os.path.getsize(value) < 6:
            prompt_for_value(key, build_vars)


# prompt for values as requried
def prompt_for_value(key, build_vars):
    secret = input("Please enter a value for the {}: "
                 .format(build_vars["language"]["english"][key]))

    if key in build_vars["secrets"].keys():
        while len(secret) < 6:
            secret = input("Secrets must be greater than 6 chars,"
                           "please renter: ")
        with open(build_vars["secrets"][key], "w") as fout:
            fout.write(secret)
        secret = None

    return secret


# If general tags, such as version are here then set them in the correct format
def build_general_flags(build_vars):
    return [item for sublist in
             [[tag, value if isinstance(values, list) else values]
              for tag, values in build_vars.get("general-flags", {}).items()
              for value in values]
             for item in sublist]


# For build args set them in the correct format
def build_build_args(build_vars):
    return [item for sublist in [["--build-arg", key+"="+value]
                                 for key,value
                                 in build_vars["build-args"].items()]
            for item in sublist]


# For secrets build the correct command
# rc=my_secret.txt --secret id=root_password,src=my_secret.txt .
def build_secret_args(build_vars):
    return [item for sublist in
            [["--secret", "id=" + key + ",src=" + value]
             for key,value
             in build_vars["secrets"].items()]
            for item in sublist]


def main(raw_args=None):

    parser = argparse.ArgumentParser(
        description=("Get the relevant info to execute a "
                     "Docker Build command that supports build secrets")
    )

    parser.add_argument(
        "-d",
        "--leave-dirty",
        action="store_true",
        default=False,
        help=("If set this will leave the password files "
              "in the directory when finished")
    )

    args = parser.parse_args(raw_args)

    leave_dirty = args.leave_dirty

    build_vars = toml.load("build-vars.toml")

    # If there is no values in a field then prompt for them
    check_args(build_vars)

    # grab calling environment and add experimental flag for secret building
    mod_env = os.environ.copy()
    mod_env["DOCKER_BUILDKIT"] = "1"

    # call the docker build command with the relevant args
    subprocess.run(["docker", "build"]
                   + build_general_flags(build_vars)
                   + build_build_args(build_vars)
                   + build_secret_args(build_vars)
                   + ["."],
                   env=mod_env )

    # remove the secret files if not requested to keep them 
    if not leave_dirty:
        for value in build_vars["secrets"].values():
            os.remove(value)


if __name__ == "__main__":
    main()
