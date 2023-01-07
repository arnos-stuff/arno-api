# `python-base` sets up all our shared environment variables
FROM python:3.9.10-slim as python-base

    # python
ENV PYTHONUNBUFFERED=1
    # prevents python creating .pyc files
ENV PYTHONDONTWRITEBYTECODE=1 
ENV PYTHONUNBUFFERED 1
ENV PATH="/root/.local/bin:${PATH}"
    # pip
ENV PIP_NO_CACHE_DIR=off
ENV PIP_DISABLE_PIP_VERSION_CHECK=on
ENV PIP_DEFAULT_TIMEOUT=100

    # make poetry install to this location
ENV POETRY_HOME="/opt/poetry" 
    # make poetry create the virtual environment in the project's root
    # it gets named `.venv`
ENV POETRY_VIRTUALENVS_IN_PROJECT=true
    # do not ask any interactive question
ENV POETRY_NO_INTERACTION=1
 
    # paths
    # this is where our requirements + virtual environment will live
ENV PYSETUP_PATH="/opt/pysetup"
ENV VENV_PATH="/opt/pysetup/.venv"


# prepend poetry and venv to path + scripts home
ENV PATH="$VENV_PATH/Scripts:$POETRY_HOME/bin:$VENV_PATH/bin:$PATH"


# `builder-base` stage is used to build deps + create our virtual environment
FROM python-base as builder-base
RUN apt-get update \
    && apt-get install --no-install-recommends -y \
        # deps for installing poetry
        curl \
        # deps for building python deps
        build-essential

# install poetry - respects $POETRY_VERSION & $POETRY_HOME
RUN curl -sSL https://install.python-poetry.org | python3 -

# copy project requirement files here to ensure they will be cached.
WORKDIR $PYSETUP_PATH

# install runtime deps - uses $POETRY_VIRTUALENVS_IN_PROJECT internally
RUN pip install eudata-server==0.1.26

# `production` image used for runtime
#FROM python-base as production
#ENV FASTAPI_ENV=production
#COPY --from=builder-base $PYSETUP_PATH $PYSETUP_PATH

# expose IP we listen on
EXPOSE 8000
CMD ["python", "-m", "eudata_server", "prod", "--host", "0.0.0.0", "--port", "8000"]
