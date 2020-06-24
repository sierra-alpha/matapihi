#!/usr/bin/env python3
import argparse
import getpass
import os
import subprocess
import toml


def check_args(build_vars):
    if '' in build_vars["build-args"].values():
        for key in build_vars["build-args"].keys():
            if build_vars["build-args"][key] == '':
               build_vars["build-args"][key] = prompt_for_value(key, build_vars)

    for key,value in build_vars["secrets"].items():
        if not os.path.exists(value) or os.path.getsize(value) < 6:
            prompt_for_value(key, build_vars)


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


def build_build_args(build_vars):
    return [item for sublist in [["--build-arg", key+"="+value]
                                 for key,value
                                 in build_vars["build-args"].items()]
            for item in sublist]


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
        default=False,
        help=("If set this will leave the password files "
              "in the directory when finished")
    )

    args = parser.parse_args(raw_args)

    leave_dirty = args.leave_dirty

    build_vars = toml.load("build-vars.toml")

    # If there is no values in a field then prompt for them
    check_args(build_vars)

    import pdb; pdb.set_trace()

    mod_env = os.environ.copy()
    mod_env["DOCKER_BUILDKIT"] = "1"

    subprocess.run(["docker", "build"]
                   + build_build_args(build_vars)
                   + build_secret_args(build_vars)
                   + ["."],
                   env=mod_env )

    if not leave_dirty:
        for value in build_vars["secrets"].values():
            os.remove(value)


if __name__ == "__main__":
    main()
