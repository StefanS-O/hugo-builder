FROM golang:1.20-buster

# Arguments for versioning
ARG HUGO_VERSION
ARG DART_SASS_VERSION="1.69.5"

# Install Node.js
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
    apt-get update && \
    apt-get install -y nodejs tree

# Install Dart Sass
RUN curl -LJO "https://github.com/sass/dart-sass/releases/download/${DART_SASS_VERSION}/dart-sass-${DART_SASS_VERSION}-linux-x64.tar.gz" && \
    tar -xf dart-sass-${DART_SASS_VERSION}-linux-x64.tar.gz && \
    cp -r dart-sass/* /usr/local/bin && \
    rm -rf dart-sass*

# Install Hugo
RUN arch=$(dpkg --print-architecture) && \
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
    esac

# Create non-root user and setup global npm directory
RUN useradd -m -s /bin/bash builder && \
    mkdir -p /usr/lib/node_modules && \
    chown -R builder:builder /usr/lib/node_modules && \
    chown -R builder:builder /usr/bin

# Install PostCSS globally
RUN npm install -g postcss postcss-cli

# Make sure npm's global bin directory is accessible to builder
RUN chown -R builder:builder $(npm config get prefix)/{lib/node_modules,bin,share}

# Clean up
RUN apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Switch to non-root user
USER builder

WORKDIR /build