#!/bin/bash
cd $(dirname "$0")
source test-utils.sh

# Template specific tests
check "$(cat /etc/os-release)" [ $(cat /etc/os-release | grep "ID=fedora") ]
check "$(which dnf)" [ $(which dnf) ]  
# Working localy so may return here if there problems
check "$(cat /etc/passwd | grep "vscode")" [ $(cat /etc/passwd | grep "vscode") ]
check "$(brew doctor)" [ $(which brew) ]  
#check "User is in sudoers files $(ls /etc/sudoers.d/ | grep "coffe")" [ $(ls /etc/sudoers.d/ | grep "coffe") ]
# Report result
reportResults