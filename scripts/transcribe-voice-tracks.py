#! /usr/bin/env python
# pip install -r requirements.txt
usage = 'python transcribe-voice-track.py <fountain filename> <character> <wav filenames...>'

import util
from imports import *

import whisper
model = whisper.load_model("turbo")

import re
punc_list = ['.', '!', '?', ';', '--']
re_punc_list = [re.escape(punc) for punc in punc_list]

fountain_file = util.arg(1, usage)
character = util.arg(2, usage)
audio_filenames = util.args(3, usage)

lines = ""
with open(fountain_file, 'r') as f:
    lines = f.readlines()

# Put a list of dialog lines wanted into a FuzzyMap
fmap = util.FuzzyMap()
all_partials = {}
prev_found = {}

idx = 0
while idx < len(lines) - 1:
    line = lines[idx].strip()
    idx += 1

    # If it ends with punctuation, it's probably a screen line!
    for punc in punc_list:
        if line.endswith(punc):
            continue
    
    if len(line) == 0:
        continue

    # If it has lower-case letters, it's not a speech name
    tokens = line.split(" ")
    all_upper = True
    for token in tokens:
        if token.upper() != token:
            all_upper = False
            break

    # It's probably a speech name
    if all_upper:
        name = line
        if '(' in name:
            name = name[:name.find('(')].strip()

        line = lines[idx].strip()
        idx += 1

        # Skip wryly lines
        if line.startswith('('):
            line = line[line.find(')') + 1:].strip()
            if len(line) == 0:
                line = lines[idx].strip()
                idx += 1

        if character.upper() != name:
            continue

        # Put the line in the map
        fmap.put(line, [])
        # TODO this is experimental:
        # Put each part of the line in the map, so we can try to catch partial parts!
        partials = re.split('|'.join(re_punc_list), line)
        if len(partials) > 1:
            for part in partials:
                part = part.strip()
                fmap.put(part, [])
                all_partials[part] = True

map = fmap.map
print(map)

for audio_filename in audio_filenames:
    result = model.transcribe(audio_filename)
    print(result['segments'])
    for segment in result['segments']:
        match = fmap.best_match(segment['text'])
        if match in all_partials:
            print(f'PARTIAL FOUND: {match}')
        match_list = fmap.map[match]
        if match_list is not None:
            match_list.append({'start': segment['start'], 'end': segment['end']})

    to_dump = {}
    for key in list(map.keys()):
        if len(map[key]) != 0:
            to_dump[key] = map[key]
            prev_found[key] = True
            map[key] = []

    with open(f"{audio_filename}.{character}.json", "w") as f:
        json.dump(to_dump, f)

for key in map.keys():
    if key not in all_partials and len(map[key]) == 0 and key not in prev_found:
        print(f'NOT FOUND: {key}')
