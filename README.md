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
$ docker pull ghcr.io/cyberagentai/libvips:bookworm-jpg-png
```

# Example Usage
TODO
