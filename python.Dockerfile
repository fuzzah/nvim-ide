FROM nvim-ide-base AS nvim-ide-python

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
    && update-alternatives --install /usr/local/bin/pip pip /usr/local/bin/pip3.10 0 \
    && update-alternatives --install /usr/local/bin/pip3 pip3 /usr/local/bin/pip3.10 0 \
    && :

RUN : Install pyright lsp \
    && npm install -g pyright \
    && :

# use --build-arg to change defaults:
ARG uid=1000
ARG gid=1000
ARG user=dev
USER ${user}

RUN : \
    && printf '\n\
lua << EOF\n\
require("lspconfig").pyright.setup{}\n\
EOF\n\
\n\
set completeopt-=preview\n\
autocmd Filetype python setlocal omnifunc=v:lua.vim.lsp.omnifuncn\n\
\n' >> ~/.config/nvim/init.vim \
    && :

COPY --chown=${uid}:${gid} python.fish bindings.nvim.init /tmp/
RUN : \
    && cat /tmp/python.fish >> ~/.config/fish/config.fish \
    && rm /tmp/python.fish \
    && cat /tmp/bindings.nvim.init >> ~/.config/nvim/init.vim \
    && rm /tmp/bindings.nvim.init \
    && :
