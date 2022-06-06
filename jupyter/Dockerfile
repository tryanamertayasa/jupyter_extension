FROM public.ecr.aws/j1r0q0g6/notebooks/notebook-servers/base:master-6c41e72b

USER root

# args - software versions
ARG MINIFORGE_ARCH="x86_64"
# renovate: datasource=github-tags depName=conda-forge/miniforge versioning=loose
ARG MINIFORGE_VERSION=4.10.1-4
ARG PIP_VERSION=21.1.2
ARG PYTHON_VERSION=3.7.0

# install -- node.js
RUN export DEBIAN_FRONTEND=noninteractive \
   && curl -sL "https://deb.nodesource.com/gpgkey/nodesource.gpg.key" | apt-key add - \
   && echo "deb https://deb.nodesource.com/node_14.x focal main" > /etc/apt/sources.list.d/nodesource.list \
   && apt-get -yq update \
   && apt-get -yq install --no-install-recommends \
   nodejs \
   && apt-get clean \
   && rm -rf /var/lib/apt/lists/*

# setup environment for conda
ENV CONDA_DIR /opt/conda
ENV PATH "${CONDA_DIR}/bin:${PATH}"
RUN mkdir -p ${CONDA_DIR} \
   && echo ". /opt/conda/etc/profile.d/conda.sh" >> ${HOME}/.bashrc \
   && echo ". /opt/conda/etc/profile.d/conda.sh" >> /etc/profile \
   && echo "conda activate base" >> ${HOME}/.bashrc \
   && echo "conda activate base" >> /etc/profile \
   && chown -R ${NB_USER}:users ${CONDA_DIR} \
   && chown -R ${NB_USER}:users ${HOME}

# switch to NB_UID for installs
USER ${NB_UID}

# install - conda, pip, python
RUN curl -sL "https://github.com/conda-forge/miniforge/releases/download/${MINIFORGE_VERSION}/Miniforge3-${MINIFORGE_VERSION}-Linux-${MINIFORGE_ARCH}.sh" -o /tmp/Miniforge3.sh \
   && curl -sL "https://github.com/conda-forge/miniforge/releases/download/${MINIFORGE_VERSION}/Miniforge3-${MINIFORGE_VERSION}-Linux-${MINIFORGE_ARCH}.sh.sha256" -o /tmp/Miniforge3.sh.sha256 \
   && echo "$(cat /tmp/Miniforge3.sh.sha256 | awk '{ print $1; }') /tmp/Miniforge3.sh" | sha256sum --check \
   && rm /tmp/Miniforge3.sh.sha256 \
   && /bin/bash /tmp/Miniforge3.sh -b -f -p ${CONDA_DIR} \
   && rm /tmp/Miniforge3.sh \
   && conda config --system --set auto_update_conda false \
   && conda config --system --set show_channel_urls true \
   && echo "conda ${MINIFORGE_VERSION:0:-2}" >> ${CONDA_DIR}/conda-meta/pinned \
   && echo "python ${PYTHON_VERSION}" >> ${CONDA_DIR}/conda-meta/pinned \
   && conda install -y -q \
   python=${PYTHON_VERSION} \
   conda=${MINIFORGE_VERSION:0:-2} \
   pip=${PIP_VERSION} \
   && conda update -y -q --all \
   && conda clean -a -f -y \
   && chown -R ${NB_USER}:users ${CONDA_DIR} \
   && chown -R ${NB_USER}:users ${HOME}

# install - requirements.txt
COPY --chown=jovyan:users requirements.txt /tmp
RUN python3 -m pip install -r /tmp/requirements.txt --quiet --no-cache-dir \
   && rm -f /tmp/requirements.txt \
   && jupyter lab --generate-config \
   && rm -rf ${HOME}/.cache/yarn \
   && chown -R ${NB_USER}:users ${CONDA_DIR} \
   && chown -R ${NB_USER}:users ${HOME}

# s6 - copy scripts
COPY --chown=jovyan:users s6/ /etc

# s6 - 01-copy-tmp-home
USER root
RUN mkdir -p /tmp_home \
   && cp -r ${HOME} /tmp_home \
   && chown -R ${NB_USER}:users /tmp_home
USER ${NB_UID}

EXPOSE 8888

ENTRYPOINT ["/init"]

FROM public.ecr.aws/j1r0q0g6/notebooks/notebook-servers/jupyter:master-434b10ab

USER root

# needed for LIBNVINFER
ARG OLD_CUDA_VERSION=11.1
# args - software versions
ARG CUDA_VERSION=11.2
ARG CUDA_COMPAT_VERSION=460.73.01-1
ARG CUDA_CUDART_VERSION=11.2.152-1
ARG CUDNN_VERSION=8.1.0.77-1
ARG LIBNVINFER_VERSION=7.2.3-1

# we need bash's env var character substitution
SHELL ["/bin/bash", "-c"]

# install - cuda
# for `cuda-compat-*`: https://docs.nvidia.com/cuda/eula/index.html#attachment-a
RUN curl -sL "https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64/7fa2af80.pub" | apt-key add - \
   && echo "deb https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64/ /" > /etc/apt/sources.list.d/cuda.list \
   && apt-get -yq update \
   && apt-get -yq install --no-install-recommends \
   cuda-compat-${CUDA_VERSION/./-}=${CUDA_COMPAT_VERSION} \
   cuda-cudart-${CUDA_VERSION/./-}=${CUDA_CUDART_VERSION} \
   && apt-get clean \
   && rm -rf /var/lib/apt/lists/* \
   && ln -s /usr/local/cuda-${CUDA_VERSION} /usr/local/cuda

# envs - cuda
ENV PATH /usr/local/nvidia/bin:/usr/local/cuda/bin:${PATH}
ENV LD_LIBRARY_PATH /usr/local/nvidia/lib:/usr/local/nvidia/lib64
ENV NVIDIA_VISIBLE_DEVICES all
ENV NVIDIA_DRIVER_CAPABILITIES compute,utility
ENV NVIDIA_REQUIRE_CUDA "cuda>=${CUDA_VERSION}"

# install - other nvidia stuff
RUN curl -sL "https://developer.download.nvidia.com/compute/machine-learning/repos/ubuntu2004/x86_64/3bf863cc.pub" | apt-key add - \
   && echo "deb https://developer.download.nvidia.com/compute/machine-learning/repos/ubuntu2004/x86_64 /" > /etc/apt/sources.list.d/nvidia-ml.list \
   && echo "deb https://developer.download.nvidia.com/compute/machine-learning/repos/ubuntu1804/x86_64 /" > /etc/apt/sources.list.d/nvidia-ml.list \
   && apt-get -yq update \
   && apt-get -yq install --no-install-recommends \
   cm-super \
   cuda-command-line-tools-${CUDA_VERSION/./-} \
   cuda-nvrtc-${CUDA_VERSION/./-} \
   libcublas-${CUDA_VERSION/./-} \
   libcudnn8=${CUDNN_VERSION}+cuda${CUDA_VERSION} \
   libcufft-${CUDA_VERSION/./-} \
   libcurand-${CUDA_VERSION/./-} \
   libcusolver-${CUDA_VERSION/./-} \
   libcusparse-${CUDA_VERSION/./-} \
   libfreetype6-dev \
   libhdf5-serial-dev \
   libnvinfer7=${LIBNVINFER_VERSION}+cuda${OLD_CUDA_VERSION} \
   libnvinfer-plugin7=${LIBNVINFER_VERSION}+cuda${OLD_CUDA_VERSION} \
   libzmq3-dev \
   pkg-config \
   # can't be used until NVIDIA updates (requires python < 3.7)
   # python3-libnvinfer=${LIBNVINFER_VERSION}+cuda${CUDA_VERSION} \
   && apt-get clean \
   && rm -rf /var/lib/apt/lists/*

# tensorflow fix - CUDA profiling, tensorflow requires CUPTI
ENV LD_LIBRARY_PATH /usr/local/cuda/extras/CUPTI/lib64:/usr/local/cuda/lib64:${LD_LIBRARY_PATH}

# tensorflow fix - wrong libcuda lib path (+ reconfigure dynamic linker run-time bindings)
RUN ln -s /usr/local/cuda/lib64/stubs/libcuda.so /usr/local/cuda/lib64/stubs/libcuda.so.1 \
   && echo "/usr/local/cuda/lib64/stubs" > /etc/ld.so.conf.d/z-cuda-stubs.conf \
   && ldconfig

# tensorflow fix - wrong libcusolver lib path
# https://github.com/tensorflow/tensorflow/issues/43947#issuecomment-748273679
RUN ln -s /usr/local/cuda-${CUDA_VERSION}/targets/x86_64-linux/lib/libcusolver.so.11 /usr/local/cuda-${CUDA_VERSION}/targets/x86_64-linux/lib/libcusolver.so.10

# tensorflow fix - some tensorflow tools expect a `python` binary
RUN ln -s $(which python3) /usr/local/bin/python

USER $NB_UID

# install - requirements.txt
COPY --chown=jovyan:users cuda1-requirements.txt /tmp/requirements.txt
RUN python3 -m pip install -r /tmp/requirements.txt --quiet --no-cache-dir \
   && rm -f /tmp/requirements.txt
