#!/usr/bin/env python3
import sys
import os
import subprocess
from bs4 import BeautifulSoup
import argparse

mame_exe = 'mame'
rom_dir=None
chd_dir=None
sample_dir=None

rom_total = 0
rom_missing = 0

chd_total = 0
chd_missing = 0

sample_total = 0
sample_missing = 0

def get_mame_info(rom_name):
    try:
        outp = subprocess.check_output([mame_exe, rom_name, "-listxml"])
        soup = BeautifulSoup(outp, 'xml')
        return soup.machine
    except subprocess.CalledProcessError as err:
        pass

    return None

def get_rom_filename(mame_info):
    return mame_info['cloneof'] if mame_info.has_attr('cloneof') else mame_info['name']

def get_chd_filename(mame_info):
    return get_rom_filename(mame_info) if mame_info.disk else None

def get_sample_filename(mame_info):
    for ref in mame_info.find_all('device_ref'):
        if ref['name'] == 'samples':
            return get_rom_filename(mame_info)
    
    return None

def have_rom(rom_name):
    rom_zip = os.path.join(rom_dir, rom_name + '.zip')
    if os.path.exists(rom_zip):
        return rom_zip

    rom_7z = os.path.join(rom_dir, rom_name + '.7z')
    if os.path.exists(rom_7z):
        return rom_7z

    return None
    
def have_chd(chd_name):
    rom_chd = os.path.join(chd_dir, chd_name)
    if os.path.exists(rom_chd):
        return rom_chd

    return None

def have_sample(sample_name):
    sample_fn = os.path.join(sample_dir, sample_name + '.zip')
    if os.path.exists(sample_fn):
        return sample_fn

    sample_fn = os.path.join(sample_dir, sample_name + '.7z')
    if os.path.exists(sample_fn):
        return sample_fn

    return None

def check_list(fav_file_name):
    fav_file = open(fav_file_name, 'r')
    fav_lines = fav_file.readlines()
    for game_name in fav_lines:
        game_name = game_name.strip()
        check_game(game_name)

    # if copy_to and rom_file:
    #     print(f'cp \"{rom_file}\" \"{copy_to}\"')
    #     if chd_name != '' and chd_file:
    #         print(f'cp -r \"{chd_file}\" \"{copy_to}\"')

def check_game(game_name):
    global rom_total
    global rom_missing
    global chd_total
    global chd_missing
    global sample_total
    global sample_missing

    mame_info = get_mame_info(game_name)
    if not mame_info:
        print(f'XX {game_name}: ** bad file **')
        return

    # rom_name = mame_info['cloneof'] if mame_info.has_attr('cloneof') else game_name
    rom_filename = get_rom_filename(mame_info)
    # chd_name = mame_info.disk['name'] if mame_info.disk else ''
    chd_filename = get_chd_filename(mame_info)
    sample_filename = get_sample_filename(mame_info)

    manufacturer = mame_info.manufacturer.string if mame_info.manufacturer else ''
    year = mame_info.year.string if mame_info.year else ''
    description = mame_info.description.string if mame_info.description else ''

    rom_total += 1
    rom_file = have_rom(rom_filename)
    if rom_file:
        print(f'√', end='')
    else:
        rom_missing += 1
        print(f'X', end='')

    if chd_filename:
        chd_total += 1
        chd_file = have_chd(chd_filename)
        if chd_file:
            print('c', end='')
        else:
            chd_missing += 1
            print('x', end='')
    else:
        chd_filename = ''
        print(' ', end='')

    if sample_filename:
        sample_total += 1
        sample_file = have_sample(sample_filename)
        if sample_file:
            print('s', end='')
        else:
            sample_missing += 1
            print('x', end='')
    else:
        sample_filename = ''
        print(' ', end='')

    # game_name : actual rom (parent) : chd : year : manufacturer : description
    print(f' {game_name}:{rom_filename}:{chd_filename}:{sample_filename}:"{manufacturer}":{year}:"{description}"', flush=True)

ROM_DIR='/Volumes/MAME/MAME 0.177 ROMs'
FAV_FILE_NAME='mame-all-killer.txt'

parser = argparse.ArgumentParser(description='Find ROMs for MAME Favorites')
parser.add_argument('arg_list', type=str, nargs='+',
                    help='a favorites file')
parser.add_argument('-r', '--rom_dir', default='./roms', help='ROM directory (default: ./roms)')
parser.add_argument('-s', '--sample_dir', default='./samples', help='Sound Samples directory (default: ./samples)')
parser.add_argument('-c', '--chd_dir', help='CHD directory (default: same as rom_dir)')
parser.add_argument('-m', '--mame', default='mame', help='MAME Executable (default: mame)')
parser.add_argument('--copy_to', default=None, help='Destination to copy to (default: None, don\'t copy)')
parser.add_argument('-g', '--games', action='store_true', help='arguments are game names not favorites files')

args = parser.parse_args()
mame_exe = args.mame

rom_dir = args.rom_dir
chd_dir = args.chd_dir if args.chd_dir else args.rom_dir
sample_dir = args.sample_dir if args.sample_dir else None

if args.games:
    for game_name in args.arg_list:
        check_game(game_name)
else:
    for fav_file in args.arg_list:
        check_list(fav_file)

print(f'ROMs: {rom_total-rom_missing}/{rom_total} missing {rom_missing}')
print(f'CHDs: {chd_total-chd_missing}/{chd_total} missing {chd_missing}')
print(f'Samples: {sample_total-sample_missing}/{sample_total} missing {sample_missing}')


