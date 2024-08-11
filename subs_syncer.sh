#!/bin/bash

if [ $# -ne 3 ]; then
    { echo "Input format: min_delay sec_delay show_name"; exit 1; }
fi

show_name="$3"

mkdir -p "Synced subs/$show_name"

FILES=$(ls "Unsynced subs" | grep ".ass")
I=1

for file in $FILES
do
    grep "Dialogue" "Unsynced subs/$file" | awk -v min_delay="$1" -v sec_delay="$2" -F ","  '
    BEGIN {
        counter = 1
    }
    {
        start = $2
        end = $3 
        japanese = $10

        split(start, start_separated, ":") #output a list
        split(start_separated[3], start_secmil,".")
        
        start_hour = start_separated[1]
        start_min = start_separated[2]
        start_sec = start_secmil[1]
        start_mil = start_secmil[2]

        split(end, end_separated, ":")
        split(end_separated[3], end_secmil,".")

        end_hour = end_separated[1]
        end_min = end_separated[2]
        end_sec = end_secmil[1]
        end_mil = end_secmil[2]

        if ((start_min > min_delay) || (start_min == min_delay && start_sec > sec_delay)) {
            start_min -= min_delay
            start_sec -= sec_delay
            end_min -= min_delay
            end_sec -= sec_delay
            if (start_sec < 0) {
                start_sec += 60
                start_min -= 1
            }
            if (end_sec < 0) {
                end_sec += 60
                end_min -= 1
            }
        }
        printf "%d\n", counter
        printf "%d:%02d:%02d.%02d --> %d:%02d:%02d.%02d\n", 
        start_hour, start_min, start_sec, start_mil,
        end_hour, end_min, end_sec, end_mil
        printf "%s\n\n", japanese 
        counter ++
    }' > "Synced subs/$show_name/$show_name $I.srt"
    I=$((I + 1))
done