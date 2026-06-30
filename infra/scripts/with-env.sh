#!/usr/bin/env sh
set -eu

env_files=""

if [ -f .env.local ]; then
  env_files="$env_files -e .env.local"
fi

env_files="$env_files -e .env.development"

dotenv_bin="${DOTENV_BIN:-./node_modules/.bin/dotenv}"

if [ ! -x "$dotenv_bin" ]; then
  dotenv_bin="dotenv"
fi

# shellcheck disable=SC2086
exec "$dotenv_bin" $env_files -- "$@"
