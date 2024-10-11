# TagLib statically cross-compiled

![Build](https://img.shields.io/github/actions/workflow/status/navidrome/cross-taglib/ci.yml?branch=main&logo=github&style=flat-square)
[![Last Release](https://img.shields.io/github/v/release/navidrome/cross-taglib?logo=github&label=latest&style=flat-square)](https://github.com/navidrome/cross-taglib/releases)

## Purpose

This repository provides a statically cross-compiled version of [TagLib](https://taglib.org), a library for reading and 
editing metadata of several popular audio formats. This project requires [Docker or Docker Desktop](https://docker.com) 
to work locally

## Supported platforms
This table shows the platforms and architectures supported by this project. To build for a specific platform, use 
the `make build` command with the `PLATFORMS` variable set to the desired platform(s)

| Platform      | Param to `make` |
|---------------|-----------------|
| Linux AMD64   | linux/amd64     |
| Linux 386     | linux/386       |
| Linux ARM64   | linux/arm64     |
| Linux ARMv7   | linux/arm/v7    |
| Linux ARMv6   | linux/arm/v6    |
| Linux ARMv5   | linux/arm/v5    |
| Windows AMD64 | windows/amd64   |
| Windows 386   | windows/386     |
| macOS AMD64   | darwin/amd64    |
| macOS ARM64   | darwin/arm64    |


### Tasks

- `make build` - Will build for all supported platforms
- `make build PLATFORMS=linux/amd64,darwin/arm64` - Will build for specific platforms
- `make update` - Will update the TagLib version in the `.version` file. After updating, you should build locally to 
   ensure everything is working, and then commit and push the changes.

### Release

To release a new version, just push a new tag in the format `vX.Y.Z-C`.  This will trigger a GitHub Actions workflow that 
will build and release the binaries for all supported platforms.

The version represents the TagLib version + a counter. For example, `v2.0.2-1` represents the first release based on 
TagLib 2.0.2.