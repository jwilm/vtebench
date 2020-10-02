#!/usr/bin/env bash

# Plot all benchmarks in separate SVGs.

# Make sure gnuplot is installed.
if ! [ -x "$(command -v gnuplot)" ]; then
    echo "command not found: gnuplot"
    exit 1
fi

# Ensure at least one input and output file is present.
if [ $# -lt 2 ]; then
    echo "Usage: gnuplot.sh <INPUT_FILES>... <OUTPUT_FILE>"
    exit 1
fi

# Get last argument as output file with the `.svg` suffix removed.
output_index=$#
output_name=${!output_index}
output_nosuffix=${output_name%.svg}
output_suffix=${output_name##$output_nosuffix}

num_cols=$(cat "$1" | head -n 1 | awk '{ print NF }')

for col in $(seq 1 $num_cols); do
    # Append benchmark name before file suffix.
    benchmark=$(cat "$1" | head -n 1 | awk "{ print \$$col }")
    output_file="${output_nosuffix}_${benchmark}${output_suffix}"

    # Setup gnuplot script with output format and file.
    gnuplot_script="\
    set terminal svg noenhanced size 1000,750 background rgb 'white'
    set output \"${output_file}\"
    set xlabel \"samples\"
    set ylabel \"milliseconds (lower is better)\"
    plot "

    # Add all columns for the input file to the gnuplot script.
    for input_index in $(seq 1 $(($# - 1))); do
        input_file=${!input_index}
        gnuplot_script+="\"$input_file\" \
            using $col \
            with linespoint \
            title \"$input_file: \".columnhead($col),"
    done
    gnuplot_script=${gnuplot_script::-1}

    # Plot everything.
    echo -e "$gnuplot_script" | gnuplot
done