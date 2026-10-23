# ghcr.io/mi-avionics/ci-base -- the standard job container for MI-Avionics'
# self-hosted runners (runs-on: [self-hosted, onprem]). Those runners
# require every job to declare `container:`, so this image carries the
# tools the org's workflows use. See README.md for the contents and how to
# add a tool.
FROM ubuntu:24.04@sha256:68ee22004a9109b44973313b02ff7b1de250f1de0f5ecb628d73f579aaff33ac

ARG TERRAFORM_VERSION=1.17.0
ARG NODE_MAJOR=24

# PIP_BREAK_SYSTEM_PACKAGES: 24.04's Python refuses `pip install` outside a
# venv (PEP 668). Each job gets a fresh copy of this image, so installing
# into the system Python is harmless here and matches what workflows
# written for ubuntu-latest expect.
ENV DEBIAN_FRONTEND=noninteractive \
    LANG=C.UTF-8 \
    PIP_BREAK_SYSTEM_PACKAGES=1 \
    PIP_ROOT_USER_ACTION=ignore

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Base tools, then the vendors' own apt repos for Node.js, the Docker CLI,
# the GitHub CLI and Terraform (newer than Ubuntu's, or not packaged there).
RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      ca-certificates curl wget gnupg git git-lfs openssh-client \
      jq zip unzip xz-utils rsync make build-essential \
      python3 python3-pip python3-venv python-is-python3 \
 && install -d -m 0755 /etc/apt/keyrings \
 && curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key \
      | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg \
 && echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_${NODE_MAJOR}.x nodistro main" \
      > /etc/apt/sources.list.d/nodesource.list \
 && curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc \
 && echo "deb [signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu noble stable" \
      > /etc/apt/sources.list.d/docker.list \
 && curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg -o /etc/apt/keyrings/githubcli.gpg \
 && echo "deb [signed-by=/etc/apt/keyrings/githubcli.gpg] https://cli.github.com/packages stable main" \
      > /etc/apt/sources.list.d/github-cli.list \
 && curl -fsSL https://apt.releases.hashicorp.com/gpg | gpg --dearmor -o /etc/apt/keyrings/hashicorp.gpg \
 && echo "deb [signed-by=/etc/apt/keyrings/hashicorp.gpg] https://apt.releases.hashicorp.com noble main" \
      > /etc/apt/sources.list.d/hashicorp.list \
 && apt-get update \
 && apt-get install -y --no-install-recommends \
      nodejs docker-ce-cli docker-buildx-plugin gh "terraform=${TERRAFORM_VERSION}-*" \
 && git lfs install --system \
 && rm -rf /var/lib/apt/lists/*

# AWS CLI v2 isn't in apt; AWS's own installer.
RUN curl -fsSL "https://awscli.amazonaws.com/awscli-exe-linux-$(uname -m).zip" -o /tmp/awscli.zip \
 && unzip -q /tmp/awscli.zip -d /tmp \
 && /tmp/aws/install \
 && rm -rf /tmp/aws /tmp/awscli.zip

# Salesforce CLI (sf), used by salesforce-metadata.
RUN npm install -g @salesforce/cli \
 && npm cache clean --force
