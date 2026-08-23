# This dockerfile builds an image for the backend package.
# It should be executed with the root of the repo as docker context.
#
# Before building this image, run:
#
# yarn install --immutable
# yarn tsc
# yarn build:backend
#
# Host build steps must use the same Node version as the FROM image below.

FROM node:24-trixie-slim

# Install runtime dependencies:
# - libsqlite3-dev for Backstage sqlite/native dependencies
# - python3 + pip for TechDocs local generation
# - python3-venv because Debian/PEP 668 discourages system pip installs
#
# TechDocs will use a dedicated virtual environment at /opt/techdocs.
USER root

RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    apt-get update && \
    apt-get install -y --no-install-recommends \
      libsqlite3-dev \
      python3 \
      python3-pip \
      python3-venv \
      git && \
    rm -rf /var/lib/apt/lists/*

# Create an isolated Python environment for Backstage TechDocs.
RUN python3 -m venv /opt/techdocs && \
    /opt/techdocs/bin/pip install --no-cache-dir --upgrade pip setuptools wheel && \
    /opt/techdocs/bin/pip install --no-cache-dir mkdocs-techdocs-core

# Make mkdocs and Python tools from the TechDocs virtual environment
# directly available to Backstage.
ENV PATH="/opt/techdocs/bin:${PATH}"

# Verify TechDocs dependencies during image build.
RUN python3 --version && \
    mkdocs --version

# From here on run the Backstage backend as the least-privileged node user.
USER node

WORKDIR /app

# Copy files needed by Yarn.
COPY --chown=node:node .yarn ./.yarn
COPY --chown=node:node .yarnrc.yml ./
COPY --chown=node:node backstage.json ./

ENV NODE_ENV=production

# Copy repo skeleton first to improve Docker layer caching.
COPY --chown=node:node yarn.lock package.json packages/backend/dist/skeleton.tar.gz ./

RUN tar xzf skeleton.tar.gz && rm skeleton.tar.gz

RUN --mount=type=cache,target=/home/node/.cache/yarn,sharing=locked,uid=1000,gid=1000 \
    yarn workspaces focus --all --production && \
    rm -rf "$(yarn cache clean)"

# Include Backstage software templates and catalog files.
COPY --chown=node:node examples ./examples
COPY --chown=node:node catalog ./catalog

# Copy backend bundle and configuration.
COPY --chown=node:node packages/backend/dist/bundle.tar.gz app-config*.yaml ./

RUN tar xzf bundle.tar.gz && rm bundle.tar.gz

CMD ["node", "packages/backend", "--config", "app-config.yaml", "--config", "app-config.production.yaml"]
