FROM nvidia/cuda:11.3.1-base-ubuntu20.04
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    git \
    curl

# get miniconda
# this yields strange warnings, but ultimately works
RUN curl -fsSL -v -o ~/miniconda.sh -O  "https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh"

# install miniconda
# install conda dependencies. Adjust as neccesary
RUN chmod +x ~/miniconda.sh && \
    ~/miniconda.sh -b -p /opt/conda && \
    /opt/conda/bin/conda install -y python=3.10 && \
    /opt/conda/bin/conda install -y pytorch=1.11.0 torchvision=0.12.0 torchaudio=0.11.0 cudatoolkit=11.3 -c pytorch

ENV PATH=/opt/conda/bin:$PATH

RUN conda install -c fastchan fastai

RUN groupadd -r algorithm && useradd -m --no-log-init -r -g algorithm algorithm

RUN mkdir -p /opt/algorithm /input /output /images /test /opt/algorithm/models \
    && chown algorithm:algorithm /opt/algorithm /input /output /images /test /opt/algorithm/models /opt/conda

RUN apt-get update

RUN DEBIAN_FRONTEND=noninteractive apt-get install -y ffmpeg libsm6 libxext6 --no-install-recommends

USER algorithm

WORKDIR /opt/algorithm

ENV PATH="/home/algorithm/.local/bin:${PATH}"

RUN python -m pip install --user -U scikit-image

COPY --chown=algorithm:algorithm requirements.txt /opt/algorithm/

RUN python -m pip install --user -rrequirements.txt

COPY --chown=algorithm:algorithm process.py /opt/algorithm/

COPY --chown=algorithm:algorithm ml_utils2.py /opt/algorithm/

COPY --chown=algorithm:algorithm test/ /input/

COPY --chown=algorithm:algorithm output/ /output/

COPY --chown=algorithm:algorithm models/ /opt/algorithm/models/

ENTRYPOINT python -m process $0 $@
