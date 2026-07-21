# global arguments
ARG MAINTAINER='MultiCash https://multi-cash.at'

ARG PIPER_REPO=https://github.com/OHF-voice/piper1-gpl.git
ARG PIPER_REPO_REF=main

ARG PYTHON_IMAGE_VERSION=3.14.6-slim-trixie
ARG PYTHON_IMAGE_HASH=b877e50bd90de10af8d82c57a022fc2e0dc731c5320d762a27986facfc3355c1
ARG PYTHON_IMAGE=python:${PYTHON_IMAGE_VERSION}@sha256:${PYTHON_IMAGE_HASH}

ARG MC_PORT
ARG MC_MODEL
ARG MC_ADDITIONAL_CMD_ARGS

# ---
FROM ${PYTHON_IMAGE}
ARG MAINTAINER
ARG PIPER_REPO
ARG PIPER_REPO_REF

ARG MC_PORT
ARG MC_MODEL
ARG MC_ADDITIONAL_CMD_ARGS

ENV PIP_BREAK_SYSTEM_PACKAGES=1
ENV DATA_DIR=/root/.piper
ENV VIRTUAL_ENV=/opt/venv
ENV PATH="${VIRTUAL_ENV}/bin:$PATH"
ENV MC_PORT="${MC_PORT}:-5000"
ENV MC_MODEL="${MC_MODEL}:-en_US-lessac-medium"
ENV MC_ADDITIONAL_CMD_ARGS="${MC_ADDITIONAL_CMD_ARGS}:-"

RUN apt-get update \
    && apt-get install --quiet --no-install-recommends --no-install-suggests --yes \
        python3 \
        python3-venv \
        python3-pip \
        python3-dev \
        wget \
        git \
        build-essential \
        cmake \
        ninja-build \
    && rm --recursive --force /var/lib/apt/lists/* \
    && rm --recursive --force /var/log/dpkg.log /var/log/apt/* \
    && mkdir --parents "${DATA_DIR}"

# Set working directory
WORKDIR /app

# Clone piper repository
RUN git clone "${PIPER_REPO}" . --depth=1 --branch "${PIPER_REPO_REF}"

# Create python virtual environment
RUN python3 -m venv "${VIRTUAL_ENV}" \
    # Activate virtual environment and install piper via pip
    && . "${VIRTUAL_ENV}"/bin/activate \
    && pip install --no-cache-dir --upgrade pip \
    && pip install --no-cache-dir -e .[dev] \
    && pip3 install 'flask>=3,<4' \
    && python3 setup.py build_ext --inplace \
    # download voices
    # See: https://huggingface.co/rhasspy/piper-voices/tree/main
    && python3 -m piper.download_voices --data-dir "${DATA_DIR}" "en_US-lessac-medium" \
    && python3 -m piper.download_voices --data-dir "${DATA_DIR}" "de_DE-thorsten-high" \
    && python3 -m piper.download_voices --data-dir "${DATA_DIR}" "en_GB-cori-high" \
    && python3 -m piper.download_voices --data-dir "${DATA_DIR}" "it_IT-paola-medium" \
    && python3 -m piper.download_voices --data-dir "${DATA_DIR}" "es_ES-davefx-medium"

# Set docker labels
LABEL maintainer="${MAINTAINER}"
LABEL piper-version="${PIPER_REPO_REF}"

CMD [ "sh", "-c", "python3 -m piper.http_server -m ${MC_MODEL} --host 0.0.0.0 --port ${MC_PORT} --data-dir ${DATA_DIR} ${MC_ADDITIONAL_CMD_ARGS}" ]
