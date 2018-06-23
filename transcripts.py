#!/usr/bin/env python3
#
# Manage transcripts for note-taking sessions, using a workflow based around
# the Dragon NaturallySpeaking software. This script doesn't actually interact
# with Python, but rather ensures that the various files (original OGG,
# transcoded MP3, and transcribed RTF) are easy for me to work with.
#
# Much of the value of this script comes from the fact that my Audio Recorder
# software (https://gitlab.com/axet/android-audio-recorder) saves filenames
# containing spaces, and I can't find a way to change that.
#
# Created by Louis Wust


import argparse
import datetime
#import ffmpeg
import os
import os.path
import re
#import unrtf


# https://stackoverflow.com/questions/2720319/python-figure-out-local-timezone
LOCAL_TIMEZONE = datetime.datetime.now(datetime.timezone.utc).astimezone().tzinfo


def do_date(args):
    date_re = re.compile('^(\d{4})-(\d{2})-(\d{2}) (\d{2})\.(\d{2})\.(\d{2}).*$')
    for path in args.path:
        date_match = date_re.match(os.path.basename(path))
        date = datetime.datetime(year=int(date_match.group(1)),
                                 month=int(date_match.group(2)),
                                 day=int(date_match.group(3)),
                                 hour=int(date_match.group(4)),
                                 minute=int(date_match.group(5)),
                                 second=int(date_match.group(6)),
                                 tzinfo=LOCAL_TIMEZONE)
        os.utime(path, times=(date.timestamp(), date.timestamp()))


if __name__ == '__main__':
    parser = argparse.ArgumentParser(prog="transcripts",
                                     description="Manage transcripts for note-taking sessions")
    subparsers = parser.add_subparsers()

    parser_date = subparsers.add_parser('date', help='set correct timestamp')
    parser_date.add_argument('path', nargs='+')
    parser_date.set_defaults(func=do_date)

    args = parser.parse_args()
    args.func(args)