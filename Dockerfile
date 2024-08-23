# Start with a base image
FROM alpine:latest

# Set environment variables
ENV LANG=C.UTF-8

# Install necessary packages
RUN apk add --no-cache \
    wget \
    unzip \
    curl \
    git \
    python3 \
    py3-pip \
    bash \
    py3-virtualenv \
    npm 

RUN addgroup -S sonicgroup && adduser -S sonic -G sonicgroup

# some of the liners need to be installed via sonic to prevent problematic nonroot stuff
USER sonic

WORKDIR /home/sonic

# python linters + needed to run app
RUN python3 -m venv /home/sonic/venv

# Set environment variable for the virtual environment
ENV PATH="/home/sonic/venv/bin:$PATH"

# Install Python linters inside the virtual environment
#PIPVENV__START
RUN PYTHONDONTWRITEBYTECODE=1 pip3 install --no-cache-dir --upgrade pip virtualenv \
    && mkdir -p "/home/sonic/venvs/pylint" && cd "/home/sonic/venvs/pylint" && virtualenv . && source bin/activate && PYTHONDONTWRITEBYTECODE=1 pip3 install --no-cache-dir pylint typing-extensions && deactivate && cd ./../.. \
    && mkdir -p "/home/sonic/venvs/black" && cd "/home/sonic/venvs/black" && virtualenv . && source bin/activate && PYTHONDONTWRITEBYTECODE=1 pip3 install --no-cache-dir black && deactivate && cd ./../.. \
    && mkdir -p "/home/sonic/venvs/flake8" && cd "/home/sonic/venvs/flake8" && virtualenv . && source bin/activate && PYTHONDONTWRITEBYTECODE=1 pip3 install --no-cache-dir flake8 && deactivate && cd ./../.. \
    && mkdir -p "/home/sonic/venvs/isort" && cd "/home/sonic/venvs/isort" && virtualenv . && source bin/activate && PYTHONDONTWRITEBYTECODE=1 pip3 install --no-cache-dir isort black && deactivate && cd ./../.. \
    && mkdir -p "/home/sonic/venvs/bandit" && cd "/home/sonic/venvs/bandit" && virtualenv . && source bin/activate && PYTHONDONTWRITEBYTECODE=1 pip3 install --no-cache-dir bandit bandit_sarif_formatter bandit[toml] && deactivate && cd ./../.. \
    && mkdir -p "/home/sonic/venvs/mypy" && cd "/home/sonic/venvs/mypy" && virtualenv . && source bin/activate && PYTHONDONTWRITEBYTECODE=1 pip3 install --no-cache-dir mypy && deactivate && cd ./../.. \
    && mkdir -p "/home/sonic/venvs/pyright" && cd "/home/sonic/venvs/pyright" && virtualenv . && source bin/activate && PYTHONDONTWRITEBYTECODE=1 pip3 install --no-cache-dir pyright && deactivate && cd ./../.. \
    && mkdir -p "/home/sonic/venvs/ruff" && cd "/home/sonic/venvs/ruff" && virtualenv . && source bin/activate && PYTHONDONTWRITEBYTECODE=1 pip3 install --no-cache-dir ruff && deactivate && cd ./../.. \
    && mkdir -p "/home/sonic/venvs/snakefmt" && cd "/home/sonic/venvs/snakefmt" && virtualenv . && source bin/activate && PYTHONDONTWRITEBYTECODE=1 pip3 install --no-cache-dir snakefmt && deactivate && cd ./../.. \
    && mkdir -p "/home/sonic/venvs/yamllint" && cd "/home/sonic/venvs/yamllint" && virtualenv . && source bin/activate && PYTHONDONTWRITEBYTECODE=1 pip3 install --no-cache-dir yamllint && deactivate && cd ./../.. \
    && find /home/sonic/venvs \( -type f \( -iname \*.pyc -o -iname \*.pyo \) -o -type d -iname __pycache__ \) -delete \
    && rm -rf /home/sonic/.cache
ENV PATH="${PATH}":/home/sonic/venvs/pylint/bin:/home/sonic/venvs/black/bin:/home/sonic/venvs/flake8/bin:/home/sonic/venvs/isort/bin:/home/sonic/venvs/bandit/bin:/home/sonic/venvs/mypy/bin:/home/sonic/venvs/pyright/bin:/home/sonic/venvs/ruff/bin:/home/sonic/venvs/snakefmt/bin:/home/sonic/venvs/yamllint/bin
#PIPVENV__END

COPY ./server/requirements.txt ./requirements.txt
RUN pip install -r requirements.txt
COPY ./.config/python/dev/requirements.txt ./requirements.txt
RUN pip install -r requirements.txt

USER root

# JavaScript linters
RUN npm install -g eslint prettier
RUN npm install -g standard

# TypeScript linters
RUN npm install -g ts-standard
RUN npm install -g v8r
RUN npm install -g jsonlint
RUN npm install -g pyright
# Docker linters
COPY ./binaries/hadolint /usr/bin/

# Kubernetes linters
RUN  apk add helm --no-cache
COPY ./binaries/kubeconform /usr/bin/






# Copy scripts and rules to container
COPY megalinter /home/sonic/megalinter
COPY megalinter/descriptors /home/sonic/megalinter-descriptors
COPY TEMPLATES /home/sonic/action/lib/.automation
# Copy server scripts
COPY server /home/sonic/server

# Get the build arguments
ARG BUILD_DATE
ARG BUILD_REVISION
ARG BUILD_VERSION

# Set ENV values used for debugging the version
ENV BUILD_DATE=$BUILD_DATE \
    BUILD_REVISION=$BUILD_REVISION \
    BUILD_VERSION=$BUILD_VERSION

# Label the instance and set maintainer
LABEL com.github.actions.name="MegaLinter" \
      com.github.actions.description="The ultimate linters aggregator to make sure your projects are clean" \
      com.github.actions.icon="code" \
      com.github.actions.color="red" \
      maintainer="Nicolas Vuillamy <nicolas.vuillamy@gmail.com>" \
      org.opencontainers.image.created=$BUILD_DATE \
      org.opencontainers.image.revision=$BUILD_REVISION \
      org.opencontainers.image.version=$BUILD_VERSION \
      org.opencontainers.image.authors="Nicolas Vuillamy <nicolas.vuillamy@gmail.com>" \
      org.opencontainers.image.url="https://megalinter.io" \
      org.opencontainers.image.source="https://github.com/oxsecurity/megalinter" \
      org.opencontainers.image.documentation="https://megalinter.io" \
      org.opencontainers.image.vendor="Nicolas Vuillamy" \
      org.opencontainers.image.description="Lint your code base with GitHub Actions"

# init stuff
COPY entrypoint.sh /home/sonic/entrypoint.sh
RUN chmod +x entrypoint.sh
RUN mkdir /home/sonic/lint
# hardcoded stuff for nonroot
RUN chmod o=rwX /home/sonic/lint
RUN chmod o=rwX /home/sonic/.cache
RUN chmod o=rwX /home/sonic
# need by python linters & app
ENV HOME=/home/sonic
ENV AZURE_DEVOPS_CACHE_DIR=/home/sonic

ENV DEFAULT_WORKSPACE="/home/sonic/lint"
# default conf
ENV KUBERNETES_HELM_CHART_DIRECTORY="You_must_specify_a_directory_for_chart_where_Chart.yaml_appear_in_seperate_env__KUBERNETES_HELM_CHART_DIRECTORY:_[path]_"
ENV MEGALINTER_CONF="ENABLE: JAVASCRIPT,TYPESCRIPT,PYTHON,JSON,DOCKERFILE,KUBERNETES,YAML\n\
DISABLE_LINTERS: KUBERNETES_KUBESCAPE\n\
KUBERNETES_DIRECTORY: \"\"\n\
KUBERNETES_HELM_ARGUMENTS: ${KUBERNETES_HELM_CHART_DIRECTORY}"

COPY ./dummyfiles /home/sonic/lint/
WORKDIR /home/sonic/lint

USER nobody
# need to remove comment after transfer image 
# ENTRYPOINT ["/bin/bash", "/home/sonic/entrypoint.sh"]
