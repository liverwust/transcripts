Transcripts
===========

Originally, the intention was to automate ingest of recorded files to
Dragon NaturallySpeaking, and to produce actual transcripts of recorded
audio notes. However, the speech-to-text engine doesn't do a good job,
perhaps because of the car noise or just my voice. Instead, the new
goal is to produce "audio transcripts," with car noise reduced and
silence removed.

Components
----------

* [LG Tone Infim HBS920 Bluetooth headset][1]
* [Sony Xperia XA2][2] or other Android handset
* [axet android-audio-recorder][3]
* [Audacity][4]
* 15-sec WAV file (48kHz) of car noise; not saved in Git

[1]: https://www.lg.com/sa_en/support/support-product/lg-HBS-920
[2]: https://www.sonymobile.com/us/products/phones/xperia-xa2/
[3]: https://gitlab.com/axet/android-audio-recorder
[4]: https://www.audacityteam.org/

Workflow
--------

1.  Pair & connect headset to phone, to use while driving
2.  Configure Audio Recorder app with the following settings:
    * __Storage Path:__ default, under "Android"
    * __Recording Source:__ Bluetooth
    * __Sample Rate:__ 48kHz
    * __Encoding:__ .flac
    * __Mode:__ Mono (default)
    * __Name Format:__ 2020-01-20 13.58.41.flac
    * __Bandpass Voice Filter:__ enabled
    * __Recording Volume:__ 100%
    * __Skip Silence:__ disabled
    * __Encoding on Fly:__ disabled
    * __Pause During Calls:__ enabled
    * __Silence Mode:__ disabled
    * __Lockscreen Controls:__ disabled
3.  Start recording; don't worry about leaving silence to think
4.  Stop recording
5.  Later, once off the road, rename & upload the file (e.g., w/ QFile)
6.  Download the file to a computer with Audacity, to /tmp/macro-input
7.  Copy CarNoise.wav (not included) into /tmp/macro-input as well, and
    rename it so that it will be sorted first (e.g., 000-CarNoise.wav)
8.  Set up the _Remove Car Noise_ macro to match the included PNG
9.  Run the macro on __Files...__, and select all files in
    /tmp/macro-input -- note that Audacity seems to have problems when
    more than 100 files are selected
10. Run the adjust\_mtimes.sh script with no arguments
11. Upload the xx\_processed.ogg files from /tmp/macro-output to NAS
