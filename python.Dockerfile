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
