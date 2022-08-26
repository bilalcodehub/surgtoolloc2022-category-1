FROM pytorch/pytorch

RUN groupadd -r algorithm && useradd -m --no-log-init -r -g algorithm algorithm

RUN mkdir -p /opt/algorithm /input /output /images /opt/algorithm/models /opt/algorithm/models/cls /opt/algorithm/models/seg \
    && chown algorithm:algorithm /opt/algorithm /input /output /images /opt/algorithm/models /opt/algorithm/models/cls /opt/algorithm/models/seg

RUN apt-get update

RUN apt-get install ffmpeg libsm6 libxext6 -y

USER algorithm

WORKDIR /opt/algorithm

ENV PATH="/home/algorithm/.local/bin:${PATH}"

RUN python -m pip install --user -U pip

RUN python -m pip install --user -U scikit-image

COPY --chown=algorithm:algorithm requirements.txt /opt/algorithm/

RUN python -m pip install --user -rrequirements.txt

COPY --chown=algorithm:algorithm process.py /opt/algorithm/

COPY --chown=algorithm:algorithm ml_utils.py /opt/algorithm/

COPY --chown=algorithm:algorithm test/ /opt/algorithm/input/

COPY --chown=algorithm:algorithm output/ /output/

COPY --chown=algorithm:algorithm models/cls/ /opt/algorithm/models/cls/

COPY --chown=algorithm:algorithm models/seg/ /opt/algorithm/models/seg/

RUN chmod -R 777 /input /output /images /opt/algorithm

ENTRYPOINT python -m process $0 $@
