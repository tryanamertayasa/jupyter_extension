# Jupyterlab Extensions

This image is the default jupyter image with several plugins installed.

## How to Install and Run
**General**
- Setup Github OAUTH: `export GITHUB_OAUTH_TOKEN=<token>`
- Build Image: `sudo bash build.sh`
- Run: `sudo docker run asia.gcr.io/tiket-0818/base_image/jupyter:jupyter-lab-plugin`

**Kubeflow Notebook**
- Create New Server with Image: `asia.gcr.io/tiket-0818/base_image/jupyter:jupyter-lab-plugin`
- Run Command: `base /tmp/setup-extension.sh`
- Restart Server

## Plugins
**New Plugins**
- [System Monitor](https://github.com/jtpio/jupyterlab-system-monitor)
- [Collapsible Headings](https://github.com/aquirdTurtle/Collapsible_Headings)
- [Table of Contents](https://github.com/jupyterlab/jupyterlab-toc)
- [Variable Inspector](https://github.com/lckr/jupyterlab-variableInspector)
- [Code Formatter](https://github.com/ryantam626/jupyterlab_code_formatter)
- [Draw IO](https://github.com/QuantStack/jupyterlab-drawio)
- [Execute Time](https://github.com/deshaw/jupyterlab-execute-time)
- [Git](https://github.com/jupyterlab/jupyterlab-git)

**New Tools**
- htop
- gcc / g++
- make

