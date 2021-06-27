#
# Absolute path of the dictory the script is in. Don't touch this unless you know what you're doing
#
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

#
# Filter to adjust music volume. -2dB is recommended
#
VOLUME="-2dB"

#
# How many threads FFMPEG will use. Set to "0" to let FFMPEG decide
#
THREAD_COUNT="6"

#
# Filepath of your background video. Must be an JPG or PNG image, 720p or 1080p resolution.
# Take into account the place for the waveform, and the dynamic text (Artist, album, trackname) overlays
BACKGROUND="${SCRIPT_DIR}/assets/bg.jpg"

#
# RTMP URLs you wish to stream to
#
RTSPLINK1="rtmp://paris.restream.io/live/re_2084611_3e79043d262eeb3ec309"
#RTSPLINK1="rtmps://live-api-s.facebook.com:443/rtmp/2614512578800578?s_bl=1&s_ps=1&s_sw=0&s_vt=api-s&a=Abxbchl2bn985qf6"
RTSPLINK2=""

#
# Executed before the next song in the playlist starts playing
# It uses ffprobe to determine ID3 Tags
# 
# Arguments:
#   ${1} Artist name (ID3 Tag)
#   ${2} Album name (ID3 Tag)
#   ${3} Track name (ID3 Tag) OR filename if tag is not available (without .mp3 extension)
# Returns:
#   None
#
function on_next_track() {
  # Your custom code goes here

  # The following line writes the currently playing song to a text file.
  # You can safely remove it if you don't need this feature
  echo "${1} / ${2} / ${3}" > ${SCRIPT_DIR}/now_playing.txt

  :
}

#
# Executed after the playlist has been reshuffled
# Arguments:
#   None
# Returns:
#   None
#
function on_playlist_reshuffle() {
  # Your custom code goes here

  :
}

#
# Executed when the stream is restarting (e.g. after a crash)
# Arguments:
#   None
# Returns:
#   None
#
function on_stream_restart() {
  # Your custom code goes here

  :
}
