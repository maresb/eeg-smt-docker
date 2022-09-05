FROM ghcr.io/mamba-org/micromamba-devcontainer:git-66b407f

# Ensure that all users have read-write access to all files created in the subsequent commands.
ARG DOCKERFILE_UMASK=0000

# Install hadolint for Dockerfile linting (unfortunately not yet available on conda-forge)
# <https://github.com/conda-forge/staged-recipes/pull/14581>
ADD https://github.com/hadolint/hadolint/releases/download/v2.10.0/hadolint-Linux-x86_64 /usr/local/bin/hadolint
RUN sudo chmod a+rx /usr/local/bin/hadolint

# Install the Conda packages.
COPY --chown=$MAMBA_USER:$MAMBA_USER .devcontainer/dev-conda-environment.yaml /tmp/dev-conda-environment.yaml
RUN : \
    # Configure Conda to use the conda-forge channel.
    && micromamba config append channels conda-forge \
    && micromamba install -y -f /tmp/dev-conda-environment.yaml \
    && micromamba clean --all --yes \
    ;

# Activate the conda environment for the Dockerfile.
# <https://github.com/mamba-org/micromamba-docker#running-commands-in-dockerfile-within-the-conda-environment>
ARG MAMBA_DOCKERFILE_ACTIVATE=1

# Create and set the workspace folder
ARG CONTAINER_WORKSPACE_FOLDER=/workspaces/default-workspace-folder
RUN mkdir -p "${CONTAINER_WORKSPACE_FOLDER}"
WORKDIR "${CONTAINER_WORKSPACE_FOLDER}"

RUN sudo apt-get update && sudo apt-get install -y libgl1 x11-apps
RUN mamba install -y -c conda-forge pandas plotly opencv
