#!/bin/bash
#set -x

INPUT_DIR=demo_all
OUTPUT_DIR=demo_all_mitigated

check_word_in_file() {
    printf "\tL_ searching for %-9s in file: $2" $1
    if grep -q "$1" "$2"; then
	echo " [OK]"
    else
	echo " [FAIL]"
    fi
}

echo ".. copying base '$INPUT_DIR' CCS project to '$OUTPUT_DIR'" 
rm -Rf $OUTPUT_DIR
cp -R  $INPUT_DIR $OUTPUT_DIR
rm -Rf $OUTPUT_DIR/Debug/

echo ".. sanity-check CCS project configuration"
sed -i "s#<name>$(basename $INPUT_DIR)</name>#<name>$(basename $OUTPUT_DIR)</name>#g" $OUTPUT_DIR/.project
check_word_in_file "libipe" "$OUTPUT_DIR/.cproject"
check_word_in_file "linker.py" "$OUTPUT_DIR/.cproject"

echo ".. running translator.py"
../framework/translator.py $OUTPUT_DIR/victim.c -ccs ~/ti/ccs1260/ccs/ -output $OUTPUT_DIR

# HACK since translator.py only keeps the IPE funcs but not the data vars
echo ".. fixing victim.c"
head -n 22 $INPUT_DIR/victim.c | cat - $OUTPUT_DIR/victim.c > victim.c.tmp
mv victim.c.tmp $OUTPUT_DIR/victim.c

echo ".. generating diff summary"
diff -qr $INPUT_DIR $OUTPUT_DIR | sed 's/^/\tL_ /'

echo ".. all done; ready to import '$OUTPUT_DIR' as a new CCS project!"

