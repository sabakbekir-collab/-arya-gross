#!/usr/bin/env bash
# Root package.json "dev"/"start" scripts invoke this file.
# It was missing from the repo; this wraps the existing server.js runner,
# which already builds/starts the backend then starts the frontend dev server
# (see server.js — unchanged).
set -e
cd "$(dirname "$0")"
exec node server.js
