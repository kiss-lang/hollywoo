#! /bin/bash
# Usage: source env.sh

source_and_alias() {
	source env/bin/activate
	SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
	alias transcribe-voice-tracks="python ${SCRIPT_DIR}/transcribe-voice-tracks.py"
	alias amplify-voice-tracks="python ${SCRIPT_DIR}/amplify-voice-tracks.py"
	alias combine-voice-tracks="python ${SCRIPT_DIR}/combine-voice-tracks.py"
	alias cut-voice-track="python ${SCRIPT_DIR}/cut-voice-track.py"
	alias join-partial-lines="python ${SCRIPT_DIR}/join-partial-lines.py"
}

if [ -d "env" ]; then
	source_and_alias
else

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
	source_and_alias

	pip install -r requirements.txt

	case "$OSTYPE" in
	msys*)    ;;
	cygwin*)  ;;
	*)        pip install -r requirements-unix.txt
	esac

fi