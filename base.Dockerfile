FROM opensuse/tumbleweed AS nvim-ide-base

RUN : Install common deps \
    && zypper update -y \
    && zypper install -y \
        neovim \
        git curl \
        tmux fish \
        file less psmisc \
        glibc-locale \
        sudo \
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

WORKDIR /src
