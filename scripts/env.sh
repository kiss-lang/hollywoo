#! /bin/bash
# Usage: source env.sh

if [ -d "env" ]; then
	source env/bin/activate
	exit 0
fi

if [ -z "$(which ffmpeg)" ]; then
	echo "ffmpeg must be installed!"
fi

PYTHON=$(which python)
if [ -z "$PYTHON" ]; then
	PYTHON=$(which python3)
fi
if [ -z "$PYTHON" ]; then
	echo "No python!"
fi

$PYTHON -m venv env
source env/bin/activate

pip install -r requirements.txt

case "$OSTYPE" in
  msys*)    ;;
  cygwin*)  ;;
  *)        pip install -r requirements-unix.txt
esac

