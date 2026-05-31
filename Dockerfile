FROM steamcmd/steamcmd:ubuntu-24 AS base

ARG DEBIAN_FRONTEND=noninteractive
ARG PUID=1001
ARG PGID=1001

# Set environment variables
ENV USER=cubic
ENV HOME=/home/$USER
ENV TZ=Europe/Berlin
ENV LANG=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8

# Install wine, xvfb, cron, and xauth (required for xvfb-run)
RUN dpkg --add-architecture i386 && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
        jq \
        wine \
        wine64 \
        wine32:i386 \
        winbind \
        xvfb \
        xauth \
        cron \
        tzdata \
        locales \
        sudo \
        libvulkan1 \
        libvulkan1:i386 \
        mesa-vulkan-drivers \
        mesa-vulkan-drivers:i386 && \
    rm -rf /var/lib/apt/lists/*

RUN locale-gen en_US.UTF-8

# add new user
RUN getent group ${PGID} || groupadd -g ${PGID} ${USER} && \
    id -u ${USER} 2>/dev/null || useradd -m -d ${HOME} -u ${PUID} -g ${PGID} ${USER}

WORKDIR $HOME

# Copy batch files and give execute rights
COPY ./files ${HOME}/scripts
RUN chown -R ${USER}:${USER} ${HOME}/scripts && \
    chmod +x ${HOME}/scripts/*.sh

ENTRYPOINT ["/bin/bash", "/home/cubic/scripts/entrypoint.sh"]
CMD ["/home/cubic/scripts/start.sh"]