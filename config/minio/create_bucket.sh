#!/usr/bin/env bash

mc alias set local http://localhost:9000 "${MINIO_ACCESS_KEY_ID:-minio}" "${MINIO_ROOT_PASSWORD}"
mc mb -p local/"${MINIO_DEFAULT_BUCKET}"