#!/bin/bash

INPUT_FILES="scanner/*.in"
printf "Testing scanner \n"

for input_file in $INPUT_FILES; do
    printf "Testing a file in scanner folder \n"
    output_file=${input_file/.in/.out}
    ../darn < $input_file | cmp -s $output_file -
    if [ "$?" -eq 0 ]; then
        printf "Success \n"
    else
        printf "Error \n"
        exit 1
    fi
done

exit 0
