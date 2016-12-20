#!/bin/bash

INPUT_FILES="compiler/*.darn"
printf "Testing compiler \n"

for input_file in $INPUT_FILES; do
    output_file=${input_file/.darn/.out}
    ../compiler/darn.native -c $input_file ../compiler/stdlib.darn | /usr/local/opt/llvm/bin/lli | cmp $output_file -
    if [ "$?" -eq 0 ]; then
        printf "$input_file \t\t  Success \n"
    else
        printf "$input_file \t\t Error \n"
        exit 1
    fi
done

exit 0
