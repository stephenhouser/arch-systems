# Mini-MAME

Configuration and setup for a "retro arcade computer", other wise known as _Kids MAME 2_ or now _Mini-MAME_. This is a rebuild of my original [Kids MAME 1](https://stephenhouser.com/kids_mame_1/) which hosted Arcade games and a selection of PC (Windows) games for my children.

## Key Components

* [Attract Mode](http://attractmode.org) as the graphical front-end or game chooser.
* [RetroArch](https://retroarch.com) and [LibRETRO](https://www.libretro.com) for running a number of the games with control configurations and features.
* X Windows as `wine` and `attract mode` need X to do their thing
* [Wine](https://winehq.org) to enable running Microsoft Windows based games.
* [Daphne](https://daphne-emu.com) for running Laser Disc based games (Space Ace)
* [Arch Linux](https://archlinux.org) as the base operating system.

## Directory Structure

```
/home/mame
    .attract            -- attract mode configuration
        attract.cfg     -- main config for attract mode
        emulators       -- config files for each emulator, how to launch
            *.cfg
        romlists        -- lists of games to display
            *.txt       -- semi-colon separated database for each display
            *.tag       -- flagged favorites for each display

        layout          -- extra downloaded layouts
        modules         -- extra downloaded modules

    .config/retroarch   -- RetroArch (libretro) configuration
        retroarch.cfg   -- main config for retroarch

        config          -- libretro configuration for each core (*.opt)
            MAME        -- for Current MAME (v0.227)
            MAME2000    -- for MAME v0.37b5
            scummvm     -- for ScummVM
        system          -- Where cores store their own internal data/options
            mame2000    -- MAME 2000 (0.37b5) option files
            mame2003    -- MAME 2003 (0.78+) option files
            scummvm.ini -- ScummVM config (list of games and how to launch)

    daphne1.0           -- see daphne below, v1.0 files
    mame0.37b5          -- see mame below, 0.37b5 files
    mame0.78+           -- see mame below, 0.78+ files
    mame0.227           -- see mame below, 0.227 files
    scummvm2.2          -- see scummvm below, 2.2 files
    ...                 -- other game engines and game files

    shared              -- shared media across game versions
        mame            -- for mame
            snap            -- game play snapshot; video or static (front-end)
            artwork         -- other game artwork
            flyer           -- game flyer (front-end) 
            marquee         -- game cab marquee
            wheel           -- game wheel image (front-end)
        daphne          -- for daphne
            ...
        scummvm         -- fos scummvm
            ...

    daphne              -- linked to current daphne
        roms            -- game roms   
        framefile       -- laserdisc movies and frame file configs
            game        -- movies and control for game
            game/game.txt -- control file for game
        ...             -- links to $/shared/daphne/... media

    mame                -- linked to current mame
        roms            -- roms and CHDs
        samples         -- sound samples (in-game)
        nvram           -- stored non-volitaile
        ...             -- links to $/shared/mame/... media

    scummvm             -- linked to current scummvm
        games           -- game files
            game.scummvm    -- game launch file needed by libretro
        ...             -- links to $/shared/scummvm/... media


## Graphical Front-End

_Attract Mode_ is an attractive front-end that is small, easy to navigate, and only loosely documented. Which makes it perfect for my use. Oh, it's cross platform as well so I can use it on Linux.

## Running Gamess

_RetroArch_ and _LibRETRO_ make running most arcade games very simple. While _RetroArch_ has a complete front-end, I find it unsuitable to a traditional arcade style machine with joystick and keys. So, I don't use that part. The part where it can run older MAME ROMs (0.37b5) and where it provides game recording, pause, rewind, and fastforward are really the features being used.

_LibRETRO_ refers to the game engines that it can run as _cores_. The following are _cores_ I've installed here.

* MAME 2000 -- runs MAME 0.37b5 ROMs (includes 95% of  of my favorite classic American arcade games)
* MAME 2003 -- runs MAME 0.78 ROMs (includes more of the classic American arcade experience)
* MAME 2003 Plus -- runs MAME 0.78+ ROMS (includes 99% of my favorite classic American arcade)
* ScummVM -- runs a number of the "Kids Games" from Humougous Entertainment.

### Other Games

The `wine-iso` script mounts and executes a number of other _Windows_ based games my kids lived to play. It uses `fuseiso` and `wine` to accomplish this.

## Operating System

_Arch Linux_ provides a lightweight configurable base without a lot of extra cruft that I don't want on a mostly-disconnected computer. No data collection, Internet updating when you don't want it, or strange _user analytics_ going on in the background.

## Setting Up

1. _Arch Linux_ should already be installed. Check the [Arch Bootstrap](https://github.com/stephenhouser/arch-bootstrap) project to get that done.

2. Either create the `mame` or `arcade` user by hand or use the included `bootstrap.sh` to do that.

3. As the `mame` or `arcade` user, run `bootstrap.sh` to install and configure most of the stuff needed. Perferably do this _at the console_ as some of the steps might open up a window and require attention. All this stuff is after all designed to be run at the console.

4. Run `startx /usr/bin/wine progman` and `startx /usr/bin/winecfg` get wine to build it's directory structure

Scripts for setting up mini-mame arcade machine with Arch Linux

* `bootstrap.sh` to create the `mame` account if you don't have it already
* `bootstrap.sh` to pull the repo and run `setup-mini-mame.sh` which installs everything



## Devices

        Ultimarc Opti-PAC Trackball/Spinner
        Cypress I-PAC Arcade Control Interface

## Keys

I want libRetro games to match typical MAME controls, which matches my I-PAC

https://retropie.org.uk/docs/RetroArch/

```
                                -- Defender keys (from MAME)
input_player1_start = "num1"    -- player 1 start
input_player1_select = "num5"   -- player 1 coin

input_player1_b = "ctrl"	    -- b1 fire
input_player1_x = "alt"		    -- b2 thrust
input_player1_a = "space"	    -- b3 smart bomb
input_player1_y = "shift"	    -- b4 hyperspace
input_player1_r = "z"		    -- b5 reverse
input_player1_l = "x"		    -- b6

input_player1_left = "left"
input_player1_right = "right"
input_player1_up = "up"
input_player1_down = "down"
```