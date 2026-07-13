# global arguments
ARG MAINTAINER='MultiCash https://multi-cash.at'

ARG PIPER_REPO=https://github.com/OHF-voice/piper1-gpl.git
ARG PIPER_REPO_REF=main

ARG DEBIAN_IMAGE_VERSION=trixie-20260623-slim
ARG DEBIAN_IMAGE_HASH=28de0877c2189802884ccd20f15ee41c203573bd87bb6b883f5f46362d24c5c2
ARG DEBIAN_IMAGE=debian:${DEBIAN_IMAGE_VERSION}@sha256:${DEBIAN_IMAGE_HASH}

# ---
FROM ${DEBIAN_IMAGE}
ARG MAINTAINER
ARG PIPER_REPO
ARG PIPER_REPO_REF

ENV PIP_BREAK_SYSTEM_PACKAGES=1
ENV DATA_DIR=/root/.piper
ENV VIRTUAL_ENV=/opt/venv
ENV PATH="$VIRTUAL_ENV/bin:$PATH"

RUN apt-get update \
    && apt-get install --quiet --no-install-recommends --no-install-suggests --yes \
        python3 \
        python3-venv \
        python3-pip \
        python3-dev \
        git \
        build-essential \
        cmake \
        ninja-build \
    && rm --recursive --force /var/lib/apt/lists/* \
    && rm --recursive --force /var/log/dpkg.log /var/log/apt/*

# Set working directory
WORKDIR /app

# Clone piper repository
RUN git clone "$PIPER_REPO" . --depth=1 --branch "$PIPER_REPO_REF"

# Create python virtual environment
RUN python3 -m venv "${VIRTUAL_ENV}"

# Activate virtual environment and install piper via pip
RUN . "${VIRTUAL_ENV}"/bin/activate \
    && pip install --no-cache-dir --upgrade pip \
    && pip install --no-cache-dir -e .[dev] \
    && pip3 install 'flask>=3,<4' \
    && python3 setup.py build_ext --inplace

RUN python3 -m piper.download_voices --data-dir "${DATA_DIR}" "en_US-lessac-medium"
RUN python3 -m piper.download_voices --data-dir "${DATA_DIR}" "de_DE-thorsten-high"
RUN python3 -m piper.download_voices --data-dir "${DATA_DIR}" "en_GB-cori-high"
RUN python3 -m piper.download_voices --data-dir "${DATA_DIR}" "it_IT-paola-medium"
RUN python3 -m piper.download_voices --data-dir "${DATA_DIR}" "es_ES-davefx-medium"

# Expose http port
EXPOSE 5000

# Set docker labels
LABEL maintainer="${MAINTAINER}"
LABEL piper-version="${PIPER_REPO_REF}"

RUN mkdir --parents "${DATA_DIR}"

CMD [ "sh", "-c", "python3 -m piper.http_server -m en_US-lessac-medium --host 0.0.0.0 --port 5000 --data-dir ${DATA_DIR} --debug" ]
