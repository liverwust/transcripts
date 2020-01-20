#!/bin/sh
#
# Given a set of input audio files, and a set of processed audio files, adjust
# the filenames and mtimes of the second set to match the first.
#
# Requires vorbis-tools
#
# https://github.com/liverwust/transcripts

input_directory=${ADJUST_MTIME_BATS_INPUTDIR:-/tmp/macro-input}
output_directory=${ADJUST_MTIME_BATS_OUTPUTDIR:-/tmp/macro-output}
ogginfo=${ADJUST_MTIME_BATS_OGGINFO:-ogginfo}

input_listing=`mktemp`
output_listing=`mktemp`

# Input is assumed to be sorted alphabetically
ls -1 "$input_directory" > "$input_listing"
# Output sorting is based on oldest (1st processed) to newest (last)
ls -1 -tr "$output_directory" | tail -n `cat "$input_listing" | wc -l` > "$output_listing"

# Sanity checks
if head -n1 "$input_listing" | grep -q -v CarNoise
then
	echo "CarNoise should have been the first file processed" >/dev/stderr
	exit 1
fi
if $ogginfo `head -n1 "$output_listing"` | grep -qE 'data length: +[0-9]{5,}'
then
	# The assumption is that the "Noise Reduction" plugin would have
	# reduced the data size of the CarNoise sample itself to <10000 bytes
	# (really it's much less, more like 3000 bytes)
	echo "Cannot identify CarNoise file in output dir" >/dev/stderr
	exit 1
fi
if [ `ls "$output_directory" | wc -l` -lt `cat "$input_listing" | wc -l` ]; then
	echo "Too few output files compared with input files" >/dev/stderr
	exit 1
elif [ `ls "$output_directory" | wc -l` -gt `cat "$input_listing" | wc -l` ]; then
	echo "WARNING: more output files than input files; proceeding with the most recent outputs" >/dev/stderr
	# Don't exit, because this is just a warning
elif [ `ls "$output_directory" | wc -l` -eq 0 ]; then
	# Technically not an error, but would confuse seq; just exit
	exit 0
fi

# Everything looks good, so go ahead and transfer file attributes
seq 1 `cat "$input_listing" | wc -l` | while read i; do
	input_filename=`head -n$i "$input_listing" | tail -n1`
	output_filename=`head -n$i "$output_listing" | tail -n1`
	if [ $i -eq 1 ]; then
		# Remove the otherwise useless CarNoise file from output
		rm "$output_directory/$output_filename"
	else
		input_filename_wo_ext=`echo "$input_filename" | sed -r "s/\\.[a-zA-Z0-9]+\$//"`
		touch -r "$input_directory/$input_filename" "$output_directory/$output_filename"
		mv "$output_directory/$output_filename" "$output_directory/${input_filename_wo_ext}_processed.ogg"
	fi
done

rm "$input_listing"
rm "$output_listing"
