# AmasiaStream
Lightweight 24/7 RTSP (Twitch / YouTube / ReStream / etc) Music Radio using FFMPEG.
This repo is a fork of [NoniDOTio's work](https://github.com/NoniDOTio/LiveStreamRadio), thanks to him !

## Dependencies
- Install the following software on your machine: ffmpeg, alsa, mpg123
I recommend the use of tmux or screen to launch the player.sh and 247stream.sh separately.

The "streamlink" package can also be useful to catch live streams.

```bash
sudo apt install mpg123 alsa ffmpeg tmux
sudo modprobe snd-aloop
```
You can also add snd-aloop module at boot in /etc/modules

- Add your user to "audio" group

~/.asoundrc file contents :

```bash
pcm.!default {
        type hw
        card 1
}

pcm.dmixer  {
        type dmix
        ipc_key 1024
        slave {
          pcm "hw:0,0"
            period_size 1024
            buffer_size 4096
            rate 44100
        }
        bindings {
            0 0
            1 1
        }
}

#pcm.rate_convert {
#    type rate
#    slave sl2
#}

ctl.!default {
        type hw
        card 1
}
```

- Then exit and re-login to load new ALSA Settings

Check your default card with :

aplay -l

Then, change the default PCM in the asoundrc file, and in the 247Stream.sh file at the Loopback hw device selection (Example: "-i hw:Loopback,1,0" for loopback card #1)


Audio Test to file
```bash
/usr/bin/ffmpeg -loglevel warning -re -threads 0 \
  -f alsa -ac 2 -thread_queue_size 1024 -i hw:Loopback,1,0 \
  -codec:a aac -b:a 128k -ar 44100 -maxrate 4000k -bufsize 8000k -shortest -filter:a "volume=-2dB" \
  output.aac
```

Test ALSA Loopback configuration (while playing a song with mpg123 or player.sh)

```bash
arecord --dump-hw-params -D hw:Loopback,1,0
```

## Installation
Install the required packages, then clone this repository :
```bash
git clone https://github.com/nostromatic/AmasiaStream.git
```

## How To Use
1. Create your mp3 playlist
Create a folder containing all your mp3 files.
Recommended format is 128kbps MP3 file with 44100Hz of samplerate, if you use mixed formats, ALSA may not be happy.
Execute this to create the playlist.txt file containing the full path of every mp3 files in a random order (adjust the path of mp3 folder and playlist.txt) :
```bash
cd to/the/mp3/folder
find $(pwd) -type f -name "*.mp3" > path/to/playlist.txt
```

3. Create your background image or video
This will be the image deplayed in the stream background, and it also defines your stream resolution.
If your image is 720p, your stream will be in 720p, same for 1080p.
The ffmpeg command is configured to stream at 30 FPS.
Same thing for an mp4 video.

4. Adjust config.sh settings

5. Launching the stream: Use tmux and create 2 terminals

One to launch the stream first (important)
```bash
./247stream.sh
```

Then, the player.sh
```bash
./player.sh
```
