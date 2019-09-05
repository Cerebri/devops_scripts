#!/usr/bin/env bash

# Call this script with
# $1 - the CSV file name
# $2 - the amount of lines to cut into each split, say 5000
# $3 - Amount of seconds for giving monetdb a decent chance to catch up, this will need to be adjusted until monetdb is not flooding the memory any more

# Split the file in pieces
split -l $2 $1 split_

# Process each split file
for file in split_*
do
    # Import the $file here

	# Wait for monetdb to catch up
	sleep $3
	# Delete the split file
	rm -rf $file
done