#!/bin/bash

# Crops the image to fit in the display

cd "/home/nonroot/media"
shopt -s globstar
shopt -s nullglob

for file in **/*; do
    # Skip files that are already processed or are temp files
    [[ "$file" == *"_processed"* ]] && continue
    [[ "$file" == *"temp_"* ]] && continue

    # CASE 1: VIDEOS
    if [[ "$file" =~ \.(mp4|mov|MP4|MOV)$ ]]; then
        echo "Processing Video: $file"
        temp_file="$(dirname "$file")/temp_$(basename "${file%.*}.mp4")"

        # Transpose=1 rotates 90 degrees clockwise
        ffmpeg -y -i "$file" -vf \
        "transpose=1,scale=1920:1080:force_original_aspect_ratio=increase,crop=1920:1080" \
        -r 30 -c:v libx264 -crf 28 -preset ultrafast -an "$temp_file"

        if [ $? -eq 0 ]; then
            mv "$temp_file" "${file%.*}_processed.mp4"
            rm -f "$file"
        fi

    # CASE 2: IMAGES
    elif [[ "$file" =~ \.(jpg|jpeg|png|JPG|PNG)$ ]]; then
        echo "Processing Image: $file"

        # dimensions=$(identify -format "%w %h" "$file")
        # read w h <<< "$dimensions"

        convert "$file" \
            -auto-orient \
            -rotate 90 \
            -resize "1920x1080^" \
            -gravity center \
            -extent 1920x1080 \
            "${file%.*}_processed.jpg"

        if [ $? -eq 0 ]; then
            rm -f "$file"
        fi
    fi
done

echo "Preprocessing complete."
