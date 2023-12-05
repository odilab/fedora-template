# templateOption default overrides Dockerfile default and build args. 
FROM quay.io/fedora/fedora-minimal:${templateOption:imageVariant}
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
COPY ./bin/ /usr/local/bin/
COPY ./.env /tmp/env
ARG USERNAME=vscode
ARG USERSHELL=bash
ARG USER_UID=1000
ARG USER_GID=${USER_UID}
ARG INSTALL_HOMEBREW=true
RUN cat /tmp/env >> /etc/enviroment || true \
    && chmod +rx /usr/local/bin/* || true \
    && dnf -y update \
    && dnf -y install ${USERSHELL} coreutils git gh gcc gcc-c++ less ncurses openssh-clients passwd \
        procps procps-ng psmisc rsync shadow-utils strace sudo tar unzip util-linux \
        vim-minimal wget which xz zip \
    && groupadd --gid ${USER_GID} ${USERNAME} \
    && useradd --uid ${USER_UID} -s /bin/${USERSHELL} --gid ${USER_GID} -m ${USERNAME} \
    && usermod -aG wheel ${USERNAME} \
    && echo "%wheel ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/${USERNAME} \
    && chmod 0440 /etc/sudoers.d/${USERNAME} \
    && mkdir -p /workspaces && chown -R ${USERNAME} /workspaces \
    && ln -s /workspaces/ /home/${USERNAME}/workspaces \
    && chown -R ${USERNAME} /usr/local/bin/ \
    && chown -R ${USERNAME} /home/${USERNAME}  \
    && dnf clean all \
    && rm -rf /var/cache/dnf\ 
    && rm -rfd /tmp/* \
    && passwd -d ${USERNAME}
USER ${USERNAME}
RUN if  [[ $INSTALL_HOMEBREW == "true" ]]; then \
    NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)";fi
ENV PATH="$HOME/bin:$HOME/.local/bin:/home/linuxbrew/.linuxbrew/bin/:/home/linuxbrew/.linuxbrew/sbin/:$PATH"
# VOLUME [ "/var/lib/docker/" ]
# WORKDIR /workspaces
# CMD  ["/bin/${USERSHELL} -c"]
LABEL version="0.1.0"
LABEL org.opencontainers.image.authors="disev@d1sev.dev"
LABEL org.opencontainers.image.description="This Containerfile creates a fedora-minimal image \
    to meet the minimal requirements of the devcontainer cli and skip most repeated installation \
    for a full user enviroment."
LABEL changes="installs gh git which wget tar xz zip tar sudo to run \
    common shell commands. Links dnf5 to dnf for backward compatibility. \
    Adds user home for UID=1000"