# LiveStreamRadio
Lightweight 24/7 RTSP (Twitch / YouTube / ReStream / etc) Music Radio using FFMPEG.
This repo is a fork of [NoniDOTio's work](https://github.com/NoniDOTio/LiveStreamRadio), thanks to him !

## Dependencies
Install the following software on your machine: alsa, mpg123, ffmpeg
I recommend the use of tmux or screen to launch the player.sh and 247stream.sh separately.

## Installation
Install the required packages, then clone this repository :
```bash
git clone https://github.com/NoniDOTio/LiveStreamRadio.git
```

## How To Use
### Create your music playlist
Create a folder containing all your mp3 files.
Recommended format is 128kbps MP3 file with 44100Hz of samplerate, if you use mixed formats, ALSA may not be happy.

The create the playlist.txt file containing the full path of every (adjust the path of mp3 folder and playlist.txt)
```bash
cd to/the/mp3/folder
find $(pwd) -type f -name "*.mp3" > path/to/playlist.txt
```

Every lines will be shuffled at player.sh start

### Create your background image
This will be the image deplayed in the stream background, and it also defines your stream resolution.
If your image is 720p, your stream will be in 720p, same for 1080p.
The ffmpeg command is configured to stream at 30 FPS.

Place the image to /path/to/the/git/folder/assets/bg.jpg

### Adjust config.sh settings


### Launching the stream
Use tmux and create 2 terminals

One to launch the stream first
```bash
./247stream.sh
```

Then, the player.sh
```bash
./player.sh
```
