. ./config.sh

while true :
do

  # Audio Test to file
  #
  #/usr/bin/ffmpeg -loglevel warning -re -threads 0 \
  #  -f alsa -ac 2 -thread_queue_size 1024 -i hw:Loopback,1,0 \
  #  -codec:a aac -b:a 128k -ar 44100 -maxrate 4000k -bufsize 8000k -shortest -filter:a "volume=-2dB" \
  #  output.aac
  #
  # Test ALSA Loopback configuration (while playing a song with mpg123 or player.sh)
  #
  # arecord --dump-hw-params -D hw:Loopback,1,0

  # If $RTSPLINK2 is configured, the stream is splitted in two outputs, and every output is streamed to the provider (careful with your CPU and bandwidth)
  if [ -z "${RTSPLINK2}" ]
  then
    # Launch the stream to the unique URL
    /usr/bin/ffmpeg -loglevel warning -re -threads "${THREAD_COUNT}" \
      -framerate 30 -loop 1 -f image2 -i ${BACKGROUND} \
      -f alsa -acodec pcm_s32le -ac 2 -thread_queue_size 2048 -i hw:Loopback,1,0 \
      -filter_complex \
      "[0:v] drawtext=fontsize=32:fontfile=FreeSerif.ttf:textfile=${SCRIPT_DIR}/now_playing.txt:x=(w-text_w)/2:y=h-th-10:reload=1:fontcolor=black [v];
      [1:a] showwaves=s=1920x120:mode=line:colors=White [vf];
      [v][vf] overlay=x=1:y=880 [fin]" \
      -map "[fin]" -map "1:a" \
      -codec:v libx264 -pix_fmt yuv420p -preset veryfast -b:v 8000k -r 30.0 -g 60.0 \
      -codec:a aac -b:a 128k -ar 44100 -maxrate 4000k -bufsize 8000k -shortest -filter:a "volume=${VOLUME}" \
      -f flv -rtmp_buffer 6000 "${RTSPLINK1}"

  else
    # Launch the stream to the both URLs
    /usr/bin/ffmpeg -loglevel warning -re -threads "${THREAD_COUNT}" \
      -framerate 30 -loop 1 -f image2 -i ${BACKGROUND} \
      -f alsa -acodec pcm_s32le -ac 2 -thread_queue_size 2048 -i hw:Loopback,1,0 \
      -filter_complex \
      "[0:v] drawtext=fontsize=26:fontfile=FreeSerif.ttf:textfile=${SCRIPT_DIR}/now_playing.txt:x=(w-text_w)/2:y=h-th-10:reload=1:fontcolor=black [v];
      [1:a] showwaves=s=1920x120:mode=line:colors=White [vf];
      [v][vf] overlay=x=1:y=880 [fin];
      [fin] split=2[out1][out2]" \
      -map "[out1]" -map "1:a" \
      -codec:v libx264 -pix_fmt yuv420p -preset veryfast -b:v 8000k -r 30.0 -g 60.0 \
      -codec:a aac -b:a 128k -ar 44100 -maxrate 4000k -bufsize 8000k -shortest -filter:a "volume=${VOLUME}" \
      -f flv -rtmp_buffer 6000 "${RTSPLINK1}" \
      -map "[out2]" -map "1:a" \
      -codec:v libx264 -pix_fmt yuv420p -preset veryfast -b:v 8000k -r 30.0 -g 60.0 \
      -codec:a aac -b:a 128k -ar 44100 -maxrate 4000k -bufsize 8000k -shortest -filter:a "volume=${VOLUME}" \
      -f flv -rtmp_buffer 6000 "${RTSPLINK2}"
  fi

  echo "[ERROR] `date '+%Y-%m-%d %H:%M:%S'` Stream crashed. Restarting..." >> ${SCRIPT_DIR}/event.log
  on_stream_restart
done
