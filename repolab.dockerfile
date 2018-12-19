FROM ubuntu:18.04

ENV DEBIAN_FRONTEND noninteractive
ENV LANG C.UTF-8
ENV LC_ALL C.UTF-8

RUN apt-get update && apt-get -yq dist-upgrade \
 && apt-get install -yq --no-install-recommends \
	locales python-pip cmake \
	python3-pip python3-setuptools git build-essential \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

RUN pip3 install jupyterlab bash_kernel \
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
WORKDIR ${HOME}

CMD ["jupyter", "lab", "--no-browser", "--ip=0.0.0.0", "--NotebookApp.token=''"]

RUN apt-get update \
 && apt-get install -yq --no-install-recommends \
    libboost-all-dev \
    libopencv-dev \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

RUN git clone https://github.com/MalcolmMielle/BetterGraph.git /BetterGraph \
 && cd /BetterGraph \
 && mkdir build \
 && cd build \
 && cmake .. \
 && make -j2 install \
 && rm -fr /BetterGraph

RUN apt-get update \
 && apt-get install -yq --no-install-recommends \
    libeigen3-dev \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

RUN git clone https://github.com/MalcolmMielle/VoDiGrEx.git /VoDiGrEx \
 && cd /VoDiGrEx \
 && mkdir build \
 && cd build \
 && cmake .. \
 && make -j2 install \
 && rm -fr /VoDiGrEx

COPY . ${HOME}
RUN chown -R ${NB_UID} ${HOME}
USER ${NB_USER}

RUN mkdir build \
 && cd build \
 && cmake .. \
 && make -j2
