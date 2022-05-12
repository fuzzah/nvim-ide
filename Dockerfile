ARG cxx=false
ARG python=false

FROM opensuse/tumbleweed AS nvim-ide-base

RUN : Install common deps \
    && zypper update -y \
    && zypper install -y \
        neovim \
        git curl \
        tmux fish \
        file less psmisc \
        glibc-locale \
        strace \
        sudo \
        npm ripgrep fd \
    && zypper clean -a \
    && :
RUN ln -s /usr/bin/nvim /usr/bin/vim

ENV LANG en_US.UTF-8

RUN : Configure tmux \
    && echo "set -g mouse on" > /etc/tmux.conf \
    && mkdir -p /run/tmux \
    && :
ENV EDITOR=nvim

# use --build-arg to change defaults:
ARG uid=1000
ARG gid=1000
ARG user=dev

RUN : Configure user \
    && useradd -m -u ${uid} ${user} \
    && echo ${user} "ALL=(ALL:ALL) NOPASSWD: ALL" >> /etc/sudoers \
    && :
USER ${uid}:${gid}

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



FROM nvim-ide-base AS nvim-ide-cxx-false

FROM nvim-ide-base AS nvim-ide-cxx-true
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



FROM nvim-ide-cxx-${cxx} AS nvim-ide-python-false

FROM nvim-ide-cxx-${cxx} AS nvim-ide-python-true
USER root
RUN : Install python and pip \
    && zypper update -y \
    && zypper install -y \
        python38 python38-pip \
        python39 python39-pip \
        python310 python310-pip \
    && zypper clean -a \
    && pip3.8 install --upgrade pip \
    && pip3.9 install --upgrade pip \
    && pip3.10 install --upgrade pip \
    && :

RUN : update-alternatives for python and pip \
    && rm -f /usr/local/bin/pip \
    && update-alternatives --install /usr/bin/python python /usr/bin/python3.10 0 \
    && update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.10 0 \
    && update-alternatives --install /usr/bin/pip pip /usr/bin/pip3.10 0 \
    && update-alternatives --install /usr/bin/pip3 pip3 /usr/bin/pip3.10 0 \
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



FROM nvim-ide-python-${python} AS nvim-ide

RUN : \
    && printf '\n\
set completeopt-=preview\n\
autocmd Filetype * setlocal omnifunc=v:lua.vim.lsp.omnifunc\n\
\n' >> ~/.config/nvim/init.vim \
    && :

COPY --chown=${uid}:${gid} bindings.nvim.init /tmp/
RUN : \
    && cat /tmp/bindings.nvim.init >> ~/.config/nvim/init.vim \
    && rm /tmp/bindings.nvim.init \
    && :

