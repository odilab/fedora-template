#!/usr/bin/env bash
#
# Maintainer: d1sev
# Version: 0.1.0
# Snippets and Inspiration taken from: 
#    - https://github.com/microsoft/vscode-dev-containers/blob/main/script-library/common-redhat.sh
#    - https://github.com/devcontainers/features/tree/main/src/common-utils
#    - https://github.com/ublue-os/startingpoint
#    - https://github.com/devcontainers/feature-starter
#-------------------------------------------------------------------------------------------------------------
# Licensed under the MIT License. See https://go.microsoft.com/fwlink/?linkid=2090316 for license information.
#-------------------------------------------------------------------------------------------------------------
set -e
if [ "$(id -u)" -ne 0 ]; then
    echo -e 'Script must be run as root. Use sudo, su, or add "USER root" to your Dockerfile before running this script.'
    exit 1
fi
USERNAME="${USERNAME:-"automatic"}"
USER_UID="${USERUID:-"automatic"}"
USER_GID="${USERGID:-"automatic"}"
USER_SHELL=${USERSHELL:-"bash"}
INSTALL="${DNFINSTALL:-"none"}"
UPGRADE_PACKAGES="${UPGRADEPACKAGES:-"true"}"
WSL_READY="${WSLREADY:-"false"}"
BREW_READY="${BREWREADY:-"true"}"

MARKER_FILE="/usr/local/etc/vscode-dev-containers/common"
FEATURE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

DEFAULT_PACKAGES="\
    coreutils git gcc gcc-c++ less ncurses  passwd \
    procps procps-ng psmisc rsync shadow-utils strace sudo tar unzip util-linux\
    iproute ca-certificates rsync openssl-libs krb5-libs libicu zlib \
    vim-minimal wget which xz zip"
# check if INSTALL is "none" "false" or Empty string. If it's not add INSTALL to DEFAULT_PACKAGES

# Shim to use microdnf if available, otherwise lookup for dnf binary as it may be dnf5 or dnf7
# # Install dependencies and common used tool in devcontainer
if [ "${PACKAGES_ALREADY_INSTALLED}" != "true" ]; then
    # Check if dnf command will fail to create
    # Check if dnf command will fail to create symlink
    if ! dnf --version > /dev/null 2>&1; then
        ln -s $(ls /bin/dnf* | head -n 1) /bin/dnf
    fi
    if  [[ $INSTALL != "none" ]]; then
        DEFAULT_PACKAGES="${DEFAULT_PACKAGES} ${INSTALL}"
    fi 
    if  [[ $USER_SHELL != "bash" ]]; then
        DEFAULT_PACKAGES="${DEFAULT_PACKAGES} ${USER_SHELL}"
    fi 
    mapfile -d ' ' DNF_INSTALL  < <(echo "$DEFAULT_PACKAGES")
    DNF_INSTALLED=""
    DNF_FAILED=""
    for package in "${DNF_INSTALL[@]}"; do
        dnf install -y $package && DNF_INSTALLED="${DNF_INSTALLED} $package"|| DNF_FAILED="${DNF_FAILED} $package"
    done
    PACKAGES_ALREADY_INSTALLED="true"
    #get the path of the installed user shell 
    USER_SHELL=$(which ${USER_SHELL})
fi
# Update to latest versions of packages
if [ "${UPGRADE_PACKAGES}" = "true" ]; then
    dnf upgrade -y
fi
# Ensure that login shells get the correct path if the user updated the PATH using ENV.
rm -f /etc/profile.d/00-restore-env.sh
echo "export PATH=${PATH//$(sh -lc 'echo $PATH')/\$PATH}" > /etc/profile.d/00-restore-env.sh
chmod +x /etc/profile.d/00-restore-env.sh

# If in automatic mode, determine if a user already exists, if not use vscode
if [ "${USERNAME}" = "auto" ] || [ "${USERNAME}" = "automatic" ]; then
    if [ "${_REMOTE_USER}" != "root" ]; then
        USERNAME="${_REMOTE_USER}"
    else
        USERNAME=""
        POSSIBLE_USERS=("devcontainer" "vscode" "node" "codespace" "$(awk -v val=1000 -F ":" '$3==val{print $1}' /etc/passwd)")
        for CURRENT_USER in "${POSSIBLE_USERS[@]}"; do
            if id -u ${CURRENT_USER} > /dev/null 2>&1; then
                USERNAME=${CURRENT_USER}
                break
            fi
        done
        if [ "${USERNAME}" = "" ]; then
            USERNAME=vscode
        fi
    fi
elif [ "${USERNAME}" = "none" ]; then
    USERNAME=root
    USER_UID=0
    USER_GID=0
fi
# Create or update a non-root user to match UID/GID.
group_name="${USERNAME}"
if id -u ${USERNAME} > /dev/null 2>&1; then
    # User exists, update if needed
    if [ "${USER_GID}" != "automatic" ] && [ "$USER_GID" != "$(id -g $USERNAME)" ]; then
        group_name="$(id -gn $USERNAME)"
        groupmod --gid $USER_GID ${group_name}
        usermod --gid $USER_GID $USERNAME
    fi
    if [ "${USER_UID}" != "automatic" ] && [ "$USER_UID" != "$(id -u $USERNAME)" ]; then
        usermod --uid $USER_UID $USERNAME
    fi
else
    # Create user
    if [ "${USER_GID}" = "automatic" ]; then
        groupadd $USERNAME
    else
        groupadd --gid $USER_GID $USERNAME
    fi
    if [ "${USER_UID}" = "automatic" ]; then
        useradd --gid $USERNAME -m $USERNAME
    else
        useradd --uid $USER_UID --gid $USERNAME -m $USERNAME
    fi
    passwd -d ${USERNAME}
fi
# Add sudo support for non-root user
if [ "${USERNAME}" != "root" ] && [ "${EXISTING_NON_ROOT_USER}" != "${USERNAME}" ]; then
    usermod -aG wheel ${USERNAME}
    echo $USERNAME ALL=\(wheel\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME
    chmod 0440 /etc/sudoers.d/$USERNAME
    chown ${USERNAME}:${USERNAME} /home/${USERNAME}
    EXISTING_NON_ROOT_USER="${USERNAME}"
    passwd -d ${USERNAME}
    echo "EXISTING_NON_ROOT_USER: $EXISTING_NON_ROOT_USER"
fi

# ** Shell customization section **
if [ "${USERNAME}" = "root" ]; then 
    user_rc_path="/root"
else
    user_rc_path="/home/${USERNAME}"
fi
if  [[ $WSL_READY != "true" ]]; then
    echo "Skip WSL Interop Settings"
else
echo "WSL Interop Settings"
cat << 'EOF' > /etc/wsl.conf
[boot]
systemd=true
# Set a command to run when a new WSL instance launches. This example starts the Docker container service.
command = service docker start
# Automatically mount Windows drive when the distribution is launched
[automount]
# Set to true will automount fixed drives (C:/ or D:/) with DrvFs under the root directory set above. Set to false means drives won't be mounted automatically, but need to be mounted manually or with fstab.
enabled = true
# Sets the directory where fixed drives will be automatically mounted. This example changes the mount location, so your C-drive would be /c, rather than the default /mnt/c. 
root = /mnt/
# Sets the `/etc/fstab` file to be processed when a WSL distribution is launched.
mountFsTab = true
# Network host settings that enable the DNS server used by WSL 2. This example changes the hostname, sets generateHosts to false, preventing WSL from the default behavior of auto-generating /etc/hosts, and sets generateResolvConf to false, preventing WSL from auto-generating /etc/resolv.conf, so that you can create your own (ie. nameserver 1.1.1.1).
[network]
# hostname to be used for WSL distribution. Windows hostname is default
hostname = wsl
generateHosts = true
generateResolvConf = true
# Set whether WSL supports interop process like launching Windows apps and adding path variables. Setting these to false will block the launch of Windows processes and block adding $PATH environment variables.
[interop]
# Setting this key will determine whether WSL will support launching Windows processes.
enabled = true
# Setting this key will determine whether WSL will add Windows path elements to the $PATH environment variable.
appendWindowsPath = true
EOF
   if [ "${USERNAME}" != "root" ]; then
        #append on  .wsl.conf with default values to enable login with default user
        echo "[user]" >> /etc/wsl.conf
        echo "default=${USERNAME}" >> /etc/wsl.conf
        # create workspace directory in root and make root and $USERNAME the owner
        mkdir -p /workspace
        chown -R ${USERNAME}:${USERNAME} /workspace
    fi
fi
# code shim, it fallbacks to code-insiders if code is not available
cat << 'EOF' > /usr/local/bin/code
#!/bin/sh

get_in_path_except_current() {
    which -a "$1" | grep -A1 "$0" | grep -v "$0"
}
workpath="."
code="$(get_in_path_except_current code)"
if [ -n "$@" ]; then
    workpath=$@
fi
if [ -n "$code" ]; then
    exec "$code" "$workpath" 
elif [ "$(command -v code-insiders)" ]; then
    exec code-insiders "$workpath"
else
    echo "code or code-insiders is not installed" >&2
    exit 127
fi
EOF
chmod +x /usr/local/bin/code

# Persist image metadata info, script if meta.env found in same directory
meta_info_script="$(cat << 'EOF'
#!/bin/sh
. /usr/local/etc/vscode-dev-containers/meta.env

# Minimal output
if [ "$1" = "version" ] || [ "$1" = "image-version" ]; then
    echo "${VERSION}"
    exit 0
elif [ "$1" = "release" ]; then
    echo "${GIT_REPOSITORY_RELEASE}"
    exit 0
elif [ "$1" = "content" ] || [ "$1" = "content-url" ] || [ "$1" = "contents" ] || [ "$1" = "contents-url" ]; then
    echo "${CONTENTS_URL}"
    exit 0
fi

#Full output
echo
echo "Development container image information"
echo
if [ ! -z "${VERSION}" ]; then echo "- Image version: ${VERSION}"; fi
if [ ! -z "${DEFINITION_ID}" ]; then echo "- Definition ID: ${DEFINITION_ID}"; fi
if [ ! -z "${VARIANT}" ]; then echo "- Variant: ${VARIANT}"; fi
if [ ! -z "${GIT_REPOSITORY}" ]; then echo "- Source code repository: ${GIT_REPOSITORY}"; fi
if [ ! -z "${GIT_REPOSITORY_RELEASE}" ]; then echo "- Source code release/branch: ${GIT_REPOSITORY_RELEASE}"; fi
if [ ! -z "${BUILD_TIMESTAMP}" ]; then echo "- Timestamp: ${BUILD_TIMESTAMP}"; fi
if [ ! -z "${CONTENTS_URL}" ]; then echo && echo "More info: ${CONTENTS_URL}"; fi
echo
EOF
)"
if [ -f "${SCRIPT_DIR}/meta.env" ]; then
    mkdir -p /usr/local/etc/vscode-dev-containers/
    cp -f "${SCRIPT_DIR}/meta.env" /usr/local/etc/vscode-dev-containers/meta.env
     echo "${meta_info_script}" > /usr/local/bin/devcontainer-info
    chmod +x /usr/local/bin/devcontainer-info
fi

if  [[ $BREW_READY != "true" ]]; then
    echo "Skip Homebrew installation"
else
    su $USERNAME -c "NONINTERACTIVE=1 /bin/bash $(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    (echo; echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"')>> /etc/bash.bashrc
    (echo; echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"') > /etc/profile.d/brew.sh
    chown -R ${USERNAME}:${USERNAME} /home/linuxbrew/.linuxbrew   
    PATH="${user_rc_path}/bin:${user_rc_path}/.local/bin:/home/linuxbrew/.linuxbrew/bin/:/home/linuxbrew/.linuxbrew/sbin/:$PATH"
    HOMEBREW_INSTALLED=$BREW_READY
fi
# Write marker file
mkdir -p "$(dirname "${MARKER_FILE}")"
echo -e "\
    PACKAGES_ALREADY_INSTALLED=${PACKAGES_ALREADY_INSTALLED}\n\
    EXISTING_NON_ROOT_USER=${EXISTING_NON_ROOT_USER}\n\
    HOMEBREW_INSTALLED=${HOMEBREW_INSTALLED}\n\
    DNF_INSTALLED=$DNF_INSTALLED\n\
    DNF_FAILED=$DNF_FAILED\n\
    WSLENV=${WSL_READY}"
echo "Done!"
dnf clean all
rm -rf /var/cache/*