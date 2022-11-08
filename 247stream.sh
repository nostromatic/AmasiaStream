#!/bin/bash

# Sourcing config.sh file for vars and functions
. ./config.sh

# To use with a video in the background, remove the streamlink pipe part in the ffmpeg command, fill the ${BACKGROUND} variable, and replace the first "-i" line with this :
# Example:
# /usr/bin/ffmpeg -loglevel warning -re -threads "${THREAD_COUNT}" \
# -stream_loop -1 -i ${BACKGROUND} \
# [...]

# To use a static image, fill the ${BACKGROUND} variable, and replace first lines with this example:
# /usr/bin/ffmpeg -loglevel warning -re -threads "${THREAD_COUNT}" \
# -framerate 30 -loop 1 -f image2 -i ${BACKGROUND} \
# [...]

while true :
do
  # If $RTSPLINK2 is configured, the stream is splitted in two outputs, and every output is streamed to the provider (careful with your CPU and bandwidth)
  if [ -z "${RTSPLINK2}" ]
  then
  # Launch the stream to the unique URL
   /usr/bin/ffmpeg -loglevel warning -re -threads "${THREAD_COUNT}" \
      -stream_loop -1 -i ${BACKGROUND} \
      -f alsa -acodec pcm_s32le -ac 2 -thread_queue_size 2048 -i hw:Loopback,1,0 \
      -loop 1 -f image2 -i "${LOGOIMAGE}" \
      -filter_complex \
      "[0:v] drawtext=fontsize=12:fontfile=${SCRIPT_DIR}/fonts/unispace/unispace.ttf:textfile=${SCRIPT_DIR}/live_data/now_playing.txt:x=10:y=h-th-50:reload=1:fontcolor=white [vtxt1];
      [vtxt1] drawtext=fontsize=12:fontfile=${SCRIPT_DIR}/fonts/unispace/unispace.ttf:textfile=${SCRIPT_DIR}/live_data/banner.txt:x=10:y=10:reload=1:fontcolor=white [vtxt2];
      [vtxt2] drawtext=fontsize=10:fontfile=FreeSerif.ttf:textfile=${SCRIPT_DIR}/live_data/images_credit.txt:x=w-tw-5:y=h-th-5:reload=1:fontcolor=Gray [vtxt3];
      [vtxt3][2:v] overlay=x=W-w-10:y=20 [v];
      [1:a] showwaves=s=1920x60:mode=line:colors=Gray [vf];
      [v][vf] overlay=x=1:y=main_h-overlay_h-10 [fin]" \
      -map "[fin]" -map "1:a" \
      -codec:v libx264 -pix_fmt yuv420p -preset veryfast -b:v 8000k -r 30.0 -g 60.0 \
      -codec:a aac -b:a 128k -ar 44100 -maxrate 4000k -bufsize 8000k -shortest -filter:a "volume=${VOLUME}" \
      -f flv -drop_pkts_on_overflow 1 -attempt_recovery 1 -recovery_wait_time 1 -rtmp_buffer 6000 "${RTSPLINK1}"

  else
    # Launch the stream to the both URLs
    streamlink --ringbuffer-size 64M -O http://ustream.tv/channel/iss-hdev-payload best | /usr/bin/ffmpeg -loglevel warning -re -threads "${THREAD_COUNT}" \
      -i - \
      -f alsa -acodec pcm_s32le -ac 2 -thread_queue_size 2048 -i hw:Loopback,1,0 \
      -loop 1 -f image2 -i "${LOGOIMAGE}" \
      -filter_complex \
      "[0:v] drawtext=fontsize=18:fontfile=${SCRIPT_DIR}/fonts/unispace/unispace.ttf:textfile=${SCRIPT_DIR}/live_data/now_playing.txt:x=10:y=h-th-50:reload=1:fontcolor=white [vtxt1];
      [vtxt1] drawtext=fontsize=18:fontfile=${SCRIPT_DIR}/fonts/unispace/unispace.ttf:textfile=${SCRIPT_DIR}/live_data/banner.txt:x=10:y=10:reload=1:fontcolor=white [vtxt2];
      [vtxt2] drawtext=fontsize=10:fontfile=FreeSerif.ttf:textfile=${SCRIPT_DIR}/live_data/images_credit.txt:x=w-tw-5:y=h-th-5:reload=1:fontcolor=Gray [vtxt3];
      [vtxt3][2:v] overlay=x=W-w-10:y=20 [v];
      [1:a] showwaves=s=1920x60:mode=line:colors=Gray [vf];
      [v][vf] overlay=x=1:y=main_h-overlay_h-10 [fin];
      [fin] split=2[out1][out2]" \
      -map "[out1]" -map "1:a" \
      -codec:v libx264 -pix_fmt yuv420p -preset veryfast -b:v 8000k -r 30.0 -g 60.0 \
      -codec:a aac -b:a 128k -ar 44100 -maxrate 4000k -bufsize 8000k -shortest -filter:a "volume=${VOLUME}" \
      -f flv -rtmp_buffer 6000 "${RTSPLINK1}" \
      -map "[out2]" -map "1:a" \
      -codec:v libx264 -pix_fmt yuv420p -preset veryfast -b:v 8000k -r 30.0 -g 60.0 \
      -codec:a aac -b:a 128k -ar 44100 -maxrate 4000k -bufsize 8000k -shortest -filter:a "volume=${VOLUME}" \
      -f flv -drop_pkts_on_overflow 1 -attempt_recovery 1 -recovery_wait_time 1 -rtmp_buffer 6000 "${RTSPLINK2}"
  fi

  echo "[ERROR] `date '+%Y-%m-%d %H:%M:%S'` Stream crashed. Restarting..." >> ${SCRIPT_DIR}/event.log
  on_stream_restart
done
