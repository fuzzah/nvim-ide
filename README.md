# nvim-ide
Docker images with preconfigured nvim, plugins and lsp.<br>
You are advised to use cool-retro-term for better experience.

# What's inside
## Base image
* uses opensuse/tumbleweed
* nvim 0.6.1+ with vim-plug and plugins:
    * vim-airline
    * nvim-lspconfig
    * nvim-treesitter
    * plenary.nvim
    * telescope.nvim
* git
* npm
* ripgrep & fd utils
* tmux with mouse mode enabled
* non-root user to not mess access rights of your source code (can use sudo)
* fish shell with abbreviations (aliases) defined in [base.fish](base.fish):
    * git (gs, ga, gas, gc, gm, gk, ...)
    * find (ff, fff, fd, ffd)
    * edit configs (nvim: cfv, fish: cff, bashrc: cfb)
* workdir is /src


## Python image
* uses base image
* python & pip from repos:
    * 3.8
    * 3.9
    * 3.10
* pyright lsp
* nvim bindings defined in [bindings.nvim.init](bindings.nvim.init)

# Using
### Clone this repo
```shell
git clone https://github.com/fuzzah/nvim-ide
cd nvim-ide
```
### Build images
It is implied that current user is in the docker group and/or can run docker commands without sudo.
```shell
./build_image.sh
```
If it's not the case, you should probably edit this script and put there correct uid, gid and desired user name.

### Run with your sources
```shell
docker run --rm -v your/sources:/src -it nvim-ide-python:latest
```

Note, that nvim is symlinked to vim. Also python and pip are symlinks to their latest versions.
