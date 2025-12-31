cd "/home/nonroot/media"
shopt -s globstar
shopt -s nullglob

for file in **/*; do
    # Skip files that are already processed or are temp files
    [[ "$file" == *"_ready"* ]] && continue
    [[ "$file" == *"temp_"* ]] && continue

    # CASE 1: VIDEOS
    if [[ "$file" =~ \.(mp4|mov|MP4|MOV)$ ]]; then
        echo "Processing Video: $file"
        temp_file="$(dirname "$file")/temp_$(basename "${file%.*}.mp4")"
        
        # Transpose=1 rotates 90 degrees clockwise
        ffmpeg -y -i "$file" -vf \
        "transpose=1,scale=1920:1080:force_original_aspect_ratio=decrease,pad=1920:1080:(1920-iw)/2:(1080-ih)/2:color=white" \
        -r 30 -c:v libx264 -crf 28 -preset ultrafast -an "$temp_file"

        if [ $? -eq 0 ]; then
            mv "$temp_file" "${file%.*}_ready.mp4"
            rm -f "$file"  # Added -f to prevent prompting
        fi

    # CASE 2: IMAGES
    elif [[ "$file" =~ \.(jpg|jpeg|png|JPG|PNG)$ ]]; then
        echo "Processing Image: $file"
        # Rotate 90, resize, and pad with white background
        convert "$file" -rotate 90 -resize 1920x1080 -background white -gravity center -extent 1920x1080 "${file%.*}_ready.jpg"
        
        if [ $? -eq 0 ]; then
            rm -f "$file"  # Added -f to prevent prompting
        fi
    fi
done

echo "Preprocessing complete."
