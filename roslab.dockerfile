FROM ubuntu:16.04

################################## JUPYTERLAB ##################################

ENV DEBIAN_FRONTEND noninteractive
ENV LANG C.UTF-8
ENV LC_ALL C.UTF-8

RUN apt-get -o Acquire::ForceIPv4=true update && apt-get -yq dist-upgrade \
 && apt-get -o Acquire::ForceIPv4=true install -yq --no-install-recommends \
	locales cmake git build-essential \
    python-pip \
	python3-pip python3-setuptools \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

RUN pip3 install jupyterlab==0.35.4 bash_kernel==0.7.1 tornado==5.1.1 \
 && python3 -m bash_kernel.install

ENV SHELL=/bin/bash \
	NB_USER=jovyan \
	NB_UID=1000 \
	LANG=en_US.UTF-8 \
	LANGUAGE=en_US.UTF-8

ENV HOME=/home/${NB_USER}

RUN adduser --disabled-password \
	--gecos "Default user" \
	--uid ${NB_UID} \
	${NB_USER}

EXPOSE 8888

CMD ["jupyter", "lab", "--no-browser", "--ip=0.0.0.0", "--NotebookApp.token=''"]

##################################### APT ######################################

RUN apt-get -o Acquire::ForceIPv4=true update \
 && apt-get -o Acquire::ForceIPv4=true install -yq --no-install-recommends \
    libboost-all-dev \
    libopencv-dev \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

################################### SOURCE #####################################

RUN git clone https://github.com/MalcolmMielle/BetterGraph.git /BetterGraph \
 && cd /BetterGraph \
 && mkdir build \
 && cd build \
 && cmake  ../ \
 && make -j4 install \
 && rm -fr /BetterGraph

RUN apt-get -o Acquire::ForceIPv4=true update \
 && apt-get -o Acquire::ForceIPv4=true install -yq --no-install-recommends \
    libeigen3-dev \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

RUN git clone https://github.com/MalcolmMielle/VoDiGrEx.git /VoDiGrEx \
 && cd /VoDiGrEx \
 && mkdir build \
 && cd build \
 && cmake  ../ \
 && make -j4 install \
 && rm -fr /VoDiGrEx

##################################### COPY #####################################

RUN mkdir ${HOME}/maoris

COPY . ${HOME}/maoris

#################################### CMAKE #####################################

RUN mkdir ${HOME}/maoris/build \
 && cd ${HOME}/maoris/build \
 && cmake  .. \
 && make -j2

##################################### TAIL #####################################

RUN chown -R ${NB_UID} ${HOME}

USER ${NB_USER}

WORKDIR ${HOME}/maoris
