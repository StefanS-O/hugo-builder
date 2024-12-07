FROM golang:1.20-buster

# Arguments for versioning
ARG HUGO_VERSION
ARG DART_SASS_VERSION="1.69.5"

# Install Node.js and basic utilities
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
    apt-get update && \
    apt-get install -y nodejs tree && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Install Dart Sass
RUN curl -LJO "https://github.com/sass/dart-sass/releases/download/${DART_SASS_VERSION}/dart-sass-${DART_SASS_VERSION}-linux-x64.tar.gz" && \
    tar -xf dart-sass-${DART_SASS_VERSION}-linux-x64.tar.gz && \
    cp -r dart-sass/* /usr/local/bin && \
    rm -rf dart-sass*

# Install Hugo based on architecture
RUN arch=$(dpkg --print-architecture) && \
    case ${arch} in \
    arm64) \
    curl -LJO "https://github.com/gohugoio/hugo/releases/download/v${HUGO_VERSION}/hugo_extended_${HUGO_VERSION}_linux-arm64.deb" && \
    apt-get update && \
    apt-get install -y ./hugo_extended_${HUGO_VERSION}_linux-arm64.deb && \
    rm hugo_extended_${HUGO_VERSION}_linux-arm64.deb \
    ;; \
    amd64) \
    curl -LJO "https://github.com/gohugoio/hugo/releases/download/v${HUGO_VERSION}/hugo_extended_${HUGO_VERSION}_linux-amd64.deb" && \
    apt-get update && \
    apt-get install -y ./hugo_extended_${HUGO_VERSION}_linux-amd64.deb && \
    rm hugo_extended_${HUGO_VERSION}_linux-amd64.deb \
    ;; \
    *) \
    echo "Unsupported architecture: ${arch}" && exit 1 \
    ;; \
    esac && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Install PostCSS and related packages globally
RUN npm install -g postcss postcss-cli autoprefixer @fullhuman/postcss-purgecss && \
    npm cache clean --force

# Create a non-root user
RUN useradd -m -s /bin/bash builder
USER builder

# Set working directory for builds
WORKDIR /build