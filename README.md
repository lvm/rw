# rw

Very simple script to rotate wallpaper images.

## rw.py

```
usage: rw.py [-h] [-bg] [-c] [-f] [-m] [-s] [-t] [-nx] [-i IMAGE]
             [-d DIRECTORY] [-ti TIME_INTERVAL]

optional arguments:
  -h, --help            show this help message and exit
  -bg, --background     Use in conjunction with '--center' or '--fill' or '--
                        max' or '--scale' or '--tile'. If no options are
                        provided '--scale' will be used by default.
  -c, --center          Center the file on the background. If it is too small,
                        it will be surrounded by a black border
  -f, --fill            Like --bg-scale, but preserves aspect ratio by zooming
                        the image until it fits. Either a horizontal or a
                        vertical part of the image will be cut off
  -m, --max             Like --bg-fill, but scale the image to the maximum
                        size that fits the screen with black borders on one
                        side.
  -s, --scale           Fit the file into the background without repeating it,
                        cutting off stuff or using borders. But the aspect
                        ratio is not preserved either
  -t, --tile            Tile (repeat) the image in case it is too small for
                        the screen
  -nx, --no-xinerama    Use --no-xinerama to treat the whole X display as one
                        screen when setting wallpapers.
  -i IMAGE, --image IMAGE
                        Use this background image. Optional.
  -d DIRECTORY, --directory DIRECTORY
                        Use this background image. Optional.
  -ti TIME_INTERVAL, --time-interval TIME_INTERVAL
                        '1 hour' by default. Use '0s' for seconds, '0m' for
                        minutes, or '0h' for hours.
```

## rw.rb

```
Usage: rw.rb [options]
    -b, --background
        Use in conjunction with '--center' or
        '--fill' or '--max' or '--scale' or '--tile'.
        If no options are provided '--scale' will be
        used by default.
    -c, --center
        Center the file on the background.
        If it is too small, it will be surrounded
        by a black border
    -f, --fill
        Like --bg-scale, but preserves aspect
        ratio by zooming the image until it fits.
        Either a horizontal or a vertical part of the
        image will be cut off
    -m, --max
        Like --bg-fill, but scale the image to the
        maximum size that fits the screen with black
        borders on one side.
        --tile
        Tile (repeat) the image in case it is too
        small for the screen
    -s, --scale
        Fit the file into the background without
        repeating it, cutting off stuff or using borders.
        But the aspect ratio is not preserved either
    -n, --noxinerama
        Use --noxinerama to treat the whole X
        display as one screen when setting wallpapers.
    -d, --directory=DIR
        Use this background image. Optional.
    -i, --image=IMG
        Use this background image. Optional.
    -t, --timeinterval=TI
        '1 hour' by default. Use '0s' for seconds,
        '0m' for minutes, or '0h' for hours.
    -h, --help
        Displays Help
```

# LICENSE

See [LICENSE](LICENSE)
