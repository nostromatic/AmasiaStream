#!/bin/bash

. ./config.sh

while true; do

  # Shuffle playlist
  shuf ${SCRIPT_DIR}/live_data/playlist.txt --output=${SCRIPT_DIR}/live_data/playlist.txt
  on_playlist_reshuffle
  
  while read f; do

    # Grabs ID3Tags
    current_artist=$(ffprobe -loglevel error -show_entries format_tags=artist -of default=noprint_wrappers=1:nokey=1 "${f}")
    current_trackname=$(ffprobe -loglevel error -show_entries format_tags=title -of default=noprint_wrappers=1:nokey=1 "${f}")
    current_album=$(ffprobe -loglevel error -show_entries format_tags=album -of default=noprint_wrappers=1:nokey=1 "${f}")

    # In case there is no tag in the TrackName, give the filename
    if [ -z "${current_trackname}" ]
    then
      # Remove ext in file name
      removed_ext=$(echo "${f}" | sed -e 's/.*\///' -e 's/\.mp3//')
      # And place it to display it
      current_trackname="${removed_ext}"
    fi

    # Execute custom function
    on_next_track "${current_artist}" "${current_trackname}" "${current_album}"

    # Play current song with mpg123
    mpg123 "${f}"

    # Force the sample rate to 44100
    #mpg123 -r 44100 "${f}"

    # Play a WAV file
    #aplay "${f}"

  done < ${SCRIPT_DIR}/live_data/playlist.txt
done
