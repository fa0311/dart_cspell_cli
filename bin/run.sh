#!/bin/sh

input_file="$1"

grep -oP '(?<=Unknown word \()\w+(?=\))' "$input_file" | sort | uniq