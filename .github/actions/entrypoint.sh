#!/usr/bin/env sh

cd "${GITHUB_WORKSPACE}"

npm ci

npm run build
