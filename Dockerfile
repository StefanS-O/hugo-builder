FROM golang:1.20-buster

# Arguments for versioning
ARG HUGO_VERSION
ARG DART_SASS_VERSION="1.69.5"

# Install all dependencies and clean up in a single layer
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
    apt-get update && \
    apt-get install -y nodejs tree && \
    # Install Dart Sass
    curl -LJO "https://github.com/sass/dart-sass/releases/download/${DART_SASS_VERSION}/dart-sass-${DART_SASS_VERSION}-linux-x64.tar.gz" && \
    tar -xf dart-sass-${DART_SASS_VERSION}-linux-x64.tar.gz && \
    cp -r dart-sass/* /usr/local/bin && \
    rm -rf dart-sass* && \
    # Install Hugo based on architecture
    arch=$(dpkg --print-architecture) && \
    case ${arch} in \
    arm64) \
    curl -LJO "https://github.com/gohugoio/hugo/releases/download/v${HUGO_VERSION}/hugo_extended_${HUGO_VERSION}_linux-arm64.deb" && \
    apt-get install -y ./hugo_extended_${HUGO_VERSION}_linux-arm64.deb && \
    rm hugo_extended_${HUGO_VERSION}_linux-arm64.deb \
    ;; \
    amd64) \
    curl -LJO "https://github.com/gohugoio/hugo/releases/download/v${HUGO_VERSION}/hugo_extended_${HUGO_VERSION}_linux-amd64.deb" && \
    apt-get install -y ./hugo_extended_${HUGO_VERSION}_linux-amd64.deb && \
    rm hugo_extended_${HUGO_VERSION}_linux-amd64.deb \
    ;; \
    *) \
    echo "Unsupported architecture: ${arch}" && exit 1 \
    ;; \
    esac && \
    # Create non-root user
    useradd -m -s /bin/bash builder && \
    # Set up npm global directory for the builder user
    mkdir -p /home/builder/.npm-global && \
    chown -R builder:builder /home/builder/.npm-global && \
    # Clean up
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Switch to non-root user
USER builder

# Configure npm for the builder user
ENV NPM_CONFIG_PREFIX=/home/builder/.npm-global
ENV PATH=/home/builder/.npm-global/bin:$PATH

# Install PostCSS and CLI globally since these are needed for the commands to work
RUN npm install -g \
    postcss \
    postcss-cli && \
    npm cache clean --force

# Create a fallback node_modules with required packages
RUN mkdir -p /home/builder/fallback_modules && \
    cd /home/builder/fallback_modules && \
    npm init -y && \
    npm install \
    autoprefixer \
    @fullhuman/postcss-purgecss \
    cssnano && \
    npm cache clean --force

# Add a script that will be our entrypoint
COPY --chown=builder:builder <<'EOF' /home/builder/prepare-modules.sh
#!/bin/bash
# If project has its own package.json, use that
if [ -f "/build/package.json" ]; then
    cd /build
    npm install
else
    # If no package.json exists, symlink our fallback modules
    ln -sf /home/builder/fallback_modules/node_modules /build/node_modules
fi
# Run the actual command passed to docker
exec "$@"
EOF

RUN chmod +x /home/builder/prepare-modules.sh

WORKDIR /build

ENTRYPOINT ["/home/builder/prepare-modules.sh"]