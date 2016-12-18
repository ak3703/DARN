INPUT_FILES="compiler_fail/*.darn"
printf "Testing fail tests \n"

for input_file in $INPUT_FILES; do
    output_file=${input_file/.darn/.out}
    ../compiler/darn.native < $input_file 2> temp.txt
    cmp $output_file temp.txt

    if [ "$?" -eq 0 ]; then
        printf "$input_file \t\t  Success \n"
    else
        printf "$input_file \t\t Error \n" 1>&2
        rm -f $TMP_FILE
        exit 1
    fi

done

rm -f temp.txt
exit 0