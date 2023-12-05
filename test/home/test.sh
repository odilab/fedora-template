#!/bin/bash
cd $(dirname "$0")
source test-utils.sh

# Template specific tests
check "Fedora OS Release" [ $(cat /etc/os-release | grep "ID=fedora") ]
# Core Template local-feature defaults
check "DNF Available" [ "$(dnf --version)" ]
check "DNF Package Installation succeed(run which git...)" [ $(which git) ]
check "Created Userhome" [ $(cat /etc/passwd | grep "/home/") ]
# Working localy so may return here if there problems
check "Setup Brew" [ $(su vscode -c "which brew") ]
check "User $(ls /home/vscode) is in sudoers files" [ "$(ls /etc/sudoers.d/)" ]
check "User $(ls /etc/sudoers.d/) owns home" [ $(cat /etc/passwd| grep "$(ls /home/)") ]
check "Usershell installed" [ $(which zsh) ]
check "Github CLI installed" [ $(which gh) ]
# Report result
reportResults
