FROM public.ecr.aws/j1r0q0g6/notebooks/notebook-servers/jupyter:master-434b10ab

LABEL author="hansen.young@tiket.com"
ARG GITHUB_OAUTH_TOKEN

USER root
ENV GCL_DIR /opt/gcloud
ENV PATH $PATH:${GCL_DIR}/google-cloud-sdk/bin

# Update OS + Tools
RUN apt-get update && \
    apt-get -y install build-essential mono-mcs manpages-dev git htop 

# Install Google Cloud SDK
RUN curl -sSL https://sdk.cloud.google.com > /tmp/gcl \ 
    && bash /tmp/gcl --install-dir=${GCL_DIR}/ --disable-prompts 
RUN echo "source ${GCL_DIR}/google-cloud-sdk/completion.bash.inc" >> ${HOME}/.bashrc \
    && echo "source ${GCL_DIR}/google-cloud-sdk/completion.bash.inc" >> /etc/profile \
    && echo "source ${GCL_DIR}/google-cloud-sdk/path.bash.inc" >> ${HOME}/.bashrc \
    && echo "source ${GCL_DIR}/google-cloud-sdk/path.bash.inc" >> /etc/profile \
    && chown -R ${NB_USER}:users ${GCL_DIR} \
    && chown -R ${NB_USER}:users ${HOME}

USER 1000

# Install Python Libraries
RUN pip install --upgrade pip
COPY --chown=jovyan:users requirements.txt /tmp/requirements.txt

RUN python3 -m pip install -r /tmp/requirements.txt --no-cache-dir \
    && rm -f /tmp/requirements.txt
RUN pip install "git+https://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@github.com/tiket/DATA-RANGERS-CAELUM.git@v2.0.0"
RUN pip install tensorflow==2.9.0

# Install Lab Extensions
COPY --chown=jovyan:users extension /tmp/extension
RUN bash /tmp/extension/system-monitor.sh && \
    bash /tmp/extension/collapsible-heading.sh && \
    bash /tmp/extension/table-of-content.sh && \
    bash /tmp/extension/variable-inspector.sh && \
    bash /tmp/extension/code-formatter.sh && \
    bash /tmp/extension/drawio.sh && \
    bash /tmp/extension/execute-time.sh && \
    # bash /tmp/extension/lsp.sh && \
    bash /tmp/extension/git.sh
RUN jupyter lab build && \
    rm -rf /tmp/extension

# Default Extension Configurations
# The next 2 lines setups the extension directly. However in kubeflow notebook,
# these files will be replaced by the mounted volumes.
COPY --chown=jovyan:users config/jupyter_lab_config.py ${HOME}/.jupyter/jupyter_lab_config.py
COPY --chown=jovyan:users config/user-settings ${HOME}/.jupyter/lab/user-settings

# In kubeflow notebook, run `bash /tmp/setup-extension.sh` to run the setup manually.
COPY --chown=jovyan:users config/jupyter_lab_config.py /tmp/.jupyter/jupyter_lab_config.py
COPY --chown=jovyan:users config/user-settings /tmp/.jupyter/lab/user-settings
COPY --chown=jovyan:users config/setup-extension.sh /tmp/setup-extension.sh
