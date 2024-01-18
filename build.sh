#!/bin/bash
set -eu

# Required environment variables
LIBVIPS_VERSION=${LIBVIPS_VERSION}
LIBVIPS_HASH=${LIBVIPS_HASH}
BUILD_TARGET=${BUILD_TARGET}

# Other params
DEBIAN_FRONTEND=noninteractive
DEBIAN_CURRENT_VERSION=$(cat /etc/debian_version | head -n 1)

function install_highway_debian12() {
  echo "#"
  echo "# Install highway for Debian 12"
  echo "#"

  cat << EOS >> /etc/apt/sources.list.d/debian.sources
# backport from trixie
Types: deb
URIs: http://deb.debian.org/debian
Suites: trixie
Components: main
Signed-By: /usr/share/keyrings/debian-archive-keyring.gpg
EOS

  cat << EOS >> /etc/apt/preferences
Package: *
Pin: release n=trixie
Pin-Priority: 100
EOS

  apt-get update
  apt-get install -y --no-install-recommends libhwy-dev -t trixie
}

function install_highway_debian13() {
  echo "#"
  echo "# Install highway for Debian 13"
  echo "#"

  apt-get install -y --no-install-recommends libhwy-dev -t trixie
}

function install_highway() {
  if [ $(echo "${DEBIAN_CURRENT_VERSION} < 13" | bc) = 1 ]; then
    install_highway_debian12
  else
    install_highway_debian13
  fi
}

function install_minimum_deps() {
  echo "#"
  echo "# Install minimum deps"
  echo "#"

  apt-get update

  apt-get install --no-install-recommends -y \
    curl bc git-core build-essential ca-certificates \
    meson pkg-config cmake libglib2.0-dev libexpat-dev libexif-dev

  install_highway
}

function build_vips() {
  echo "#"
  echo "# Build libvips"
  echo "#"

  install_additional_packages=$1
  build_opts=$2

  apt-get install --no-install-recommends -y ${install_additional_packages}

  mkdir -p /build/vips
  mkdir -p /vips

  pushd /build/vips
    curl -fsSLO https://github.com/libvips/libvips/releases/download/v${LIBVIPS_VERSION}/vips-${LIBVIPS_VERSION}.tar.xz

    hash=$(md5sum vips-${LIBVIPS_VERSION}.tar.xz | cut -d ' ' -f 1)
    if [ "${hash}" != "${LIBVIPS_HASH}" ]; then
      echo "## Invalid LIBVIPS_HASH !! EXIT ##" 1>&2
      echo "# expected: ${LIBVIPS_HASH}" 1>&2
      echo "# actual: ${hash}" 1>&2
      exit 1
    fi

    tar xf ./vips-${LIBVIPS_VERSION}.tar.xz
    rm vips-${LIBVIPS_VERSION}.tar.xz
  
    pushd vips-${LIBVIPS_VERSION}
      meson setup build --prefix /vips ${build_opts}
      pushd build
        meson compile
        meson install
      popd
    popd

    ldd /vips/lib/$(uname -m)-linux-gnu/libvips.so | perl -pe 's/^[ \t]+(.+?\.so).*$/\1/' >> vips-so-dep.txt
    ldd /vips/lib/$(uname -m)-linux-gnu/libvips-cpp.so | perl -pe 's/^[ \t]+(.+?\.so).*$/\1/' >> vips-cpp-so-dep.txt

  popd

  pushd /vips/lib/$(uname -m)-linux-gnu/
    dep_vips=$(cat /build/vips/vips-so-dep.txt /build/vips/vips-cpp-so-dep.txt | sort | uniq | grep -v -e 'ld-linux' -e 'linux-vdso' -e 'libvips.so')
    for dep in ${dep_vips}; do
      cp -a /lib/$(uname -m)-linux-gnu/${dep}* .
    done
  popd

  rm -rf /build
}

function build_vips_jpg_png() {
  echo "#"
  echo "# Build libvips"
  echo "# Features: JPEG, PNG"
  echo "#"

  install_additional_packages="libjpeg62-turbo-dev libopenjp2-7-dev libspng-dev"
  build_opts="--default-library shared -Dexamples=false -Dcplusplus=true -Dhighway=enabled -Dexif=enabled -Djpeg=enabled -Dopenjpeg=enabled -Dspng=enabled"

  install_minimum_deps

  build_vips "${install_additional_packages}" "${build_opts}"
}

case ${BUILD_TARGET} in
  "jpg_png")
    build_vips_jpg_png;;
  *)
    echo "Invalid build target" 1>&2
    exit 1;;
esac
