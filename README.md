# nvim-ide
Docker images with preconfigured nvim, plugins and lsp.<br>
You are advised to use cool-retro-term for better experience.

# What's inside
## Base image
* uses opensuse/tumbleweed
* nvim 0.6.1+ with vim-plug and plugins:
    * vim-airline
* git
* tmux with mouse mode enabled
* user dev with uid 1000 and gid 1000 (changable with `--build-arg`)
* fish shell with abbreviations (aliases):
    * git (gs, ga, gas, gc, gm, gk, ...)
    * find (ff, fff, fd, ffd)
    * edit configs (nvim: cfv, fish: cff, bashrc: cfb)
* workdir is /src with correct permissions (no need to chown)



## Python image
* uses base image
* python & pip from repos:
    * 3.8
    * 3.9
    * 3.10

# Using
### Clone this repo
```shell
git clone https://github.com/fuzzah/nvim-ide
cd nvim-ide
```
### Build images
It is implied that current user is in the docker group and can run docker commands without sudo.
```shell
./build_image.sh
```
If it's not the case, you should probably edit this script and put there correct uid, gid and desired user name.
