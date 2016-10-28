#!/bin/bash

INPUT_FILES="parser/*.in"
printf "Testing parser \n"

for input_file in $INPUT_FILES; do
    printf "Testing a file in parser folder $input_file \n"
    output_file=${INPUT_FILES/.in/.out}
    ../compiler/darn < $input_file | cmp -s $output_file -
    if [ "$?" -eq 0 ]; then
        printf "Success \n"
    else
        printf "Error \n"
        exit 1
    fi
done

exit 0
