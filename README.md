# libvips-docker
docker build for libvips

# Supported variants

| Name | Base Image | Architecture | libvips build confg |
| :-- | :-- | :-- | :-- |
| trixie-jpg-png | debian:trixie-slim | amd64, arm64 | -Dexamples=false -Dcplusplus=true -Dhighway=enabled -Dexif=enabled -Djpeg=enabled -Dopenjpeg=enabled -Dspng=enabled |
| bookworm-jpg-png | debian:bookworm-slim | amd64, arm64 | -Dexamples=false -Dcplusplus=true -Dhighway=enabled -Dexif=enabled -Djpeg=enabled -Dopenjpeg=enabled -Dspng=enabled |

# Public images
Public images are available at: [https://github.com/orgs/CyberAgentAI/packages/container/package/libvips](https://github.com/orgs/CyberAgentAI/packages/container/package/libvips)

```bash
$ docker pull ghcr.io/cyberagentai/libvips:bookworm-jpg-png-v8.15.2
```

# Example Usage
```dockerfile
FROM ghcr.io/cyberagentai/libvips:bookworm-jpg-png-v8.15.2 as libvips
FROM debian:bookworm-slim

# Copy shared libs
# or you can copy /vips/lib/$(uname -m)-linux-gnu/* into /lib/$(uname -m)-linux-gnu/*
COPY --from=libvips /vips/ /vips/

# Copy the binary that requires libvips
COPY ./app /app

# Run the app
RUN LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:/vips/lib/$(uname -m)-linux-gnu /app
```

# Directory structure
```bash
$ tree /vips/
/vips/
|-- bin
|   |-- vips
|   |-- ... other cmd tools
|-- include
|   `-- vips
|       |-- vips.h
|       |-- ... other header files
|-- lib
|   `-- aarch64-linux-gnu
|       |-- libvips-cpp.so -> libvips-cpp.so.42
|       |-- libvips-cpp.so.42 -> libvips-cpp.so.42.17.1
|       |-- libvips-cpp.so.42.17.1
|       |-- libvips.so -> libvips.so.42
|       |-- libvips.so.42 -> libvips.so.42.17.1
|       |-- libvips.so.42.17.1
|       |-- libhwy.so -> libhwy.so.1
|       |-- libhwy.so.1 -> libhwy.so.1.0.7
|       |-- libhwy.so.1.0.7
|       |-- libjpeg.so -> libjpeg.so.62
|       |-- libjpeg.so.62 -> libjpeg.so.62.3.0
|       |-- libjpeg.so.62.3.0
|       |-- ... other shared libs required by libvips
|       `-- pkgconfig
|           |-- vips-cpp.pc
|           `-- vips.pc
`-- share
    `-- man
        `-- man1
            |-- vips.1
            |-- ... other man files
```
