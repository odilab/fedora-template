
# Fedora Codespace (init)

Fedora Devcontainer designed for Cloud

## Options

| Options Id | Description | Type | Default Value |
|-----|-----|-----|-----|
| imageVariant | Fedora version: | string | 39 |
| user | Name of the home directory owner | string | vscode |
| uid | User UID. Default to 1000 | string | 1000 |
| gid | User GID. Default to UID Value. Will be overriden by wheel group | string | 1000 |
| shell | Set Users loginshell | string | zsh |
| brew | Preinstall Homebrew | string | true |



---

_Note: This file was auto-generated from the [devcontainer-template.json](https://github.com/coffedora/template/blob/main/src/init/devcontainer-template.json).  Add additional notes to a `NOTES.md`._
