# Hugo Build Environment Docker Image

This Docker image provides a complete build environment for Hugo sites with Sass and PostCSS processing capabilities. It includes:

- Hugo Extended
- Dart Sass
- Node.js 20.x
- PostCSS with plugins (autoprefixer, purgecss)
- Other utilities (tree)

## Automated Builds

The image is automatically built and published to Docker Hub whenever a new Hugo version is released. Each image is tagged with both:

- The specific Hugo version (e.g., `yourusername/hugo-builder:0.121.1`)
- The `latest` tag

## Using the Image

### In GitLab CI

```yaml
build:
  stage: build
  image: stefanso/hugo-builder:latest
  script:
    - hugo
```

### Local Development

Pull and run the image:

```bash
# Pull the latest version
docker pull stefanso/hugo-builder:latest

# Run with current directory mounted
docker run --rm -v ${PWD}:/build stefanso/hugo-builder:latest hugo
```

## Building Locally

If you want to build the image locally:

```bash
# Build with the latest Hugo version
HUGO_VERSION=$(curl -s https://api.github.com/repos/gohugoio/hugo/releases/latest | jq -r .tag_name | sed 's/v//')
docker build --build-arg HUGO_VERSION=${HUGO_VERSION} -t hugo-builder:latest .

# Or specify a specific Hugo version
docker build --build-arg HUGO_VERSION=0.121.1 -t hugo-builder:0.121.1 .
```

### For the current directory containing your Hugo site

`docker run --rm -v ${PWD}:/build hugo-builder:latest hugo`

### Or if you want an interactive shell to run multiple commands

`docker run --rm -it -v ${PWD}:/build hugo-builder:latest /bin/bash`

### If you want to run Hugo server with live reload

`docker run --rm -it -v ${PWD}:/build -p 1313:1313 hugo-builder:latest hugo server --bind 0.0.0.0`

## Environment Variables

- `HUGO_VERSION`: Hugo version to install (required during build)
- `DART_SASS_VERSION`: Dart Sass version to install (defaults to 1.69.5)

## Architecture Support

This image supports both AMD64 (x86_64) and ARM64 (aarch64) architectures. It will automatically detect your system's architecture and download the appropriate Hugo package. This means it works on:

- Standard Intel/AMD processors (AMD64)
- Apple Silicon (M1/M2) processors (ARM64)
- Other ARM64-based systems

When building locally, the image will automatically detect your architecture and use the appropriate Hugo package. No additional configuration is needed.

### Platform-Specific Builds

If you need to build for a specific platform, you can use Docker's `--platform` flag:

```bash
# Build for AMD64
docker build --platform linux/amd64 --build-arg HUGO_VERSION=${HUGO_VERSION} -t hugo-builder:latest .

# Build for ARM64
docker build --platform linux/arm64 --build-arg HUGO_VERSION=${HUGO_VERSION} -t hugo-builder:latest .
```

## Available Tools

The image includes:

- Hugo Extended (version specified during build)
- Dart Sass (for Sass/SCSS processing)
- Node.js 20.x
- PostCSS with the following plugins:
  - postcss-cli
  - autoprefixer
  - @fullhuman/postcss-purgecss
- Tree (for directory structure visualization)

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details
