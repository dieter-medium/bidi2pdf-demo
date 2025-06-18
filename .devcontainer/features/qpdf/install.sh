#!/usr/bin/env bash
set -euo pipefail

. /etc/os-release

SUPPORTED_VERSION_CODENAMES="bookworm"
if [[ " ${SUPPORTED_VERSION_CODENAMES} " != *" ${VERSION_CODENAME} "* ]]; then
    >&2 echo "✖ Unsupported distribution codename '${VERSION_CODENAME}'."
    >&2 echo "  Supported: ${SUPPORTED_VERSION_CODENAMES}"
    exit 1
fi

apt-get update -qq                       # quiet, we only need metadata
CANDIDATE_VERSION="$(apt-cache policy qpdf | awk '/Candidate:/ {print $2}')"

if [[ -n "${CANDIDATE_VERSION}" ]] && dpkg --compare-versions "${CANDIDATE_VERSION}" ge 12~; then
    echo "✔ Found qpdf ${CANDIDATE_VERSION} in default repositories – installing normally."
    apt-get -y --no-install-recommends install qpdf libqpdf-dev
else
   echo "ℹ qpdf ≥ 12 not in default repositories – installing from source."
   QPDF_VERSION="12.2.0"

   apt install -y --no-install-recommends build-essential cmake pkg-config  libjpeg62-turbo-dev zlib1g-dev libpng-dev libssl-dev cmake
   cd /tmp
   mkdir -p qpdf
   cd qpdf
   curl -OL https://github.com/qpdf/qpdf/archive/refs/tags/v${QPDF_VERSION}.tar.gz
   tar -xzf v${QPDF_VERSION}.tar.gz --strip-components=1
   cmake -S . -B build -DCMAKE_BUILD_TYPE=RelWithDebInfo
   cmake --build build --parallel 2 --target libqpdf libqpdf_static
   cmake --install build --component lib
   cmake --install build --component dev
   rm -rf /tmp/qpdf
fi

apt-get clean

rm -rf /var/lib/apt/lists/*