# This image builds Yocto jobs using the kas tool

FROM debian:buster-slim

ARG TARGETPLATFORM
ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y locales && \
    localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8
ENV LANG=en_US.utf8

RUN apt-get install --no-install-recommends -y \
        openssh-client \
        sudo \
        gawk wget git-core diffstat unzip texinfo \
        build-essential chrpath socat cpio python python3 python3-pip python3-pexpect \
        xz-utils debianutils iputils-ping python3-git python3-jinja2 libegl1-mesa libsdl1.2-dev \
        pylint3 xterm \
        python3-setuptools python3-wheel python3-yaml python3-distro python3-jsonschema \
        gosu lsb-release file vim less procps tree tar bzip2 zstd bc tmux libncurses-dev \
        dosfstools mtools parted \
        git-lfs mercurial iproute2 ssh-client curl rsync gnupg awscli && \
    if [ "$TARGETPLATFORM" = "linux/amd64" ]; then \
        apt-get install --no-install-recommends -y gcc-multilib syslinux; \
    fi && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN wget -nv -O /usr/bin/oe-git-proxy "http://git.yoctoproject.org/cgit/cgit.cgi/poky/plain/scripts/oe-git-proxy" && \
    chmod +x /usr/bin/oe-git-proxy
ENV GIT_PROXY_COMMAND="oe-git-proxy" \
    NO_PROXY="*"

COPY . /kas
RUN pip3 --proxy=$https_proxy install --no-deps /kas && kas --help

RUN useradd -m -s /bin/bash -G sudo runner
RUN echo "runner ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

USER runner

ENTRYPOINT ["/kas/container-entrypoint"]
