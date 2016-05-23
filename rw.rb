#!/usr/bin/env ruby
"""
rw.rb - rotate wallpaper
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
__version__ = '0.0.23rb'
__license__ = 'BSD3'


require 'tmpdir'
require 'optparse'
require 'shellwords'
require 'subprocess'


__file = File.basename("#{$0}")

NOXINE = "--no-xinerama"
CENTER = "--bg-center"
FILL = "--bg-fill"
MAX = "--bg-max"
SCALE = "--bg-scale"
TILE = "--bg-tile"

LOCKFILE = File.join(Dir.tmpdir(),
                     "rw-rb-%{uid}.lock" % {:uid => Process.uid})


def sp_call(cmd)
  begin
    Subprocess.call(cmd.shellsplit)
  rescue Subprocess::NonZeroExit => e
    puts e.message
  end
end


def fy_random(src, just_one=false)
  "Sort a list (of images) using fisher yates"
  img_dir = File.join src, "*"
  img_list = Dir.glob img_dir

  for i in 1..img_list.length
    x = rand 0..i+1
    img_list_i = img_list[i]
    img_list[i] = img_list[x]
    img_list[x] = img_list_i
  end

  if just_one
    img_list = img_list[0]
  end

  return img_list
end


def image(src)
  "if it's an image, return it. else give me a random (list of) image(s)"
  img = ""

  if File.file? src
    img = src
  elsif File.directory? src
    img = fy_random src, true
  end

  return img
end


def parse_time(time_interval)
  "Converts from '1h', '1m', or '1s' to seconds."
  interval = 3600
  ti_match = /(\d+)(h|m|s)/.match time_interval.downcase

  if ti_match
    time_n = ti_match[1]
    time_str = ti_match[2]

    if not time_n.to_i
      time_n = 1
    else
      time_n = time_n.to_i
    end

    if time_str == "s"
      interval = time_n
    elsif time_str == "m"
      interval = time_n * 60
    elsif time_str == "h"
      interval = time_n * 3600

    end
  end

  return interval
end


def feh(feh_flags)
  "Executes feh to set a backgrond image"
  feh_flags, src = feh_flags

  sp_call("feh " << feh_flags.join(" ") << " " << image(src))
end


def run_feh(time_interval, feh_flags)
  "While forever: run 'feh' and sleep a certain amount of time"
  feh feh_flags
  sleep parse_time(time_interval)
  run_feh time_interval, feh_flags
end


def lock()
  lck = File.open(LOCKFILE, File::RDWR|File::CREAT, 0644)
  lck.flock( File::LOCK_NB | File::LOCK_EX )
  return lck
end


def release(lck)
  lck.flock(File::LOCK_UN)
  File.delete(LOCKFILE)
end


options = {:background => nil,
           :center => nil,
           :fill => nil,
           :max => nil,
           :scale => nil,
           :tile => nil,
           :no_xinerama => nil,
           :image => "",
           :directory => "",
           :time_interval => "1h"
          }
OptionParser.new do |opts|
  opts.banner = "Usage: %{file} [options]" % {:file => __file}

  bg_help = %{
        Use in conjunction with '--center' or
        '--fill' or '--max' or '--scale' or '--tile'.
        If no options are provided '--scale' will be
        used by default.
}
  center_help = %{
        Center the file on the background.
        If it is too small, it will be surrounded
        by a black border
}
  fill_help = %{
        Like --bg-scale, but preserves aspect
        ratio by zooming the image until it fits.
        Either a horizontal or a vertical part of the
        image will be cut off
}
  max_help = %{
        Like --bg-fill, but scale the image to the
        maximum size that fits the screen with black
        borders on one side.
}
  scale_help = %{
        Fit the file into the background without
        repeating it, cutting off stuff or using borders.
        But the aspect ratio is not preserved either
}
  tile_help = %{
        Tile (repeat) the image in case it is too
        small for the screen
}
  no_xine_help = %{
        Use --noxinerama to treat the whole X
        display as one screen when setting wallpapers.
}
  image_help = %{
        Use this background image. Optional.
}
  dir_help =  %{
        Use this background image. Optional.
}
  ti_help =  %{
        '1 hour' by default. Use '0s' for seconds,
        '0m' for minutes, or '0h' for hours.
}

  opts.on("-b", "--background", bg_help) do
    options[:background] = true
  end
  opts.on("-c", "--center", center_help) do
    options[:center] = true
  end
  opts.on("-f", "--fill", fill_help) do
    options[:fill] = true
  end
  opts.on("-m", "--max", max_help) do
    options[:max] = true
  end
  opts.on("-t", "--tile", tile_help) do
    options[:tile] = true
  end
  opts.on("-s", "--scale", scale_help) do
    options[:scale] = true
  end
  opts.on("-n", "--noxinerama", no_xine_help) do
    options[:no_xinerama] = true
  end
  opts.on("-dD", "--directory=DIR", dir_help) do |v|
    options[:directory] = v
  end
  opts.on("-iI", "--image=IMG", image_help) do |v|
    options[:image] = v
  end
  opts.on("-tT", "--timeinterval=TI", ti_help) do |v|
    options[:time_interval] = v
  end

  opts.on('-h', '--help', 'Displays Help') do
    puts opts
    exit
  end
end.parse!

feh_flags = []
bg_source = nil
lck = nil

if options[:background]
  if options[:center]
    feh_flags << CENTER
  elsif options[:fill]
    feh_flags << FILL
  elsif options[:max]
    feh_flags << MAX
  elsif options[:scale]
    feh_flags << SCALE
  elsif options[:tile]
    feh_flags << TILE
  elsif options[:tile]
      feh_flags << TILE
  end

  if options[:no_xinerama]
    feh_flags << TILE
  end

  if options[:directory]
    bg_source = options[:directory]
  elsif options[:image]
    bg_source = options[:image]
  end

  if bg_source
    lck = lock()
    begin
      run_feh options[:time_interval], [feh_flags, bg_source]
    rescue SystemCallError
      $stderr.print "{file} is already running!" % {:file => __file}
      exit 1
    ensure
      if lck
        release(lck)
      end
    end
  end
end
