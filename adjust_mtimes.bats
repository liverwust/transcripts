#!/usr/bin/env bats

script=$BATS_TEST_DIRNAME/adjust_mtimes.sh
input_directory=$BATS_TMPDIR/bats-macro-input
output_directory=$BATS_TMPDIR/bats-macro-output

setup() {
	mkdir "$input_directory"
	mkdir "$output_directory"
	fakeogginfo=$(mktemp -p $BATS_TMPDIR)
	# avoid tripping the maximum data size for CarNoise.ogg
	echo "echo data length: 999" > $fakeogginfo
	chmod 0755 $fakeogginfo
	export ADJUST_MTIME_BATS_INPUTDIR=$input_directory
	export ADJUST_MTIME_BATS_OUTPUTDIR=$output_directory
	export ADJUST_MTIME_BATS_OGGINFO=$fakeogginfo
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
	# deliberately trip the maximum data size for CarNoise.ogg
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

@test "Nominal case, check filenames" {
	touch "${input_directory}/000_CarNoise.ogg"
	# ctime ordering does not matter for input; only the name
	touch "${input_directory}/file3.flac"
	touch "${input_directory}/file1.mp3"
	touch "${input_directory}/file2.ogg"
	# ctime ordering *does* matter for output; sleep to be sure
	echo 0 > "${output_directory}/converted000.ogg" && sleep 0.1
	echo 1 > "${output_directory}/converted001.ogg" && sleep 0.1
	echo 2 > "${output_directory}/converted002.ogg" && sleep 0.1
	echo 3 > "${output_directory}/converted003.ogg" && sleep 0.1
	run $script
	[ "$status" -eq 0 ]
	# no CarNoise in output
	[ $(ls $output_directory | wc -l) -eq 3 ]
	[ $(cat "${output_directory}/file1_processed.ogg") = "1" ]
	[ $(cat "${output_directory}/file2_processed.ogg") = "2" ]
	[ $(cat "${output_directory}/file3_processed.ogg") = "3" ]
}

@test "Nominal case, check mtimes" {
	touch "${input_directory}/000_CarNoise.ogg"
	touch -d @1565000000 "${input_directory}/file1.mp3"
	touch "${output_directory}/converted.ogg"
	touch "${output_directory}/converted000.ogg"
	run $script
	[ "$status" -eq 0 ]
	[ $(stat -c "%Y" "${output_directory}/file1_processed.ogg") = 1565000000 ]
}
