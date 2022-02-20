FROM nvim-ide-base AS nvim-ide-python

USER root
RUN : Install python3.10 and pip \
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
    && update-alternatives --install /usr/local/bin/pip pip /usr/local/bin/pip3.10 0 \
    && :

RUN : Install npm and pyright \
    && zypper update -y \
    && zypper install -y \
        npm \
    && zypper clean -a \
    && npm install -g pyright \
    && :

# use --build-arg to change defaults:
ARG uid=1000
ARG gid=1000
ARG user=dev

USER ${user}
COPY --chown=${uid}:${gid} python.fish /tmp/
RUN : \
    && cat /tmp/python.fish >> ~/.config/fish/config.fish \
    && rm /tmp/python.fish \
    && :

RUN : Installing LSP plugin \
    && sed -i \
        "s|call plug#end()|Plug 'https://github.com/neovim/nvim-lspconfig'\ncall plug#end()|g" \
        ~/.config/nvim/init.vim \
    && nvim --headless +PlugUpdate +PlugInstall +qall \
    && printf '\n\
lua << EOF\n\
require("lspconfig").pyright.setup{}\nEOF\n\n\
set completeopt-=preview\n\
autocmd Filetype python setlocal omnifunc=v:lua.vim.lsp.omnifunc\n\n\
let mapleader = "\<Space>"\n\n\
nnoremap <silent> gD    <cmd>lua vim.lsp.buf.declaration()<CR>\n\
nnoremap <silent> gd    <cmd>lua vim.lsp.buf.definition()<CR>\n\
nnoremap <silent> gi    <cmd>lua vim.lsp.buf.implementation()<CR>\n\
nnoremap <silent> gr    <cmd>lua vim.lsp.buf.references()<CR>\n\
nnoremap <silent> K     <cmd>lua vim.lsp.buf.hover()<CR>\n\
nnoremap <silent> <c-k> <cmd>lua vim.lsp.buf.signature_help()<CR>\n\
nnoremap <silent> <Leader>r    <cmd>lua vim.lsp.buf.rename()<CR>\n\
nnoremap <silent> <Leader>a    <cmd>lua vim.lsp.buf.code_action()<CR>\n\
nnoremap <silent> <Leader>f    <cmd>lua vim.lsp.buf.formatting()<CR>\n\
nnoremap <silent> <Leader>R    <cmd>lua vim.lsp.buf.document_symbol()<CR>\n\
nnoremap <silent> <Leader>W    <cmd>lua vim.lsp.buf.workspace_symbol()<CR>\n\n' \
        >> ~/.config/nvim/init.vim \
    && :
