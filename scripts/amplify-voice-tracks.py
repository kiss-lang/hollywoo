import glob

#! /usr/bin/env python
# pip install -r requirements.txt
usage = 'python amplify-voice-tracks.py <cut json> <?wav filename>'

from imports import *
import util
from time import sleep
import string
from os.path import exists
from os import system
system('color')

json_filename = util.arg(1, usage)

filenames=list(glob.glob(json_filename)) if '*' in json_filename else [json_filename]

for json_filename in filenames:
    if json_filename.endswith("-amplified.json"):
        continue

    print(json_filename)

    default_wav_name = json_filename.replace('.json', '.wav')
    wav_filename = util.arg(2, usage, default_wav_name)

    cutter = util.AudioCutter(wav_filename, json_filename)

    new_wav = wav_filename.replace(".wav", f"-amplified.wav")

    def save():
        cutter.save(new_wav)

    def process_chunk(audio_guess, timestamp):
        audio, length = cutter.audio_and_length(timestamp['start'], timestamp['end'])
        
        audio_left = [channels[0] for channels in audio]
        audio_right = [channels[1] for channels in audio]

        def max(l):
            m = 0
            m_abs = 0
            for v in l:
                if abs(v) > m_abs:
                    m = v
                    m_abs = abs(v)
            return m
        ml = max(audio_left)
        mr = max(audio_right)

        MAX = 32767

        can_multiply = abs(min(MAX/ml, MAX/mr))
        print(can_multiply)
        if can_multiply < 1:
            can_multiply = 1
        cutter.take_audio(audio_guess, {'start': cutter.current_sec, 'end': cutter.current_sec + length}, timestamp['start'], timestamp['end'], can_multiply)    

    cutter.process_audio(process_chunk, new_wav, False)
    save()