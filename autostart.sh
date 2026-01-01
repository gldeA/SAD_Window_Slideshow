#!/bin/bash

cd "/home/nonroot/media"

/home/nonroot/crop_preprocessing.sh &
sleep 2 # Allow the converter to start

shopt -s globstar # Allow the use of **/* syntax, which searches all subfolders
shopt -s nullglob # Prevents **/* from being literally interpreted if no files are found

mpv --vo=drm --fs --loop-playlist --shuffle --no-osc --no-osd-bar --really-quiet --image-display-duration=120 --cache=yes --demuxer-max-bytes=50M **/*_processed.*
