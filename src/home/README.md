
# Fedora Codespace (home)

Fedora Devcontainer designed for Cloud

## Options

| Options Id | Description | Type | Default Value |
|-----|-----|-----|-----|
| imageVariant | Fedora version: | string | nodejs-20 |
| user | Name of the home directory owner | string | vscode |
| uid | User UID. Default to 1000 | string | 1000 |
| gid | User GID. Default to UID Value. Will be overriden by wheel group | string | 1000 |
| shell | Set Users loginshell. | string | zsh |
| wsl | Prepare enviroment to be imported as WSL Distro | boolean | true |
| brew | Prepare enviroment to be imported as WSL Distro | boolean | true |
| dnfInstall | Add extra dnf Packages. | string | gh |



---

_Note: This file was auto-generated from the [devcontainer-template.json](https://github.com/coffedora/template/blob/main/src/home/devcontainer-template.json).  Add additional notes to a `NOTES.md`._
