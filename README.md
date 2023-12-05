# Dev Container Templates: FEdora Based Devcontainer - Coffedora

## How to get the CLI
On linux you can install the ClI tool via homebrew.
On windows you have to use it from wsl or install npm first.
Easiest way to get npm is the *node version manager* **nvm** 
```powershell
scoop install nvm
nvm install lts
nvm apply lts
npm install -g @devcontainers/cli
```


## How to get the Template in my project
Apply the template in a directory and edit the ARG in Dockerfile. YOu have also to adjust the name in the devcontainer.json
```powershell
devcontainer templates apply -t 'ghcr.io/coffedora/template/init:latest' 
```

