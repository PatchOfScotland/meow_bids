FROM ubuntu:18.04
SHELL ["/bin/bash", "-c"]

ENV TZ=Europe/Copenhagen
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
    python3 \
    python3-dev \
    python3-pip \
    python3-venv \
    python3-wheel \
    python3-tk \
    curl \
    wget \
    nano \
    mlocate \
    git \
    sudo \
    gnupg2 \
    gcc \
    libpq-dev \
    openssh-client \
    openssh-server \
    libglu1-mesa \
    libsm6 \
    libxt6 \
    libxrender1 \
    libfontconfig1 \
    libglib2.0-0 \
    qt5-default \
    iputils-ping

RUN python3 -m pip install --upgrade \
    pip \
    setuptools \
    wheel

RUN wget -O- http://neuro.debian.net/lists/bionic.gr.full | tee /etc/apt/sources.list.d/neurodebian.sources.list \
    && apt-key adv --recv-keys --keyserver hkps://keyserver.ubuntu.com 0xA5D32F012649A5A9 \
    && apt-get update
    
RUN apt-get install -y --no-install-recommends \
    fsl

RUN echo " " >> ~/.bashrc \
    && echo "#FSL" >> ~/.bashrc \
    && echo "FSLDIR=/usr/share/fsl" >> ~/.bashrc \
    && echo ". ${FSLDIR}/5.0/etc/fslconf/fsl.sh" >> ~/.bashrc \
    && echo "PATH=${FSLDIR}/5.0/bin:${PATH}" >> ~/.bashrc \ 
    && echo "export FSLDIR PATH" >> ~/.bashrc \
    && source ~/.bashrc

RUN wget http://172.17.0.1:8080/freesurfer-linux-ubuntu18_amd64-7.2.0.tar.gz

RUN tar -C /usr/local -xzvf freesurfer-linux-ubuntu18_amd64-7.2.0.tar.gz

COPY license.txt /usr/local/freesurfer/license.txt

RUN echo "" >> ~/.bashrc \
    && echo "export FREESURFER_HOME=/usr/local/freesurfer" >> ~/.bashrc \
    && echo "source $FREESURFER_HOME/SetUpFreeSurfer.sh" >> ~/.bashrc \
    && source ~/.bashrc

RUN python3 -m pip install --upgrade \
    numpy \
    nibabel \
    nipype \
    matplotlib \
    pybids \
    pyyaml \
    dataclasses

RUN mkdir ~/petsurfer \
    && cd ~/petsurfer \
    && git clone https://github.com/mnoergaard/nipype.git --branch add_pet_freesurfer \
    && cd ~/petsurfer/nipype \
    && python3 -m pip install .

RUN cd / \
    && git clone https://github.com/openneuropet/PET_pipelines.git

RUN sed -i "s|'/indirect/users/avneetkaur/Desktop/ColumbiaTest/'|'experiments/' |g" /PET_pipelines/pet_nipype/petpipeline/config.yaml \
    && sed -i "s|'derivatives/'|'derivatives/' |g" /PET_pipelines/pet_nipype/petpipeline/config.yaml \
    && sed -i "s|'working_dir/'|'working_dir/' |g" /PET_pipelines/pet_nipype/petpipeline/config.yaml \
    && sed -i 's|"/indirect/users/avneetkaur/Desktop/Columbia/rawdata/"|"/Data/"|g' /PET_pipelines/pet_nipype/petpipeline/config.yaml

COPY example.py /PET_pipelines/pyPetSurfer

RUN chmod +x /PET_pipelines/pyPetSurfer/example.py \
    && chmod +x /PET_pipelines/pet_nipype/petpipeline/main.py

#COPY job.sh /PET_pipelines/pyPetSurfer

RUN mkdir /Data /Output \
    && ln -s /Data/ /ds001421-download

ENV FSLDIR=/usr/share/fsl \
    PATH=${FSLDIR}/5.0/bin:${PATH} \
    FREESURFER_HOME=/usr/local/freesurfer \
    SUBJECTS_DIR=/usr/local/freesurfer/subjects \
    FUNCTIONALS_DIR=/usr/local/freesurfer/sessions

ENV FSFAST_HOME=${FREESURFER_HOME}/fsfast \
    PATH=${FREESURFER_HOME}/bin:${FSFAST_HOME}/bin:${PATH}
	