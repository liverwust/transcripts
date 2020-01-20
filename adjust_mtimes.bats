#!/usr/bin/env bats

script=$BATS_TEST_DIRNAME/adjust_mtimes.sh
input_directory=$BATS_TMPDIR/bats-macro-input
output_directory=$BATS_TMPDIR/bats-macro-output

setup() {
	mkdir "$input_directory"
	mkdir "$output_directory"
	export ADJUST_MTIME_BATS_INPUTDIR=$input_directory
	export ADJUST_MTIME_BATS_OUTPUTDIR=$output_directory
}
teardown() {
	rm -rf "$input_directory"
	rm -rf "$output_directory"
}

@test "Empty directories are OK" {
	run $script
	[ "$status" -eq 0 ]
	[ "$output" = "" ]
}

@test "Error on missing CarNoise file" {
	touch "${input_directory}/NotRight.mp3"
	touch "${input_directory}/StillWrong.mp3"
	touch "${output_directory}/NotRight_processed.mp3"
	touch "${output_directory}/StillWrong_processed.mp3"
	run $script
	[ "$status" -eq 1 ]
	[ $(echo "$output" | grep -icE "CarNoise.*first file") -gt 0 ]
}

@test "Error on too-large CarNoise output" {
	executable=$(mktemp -p $BATS_TMPDIR)
	echo "echo data length: 10000" > $executable
	chmod 0755 $executable
	touch "${input_directory}/CarNoise.ogg"
	touch "${input_directory}/Junk.ogg"
	touch "${output_directory}/Junk_processed.ogg"
	touch "${output_directory}/CarNoise_processed.ogg"
	export ADJUST_MTIME_BATS_OGGINFO=$executable
	run $script
	[ "$status" -eq 1 ]
	[ $(echo "$output" | grep -ic "identify CarNoise") -gt 0 ]
	rm $executable
}

@test "Error on too few output files" {
	touch "${input_directory}/CarNoise.ogg"
	touch "${input_directory}/OK1.ogg"
	touch "${input_directory}/OK2.ogg"
	touch "${output_directory}/CarNoise_processed.ogg"
	touch "${output_directory}/OK1_processed.ogg"
	run $script
	[ "$status" -eq 1 ]
	[ $(echo "$output" | grep -ic "too few") -gt 0 ]
}

