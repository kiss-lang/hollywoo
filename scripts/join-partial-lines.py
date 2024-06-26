#! /usr/bin/env python
# pip install -r requirements.txt
usage = 'python join-partial-lines.py <cut json> <?wav filename>'

from imports import *
import util
from time import sleep
import string
from os.path import exists
from os import system
system('color')

json_filename = util.arg(1, usage)
default_wav_name = json_filename.replace('.json', '.wav')
wav_filename = util.arg(2, usage, default_wav_name)

cutter = util.AudioCutter(wav_filename, json_filename)

def new_wav_filename():
    suffix = "0"
    new_wav = wav_filename.replace(".wav", f"-joined{suffix}.wav")
    while exists(new_wav):
        new_suffix = str(int(suffix) + 1)
        new_wav = new_wav.replace(f"-joined{suffix}.wav", f"-joined{new_suffix}.wav")
        suffix = new_suffix
    return new_wav


def save():
    cutter.save_and_quit(new_wav_filename())

joining_with_guess = ""
joining_with = None
joining_reverse = False
delay_time = 0.5

def process_chunk(audio_guess, timestamp):
    global joining_with_guess
    global joining_with
    global joining_reverse
    global delay_time
    preposition = 'into' if joining_reverse else 'onto'
    if joining_with != None:
        print(f'Joining {preposition}: \033[92m{joining_with_guess}\033[0m')
    print('\033[31m' + audio_guess + '\033[0m')
    js = 'j' if joining_with != None else 'j/J'
    usage = f'u/d/{js}/p/t/f/n/q/h'
    print(usage)
    if 'alts' in timestamp:
        print('join-partial-lines cannot join alts. skipping')
        length = timestamp['end'] - timestamp['start']
        adjusted = {'start': cutter.current_sec, 'end': cutter.current_sec + length, 'alts': []}
        cutter.take_audio(audio_guess, adjusted, timestamp['start'], timestamp['end'])
        for alt in timestamp['alts']:
            length = alt['end'] - alt['start']
            adjusted['alts'].append({'start': cutter.current_sec, 'end': cutter.current_sec + length})
            cutter.take_audio(audio_guess, adjusted, alt['start'], alt['end'])
        return

    while True:
        choice = getch()
        if choice == 'u':
            length = timestamp['end'] - timestamp['start']
            adjusted = {'start': cutter.current_sec, 'end': cutter.current_sec + length}
            cutter.take_audio(audio_guess, adjusted, timestamp['start'], timestamp['end'])
            break
        elif choice == 'd':
            break
        elif choice == 'J':
            if joining_with == None:
                joining_with_guess = audio_guess
                joining_with = timestamp
                joining_reverse = True
                break
        elif choice == 'j':
            if joining_with == None:
                joining_with_guess = audio_guess
                joining_with = timestamp
                joining_reverse = False
            else:
                # do the join
                first_guess = audio_guess if joining_reverse else joining_with_guess
                second_guess = joining_with_guess if joining_reverse else audio_guess
                joined_guess = first_guess + " " + second_guess

                full_timestamp = {
                    'start': cutter.current_sec,
                    'end': cutter.current_sec + (joining_with['end'] - joining_with['start']) + delay_time + (timestamp['end'] - timestamp['start'])
                }

                first_timestamp = timestamp if joining_reverse else joining_with
                second_timestamp = joining_with if joining_reverse else timestamp

                cutter.take_audio(joined_guess, full_timestamp, first_timestamp['start'], first_timestamp['end'])
                cutter.add_silence(delay_time)
                cutter.take_audio(joined_guess, full_timestamp, second_timestamp['start'], second_timestamp['end'])
                # clear the joining part
                joining_with_guess = ""
                joining_with = None
            break
        elif choice == 'f':
            cutter.search()
            break
        elif choice == 'n':
            cutter.repeat_search()
            break
        elif choice == 'q':
            save()
        elif choice == 'p':
            if joining_with == None:
                cutter.play_audio(timestamp['start'], timestamp['end'])
            else:
                first_timestamp = timestamp if joining_reverse else joining_with
                second_timestamp = joining_with if joining_reverse else timestamp

                cutter.play_audio(first_timestamp['start'], first_timestamp['end'])
                sleep(first_timestamp['end'] - first_timestamp['start'])
                sleep(delay_time)
                cutter.play_audio(second_timestamp['start'], second_timestamp['end'])
        elif choice == 't':
            delay_time = float(input("seconds to pause between parts? "))
            print(usage)

        elif choice == 'h':
            print('u - use this line as-is')
            if joining_with != None:
                print(f'j - join this line {preposition} \033[92m{joining_with_guess}\033[0m')
            else:
                print('j - join another line onto this line')
                print('J - join another line into this line')
            print(f't - set the delay time (currently {delay_time}')
            as_if_joined = ' as if joined' if joining_with != None else ''
            print(f'p - play this line{as_if_joined}')
            print('f - search ahead for a word or phrase')
            print('n - repeat a search.')
            print('d - discard this line')
            print('q - save and quit')

cutter.process_audio(process_chunk, new_wav_filename())