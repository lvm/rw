#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""
rw.py - rotate wallpaper
License: BSD 3-Clause

Copyright (c) 2016, Mauro <mauro@sdf.org>
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are
met:

1. Redistributions of source code must retain the above copyright
notice, this list of conditions and the following disclaimer.

2. Redistributions in binary form must reproduce the above copyright
notice, this list of conditions and the following disclaimer in the
documentation and/or other materials provided with the distribution.

3. Neither the name of the copyright holder nor the names of its
contributors may be used to endorse or promote products derived from
this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
"AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
"""

__author__ = 'Mauro'
__version__ = '0.0.1'
__license__ = 'BSD3'


import os
import re
import glob
import time
import random
import argparse
import subprocess as sp


NOXINE = "--no-xinerama"
CENTER = "--bg-center"
FILL = "--bg-fill"
MAX = "--bg-max"
SCALE = "--bg-scale"
TILE = "--bg-tile"


def fy_random(src, just_one):
    "Sort a list (of images) using fisher yates"
    img_list = glob.glob(os.path.join(src, "*"))

    for i in xrange(len(img_list)):
        x = random.randrange(0, i+1)
        img_list_i = img_list[i]
        img_list[i] = img_list[x]
        img_list[x] = img_list_i

    return img_list[0] if just_one else img_list


def image(src):
    "if it's an image, return it. else give me a random (list of) image(s)"
    img = None
    if os.path.isfile(src):
        img = src
    elif os.path.isdir(src):
        img = fy_random(src, True)

    return img


def feh(feh_flags):
    "Executes feh to set a backgrond image"
    feh_flags, src = feh_flags

    sp.call(['feh'] + feh_flags + [image(src)])


def parse_time(time_interval):
    "Converts from '1h', '1m', or '1s' to seconds."
    interval = 3600
    ti_match = re.findall("(\d+)(h|m|s)", time_interval.lower())
    if ti_match:
        time_n, time_str = ti_match[0]

        try:
            int(time_n)
        except:
            time_n = 1

        if time_str == "s":
            interval = int(time_n)
        if time_str == "m":
            interval = int(time_n) * 60
        if time_str == "h":
            interval = int(time_n) * 3600

    return interval


def run_feh(time_interval, feh_flags):
    "While forever: run 'feh' and sleep a certain amount of time"
    feh(feh_flags)
    time.sleep(parse_time(time_interval))
    run_feh(time_interval, feh_flags)


if __name__ == '__main__':
        parser = argparse.ArgumentParser()
        parser.add_argument('-bg', '--background',
                            action="store_true",
                            help="""Use in conjunction with '--center' or
                            '--fill' or '--max' or '--scale' or '--tile'.
                            If no options are provided '--scale' will be
                            used by default.""")
        parser.add_argument('-c', '--center',
                            action="store_true",
                            help="""Center the file on the background.
                            If it is too small, it will be surrounded
                            by a black border""")
        parser.add_argument('-f', '--fill',
                            action="store_true",
                            help="""Like --bg-scale, but preserves aspect
                            ratio by zooming the image until it fits.
                            Either a horizontal or a vertical part of the
                            image will be cut off""")
        parser.add_argument('-m', '--max',
                            action="store_true",
                            help="""Like --bg-fill, but scale the image to the
                            maximum size that fits the screen with black
                            borders on one side.""")
        parser.add_argument('-s', '--scale',
                            action="store_true",
                            help="""Fit the file into the background without
                            repeating it, cutting off stuff or using borders.
                            But the aspect ratio is not preserved either""")
        parser.add_argument('-t', '--tile',
                            action="store_true",
                            help="""Tile (repeat) the image in case it is too
                            small for the screen""")
        parser.add_argument('-nx', '--no-xinerama',
                            action="store_true",
                            help="""Use --no-xinerama to treat the whole X
                            display as one screen when setting wallpapers.""")
        parser.add_argument('-i', '--image',
                            type=str,
                            required=False,
                            help="Use this background image. Optional.")
        parser.add_argument('-d', '--directory',
                            type=str,
                            required=False,
                            help="Use this background image. Optional.")
        parser.add_argument('-ti', '--time-interval',
                            type=str,
                            required=False,
                            help="""'1 hour' by default. Use '0s' for seconds,
                            '0m' for minutes, or '0h' for hours.""")

        args = parser.parse_args()

        feh_flags = []
        bg_source = None

        if args.background:
            if args.center:
                feh_flags.append(CENTER)
            elif args.fill:
                feh_flags.append(FILL)
            elif args.max:
                feh_flags.append(MAX)
            elif args.scale:
                feh_flags.append(SCALE)
            elif args.tile:
                feh_flags.append(TILE)
            else:
                feh_flags.append(SCALE)

            if args.no_xinerama:
                feh_flags.append(NOXINE)

            if args.directory:
                bg_source = args.directory
            elif args.image:
                bg_source = args.image

            if bg_source:
                run_feh(args.time_interval or "1h", [feh_flags, bg_source])

        else:
            print "{} -h".format(__file__)
