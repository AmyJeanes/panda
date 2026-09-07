#!/usr/bin/env bash
set -e

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null && pwd)"
cd $DIR

PLATFORM=$(uname -s)
VENV_BIN=bin

echo "installing dependencies"
if [[ $PLATFORM == "Darwin" ]]; then
  # pass
  :
elif [[ $PLATFORM == "Linux" ]]; then
  # for AGNOS since we clear the apt lists
  if [[ ! -d /"var/lib/apt/" ]]; then
    sudo apt update
  fi

  sudo apt-get install -y --no-install-recommends \
    curl ca-certificates gcc git \
    python3-dev
elif [[ $PLATFORM == MINGW* || $PLATFORM == MSYS* ]]; then
  # an MSYS2 CLANG64 shell: a native Python's venv keeps its scripts in Scripts/, and it must not be the
  # MSYS2 toolchain's own python, whose wheels are incompatible
  VENV_BIN=Scripts
  export UV_PYTHON="${UV_PYTHON:-3.12}"
else
  echo "WARNING: unsupported platform. skipping apt/brew install."
fi

if ! command -v uv &>/dev/null; then
  echo "'uv' is not installed. Installing 'uv'..."
  curl -LsSf https://astral.sh/uv/install.sh | sh

  # doesn't require sourcing on all platforms
  set +e
  source $HOME/.local/bin/env
  set -e
fi

export UV_PROJECT_ENVIRONMENT="$DIR/.venv"
uv sync --all-extras --upgrade
source "$DIR/.venv/$VENV_BIN/activate"
