ARG crystal=false
ARG csharp=false
ARG cxx=false
ARG go=false
ARG python=false
ARG rust=false
ARG typescript=false
ARG zig=false

FROM opensuse/tumbleweed AS nvim-ide-base

RUN : Install common deps \
    && zypper update -y \
    && zypper install -y \
        neovim \
        git curl \
        tar gzip \
        tmux fish \
        file less psmisc \
        util-linux findutils \
        shadow sudo \
        glibc-locale \
        strace \
        npm ripgrep fd \
        update-alternatives \
    && zypper clean -a \
    && :
RUN ln -s /usr/bin/nvim /usr/bin/vim

ENV LANG=en_US.UTF-8

# use --build-arg to change defaults:
ARG uid=1000
ARG gid=1000
ARG user=dev

RUN : Configure tmux \
    && echo "set -g mouse on" > /etc/tmux.conf \
    && mkdir -p /run/tmux \
    && chown $uid:$gid -R /run/tmux \
    && :

ENV EDITOR=nvim

RUN : Configure user \
    && useradd -m -u ${uid} ${user} \
    && echo ${user} "ALL=(ALL:ALL) NOPASSWD: ALL" >> /etc/sudoers \
    && :
USER ${user}

COPY --chown=${uid}:${gid} base.fish /home/${user}/.config/fish/config.fish
RUN : Configure fish \
    && echo "exec fish" >> ~/.bashrc \
    && :

COPY --chown=${uid}:${gid} base.nvim.init /home/${user}/.config/nvim/init.vim
RUN : Configure neovim \
    && curl -fLo ~/.local/share/nvim/site/autoload/plug.vim \
        --create-dirs \
        https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim \
    && nvim --headless +PlugInstall +qall \
    && :

RUN printf '\n\n' >> ~/.config/nvim/init.vim

WORKDIR /src
ENV TERM=xterm-256color



# crystal: Crystal Language
FROM nvim-ide-base AS nvim-ide-crystal-false

FROM nvim-ide-base AS nvim-ide-crystal-true

ARG CRYSTAL_VERSION=1.13
USER root
# basically do as crystal devs suggest: https://crystal-lang.org/install/on_opensuse/
RUN : \
    && zypper ar -f \
        https://download.opensuse.org/repositories/devel:/languages:/crystal/openSUSE_Tumbleweed/devel:languages:crystal.repo \
    && zypper --gpg-auto-import-keys install -y "crystal$CRYSTAL_VERSION" \
    && zypper clean -a \
    && :

# lsp
ARG GIT_CRYSTALLINE_VERSION=0.13.1
RUN : \
    && cd /usr/bin/ \
    && curl -L \
        "https://github.com/elbywan/crystalline/releases/download/v$GIT_CRYSTALLINE_VERSION/crystalline_x86_64-unknown-linux-musl.gz" \
        | gzip -d > ./crystalline \
    && chown ${user}:${user} ./crystalline \
    && chmod a+x ./crystalline \
    && :

USER ${user}
RUN printf 'lua require("lspconfig").crystalline.setup{}\n\n' >> ~/.config/nvim/init.vim



# csharp: C#
FROM nvim-ide-crystal-${crystal} AS nvim-ide-csharp-false

FROM nvim-ide-crystal-${crystal} AS nvim-ide-csharp-true
ENV DOTNET_CLI_TELEMETRY_OPTOUT=1
ARG DOTNET_VERSION=8.0

USER root
RUN : \
    && zypper update -y \
    && zypper install -y \
        libicu \
    && rpm --import https://packages.microsoft.com/keys/microsoft.asc \
    && curl -L https://packages.microsoft.com/config/opensuse/15/prod.repo \
        -o /etc/zypp/repos.d/microsoft-prod.repo \
    && zypper install -y dotnet-sdk-"$DOTNET_VERSION" \
    && zypper clean -a \
    && :

USER ${user}

ARG DOTNET_CSHARP_LS_VERSION=0.14.0
RUN : Install csharp-ls LSP server \
    && dotnet tool install --no-cache --global \
        csharp-ls --version "$DOTNET_CSHARP_LS_VERSION" \
    && :
ENV PATH "$PATH:/home/${user}/.dotnet/tools"

RUN printf 'lua require("lspconfig").csharp_ls.setup{}\n\n' >> ~/.config/nvim/init.vim



# cxx: C and C++
FROM nvim-ide-csharp-${csharp} AS nvim-ide-cxx-false

FROM nvim-ide-csharp-${csharp} AS nvim-ide-cxx-true
USER root
RUN : \
    && zypper update -y \
    && zypper install -y \
        gcc gcc-c++ gcc-devel \
        clang lld llvm llvm-devel \
        libc++1 libc++-devel \
        libc++abi1 libc++abi-devel \
        lcov gdb ltrace \
        cmake ninja \
    && zypper clean -a \
    && :

USER ${user}
RUN printf 'lua require("lspconfig").clangd.setup{}\n\n' >> ~/.config/nvim/init.vim



# go: Golang
FROM nvim-ide-cxx-${cxx} AS nvim-ide-go-false

FROM nvim-ide-cxx-${cxx} AS nvim-ide-go-true
ARG GO=1.22
USER root
RUN : \
    && zypper update -y \
    && zypper install -y \
        go$GO go$GO-race go$GO-libstd go$GO-doc \
    && zypper clean -a \
    && :

USER ${user}
RUN : Install the gopls lsp \
    && go install golang.org/x/tools/gopls@latest \
    && :

ENV PATH="/home/${user}/go/bin:${PATH}"

RUN printf 'lua require("lspconfig").gopls.setup{}\n\n' >> ~/.config/nvim/init.vim



# python: Python3
FROM nvim-ide-go-${go} AS nvim-ide-python-false

FROM nvim-ide-go-${go} AS nvim-ide-python-true
ARG PY3=12
USER root
RUN : Install python and pip \
    && zypper update -y \
    && zypper install -y \
        python3$PY3 python3$PY3-pip \
    && zypper clean -a \
    && :

RUN : update-alternatives for python and pip \
    && update-alternatives --install /usr/bin/python python /usr/bin/python3.$PY3 0 \
    && update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.$PY3 0 \
    && :

RUN : Install pyright lsp \
    && npm install -g pyright \
    && :

USER ${user}

RUN printf 'lua require("lspconfig").pyright.setup{}\n\n' >> ~/.config/nvim/init.vim

COPY --chown=${uid}:${gid} python.fish /tmp/
RUN : \
    && cat /tmp/python.fish >> ~/.config/fish/config.fish \
    && rm /tmp/python.fish \
    && :



# Rust
FROM nvim-ide-python-${python} AS nvim-ide-rust-false

FROM nvim-ide-python-${python} AS nvim-ide-rust-true
USER root
RUN : \
    && zypper update -y \
    && zypper install -y \
        rustup \
        gdb ltrace \
    && zypper clean -a \
    && :

USER ${user}
ARG RUST_VERSION=1.79.0
RUN : \
    && rustup toolchain install "$RUST_VERSION" \
    && :

ARG RUST_ANALYZER_VERSION=2024-07-22
RUN : \
    && mkdir -p ~/.local/bin \
    && cd ~/.local/bin \
    && curl -L \
        "https://github.com/rust-lang/rust-analyzer/releases/download/$RUST_ANALYZER_VERSION/rust-analyzer-x86_64-unknown-linux-gnu.gz" \
        | gunzip -c - > ./rust-analyzer \
    && chmod a+x ./rust-analyzer \
    && :
ENV PATH="/home/$user/.local/bin:$PATH"

RUN printf 'lua require("lspconfig").rust_analyzer.setup{}\n\n' >> ~/.config/nvim/init.vim



# TypeScript
FROM nvim-ide-rust-${rust} AS nvim-ide-typescript-false

FROM nvim-ide-rust-${rust} AS nvim-ide-typescript-true
USER root
RUN : \
    && npm install -g \
        typescript \
        eslint \
        typescript-language-server \
    && :

USER ${user}

RUN printf 'lua require("lspconfig").tsserver.setup{}\n\n' >> ~/.config/nvim/init.vim



FROM nvim-ide-typescript-${typescript} AS nvim-ide-zig-false

FROM nvim-ide-typescript-${typescript} AS nvim-ide-zig-true
ARG ZIG=0.13.0
USER root
RUN : \
    && zypper update -y \
    && zypper install -y -f zig-$ZIG \
        gdb ltrace \
    && zypper clean -a \
    && :

ARG ZLS=0.13.0
ARG ZLS_TAR_URL="https://github.com/zigtools/zls/releases/download/$ZLS/zls-x86_64-linux.tar.xz"
RUN : \
    && cd /usr/local/bin \
    && curl -L "$ZLS_TAR_URL" \
        | tar -Jx \
    && chmod +x ./zls \
    && :

USER ${user}

RUN printf 'lua require("lspconfig").zls.setup{}\n\n' >> ~/.config/nvim/init.vim



FROM nvim-ide-zig-${zig} AS nvim-ide

RUN : \
    && printf '\n\
set completeopt-=preview\n\
autocmd Filetype * setlocal omnifunc=v:lua.vim.lsp.omnifunc\n\
\n\
set updatetime=500\n\
autocmd CursorHold * lua vim.diagnostic.open_float(nil, { focusable = false })\n\
\n\
colorscheme murphy\n\
\n' >> ~/.config/nvim/init.vim \
    && :

COPY --chown=${uid}:${gid} bindings.nvim.init /tmp/
RUN : \
    && cat /tmp/bindings.nvim.init >> ~/.config/nvim/init.vim \
    && rm /tmp/bindings.nvim.init \
    && :
