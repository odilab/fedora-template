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
MARKER_FILE="/usr/local/etc/vscode-dev-containers/local-editor"
# Write marker file
mkdir -p "$(dirname "${MARKER_FILE}")"
echo "Done!"