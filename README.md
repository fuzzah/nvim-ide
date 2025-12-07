# nvim-ide
Docker images with nvim, plugins and lsp preconfigured by fuzzah for fuzzah.<br>
Anyway, if you use it:
* at least use [cool-retro-term](https://github.com/Swordfish90/cool-retro-term) for better experience;
* you may want to customize keybindings and plugins;
* note, that changes will come from time to time just to break everything.

# What's inside
## Base image
* uses opensuse/tumbleweed
* nvim with vim-plug and plugins:
    * vim-airline
    * nvim-lspconfig
    * nvim-treesitter
    * plenary.nvim
    * telescope.nvim
    * vim-crystal
    * zig.vim
* git
* strace
* npm
* ripgrep & fd utils
* tmux with mouse mode enabled
* non-root user to not mess access rights of your source code (can use sudo)
* fish shell with abbreviations (aliases) defined in [base.fish](base.fish):
    * git (gs, ga, gas, gc, gm, gk, ...)
    * find (ff, fff, fd, ffd)
    * edit configs (nvim: cfv, fish: cff, bashrc: cfb)
* workdir is /src


## Crystal
(installable with `--build-arg crystal=true`)
* crystal with its package manager `shards`
* crystalline lsp


## C#
(installable with `--build-arg csharp=true`)
* dotnet-sdk-8.0
* csharp-ls


## C and C++
(installable with `--build-arg cxx=true`)
* clang (includes clangd lsp), llvm
* gcc, gcc-c++
* cmake
* ninja
* lcov
* gdb
* ltrace


## Go
(installable with `--build-arg go=true`)
* go from repos
* gopls lsp


## Python
(installable with `--build-arg python=true`)
* python + pip from repos
* pyright lsp


## Rust
(installable with `--build-arg rust=true`)
* rustup
* rustc & cargo
* rust-analyzer lsp
* gdb
* ltrace


## TypeScript
(installable with `--build-arg typescript=true`)
* typescript
* eslint
* typescript-language-server


## Zig
(installable with `--build-arg zig=true`)
* zig from repos
* the zls language server
* gdb
* ltrace


## Common last stage
* nvim bindings defined in [bindings.nvim.init](bindings.nvim.init)

# Using
### Clone this repo
```shell
git clone https://github.com/fuzzah/nvim-ide
cd nvim-ide
```
### Build image
You can use docker build arguments:<br>
`user` is user name in docker<br>
`uid` and `gid` are user id and group id for user in docker<br>
`crystal`, `csharp`, `cxx`, `go`, `python`, `rust`, `typescript`: set to `true` if you need this language support in nvim.<br>
Example:
```shell
DOCKER_BUILDKIT=1 docker build \
    --build-arg user=$USER \
    --build-arg uid=$(id -u) --build-arg gid=$(id -g) \
    --build-arg cxx=true --build-arg python=true -t fuzzah-nvim-ide .
```
**Note: without buildkit the image building may fail.**<br>
If you run `docker build` as root, you may want to use specific values for uid and gid:
```shell
DOCKER_BUILDKIT=1 docker build \
    --build-arg user=dev \
    --build-arg uid=1000 --build-arg gid=1000 \
    --build-arg cxx=true --build-arg python=true -t fuzzah-nvim-ide .
```


### Run with your sources
```shell
cd myproject
docker run --pull=never --rm -v $(pwd):/src -w /src -it fuzzah-nvim-ide
```

Note: vim is a simlink to nvim.


# FAQ
## How to use bash? It autostarts fish!
Start bash with `--norc` option to skip loading of bashrc file:
```shell
bash --norc
```

## Why opensuse/tumbleweed? Why not alpine?
Tumbleweed provides recent versions of python, clang, gcc, and most importantly neovim.<br>
Alpine would cause problems with python wheels and also with C/C++ as it's built with musl.<br>
