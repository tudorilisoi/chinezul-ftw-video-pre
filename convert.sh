#This script should
#-preserve these comments
#- convert videos to a format suitable for mobile portrait, vutting out the left-righ margins
#- put all converted videos on an "output" folder, overwrite output, preserve the originals
#- make sure you set oriantation information in output metadata
#- use ffmpeg or suggest another tool
#- make ffmpeg params contants at the top of the script so I can tweak them around

# FFmpeg parameters - tweak these to customize conversion
INPUT_DIR="."           # Input directory (current folder)
OUTPUT_DIR="output"     # Output folder name
PORTRAIT_ASPECT=9       # Portrait aspect ratio (9:16)
LANDSCAPE_ASPECT=16     # Landscape aspect ratio (16:9)
TARGET_WIDTH=1080       # Target width in pixels
TARGET_HEIGHT=1920      # Target height in pixels
VIDEO_CODEC="libx264"   # Video codec
AUDIO_CODEC="aac"       # Audio codec
PRESET="fast"           # Encoding preset
# ---------------------------------------------------------

# Create output directory, removing any existing one to ensure clean overwrite
rm -rf "$OUTPUT_DIR"
mkdir -p "$OUTPUT_DIR"

# Timestamp for output filenames: dd-mm-yy-hh:mm:ss
TIMESTAMP=$(date +%d-%m-%y-%H:%M:%S)

# Process each video file in the input directory
for f in "$INPUT_DIR"/*; do
    # Skip if not a regular file (skip directories, the script itself, etc.)
    [ -f "$f" ] || continue

    # Skip the script itself to avoid converting it
    filename=$(basename "$f")
    [ "$filename" = "convert.sh" ] && continue

    # Extract filename without extension for output naming
    extension="${filename##*.}"
    basename_noext="${filename%.*}"

    # Output file path
    output_file="$OUTPUT_DIR/${basename_noext}_portrait_${TIMESTAMP}.mp4"

    echo "Converting: $f -> $output_file"

    # ffmpeg command:
    # -i "$f"           - input file
    # -map_metadata 0     - copy metadata from source (handles orientation)
    # -vf "crop=...      - crop to centered portrait strip (9:16), keeping
    #                     the horizontal middle, cutting left/right margins,
    #                     then scale to target resolution
    # -c:v "$VIDEO_CODEC" - video encoder
    # -preset "$PRESET" - encoding speed/quality tradeoff
    # -c:a "$AUDIO_CODEC" - audio encoder
    # -y "$output_file" - overwrite output if it exists
    ffmpeg -i "$f" -map_metadata 0 \
        -vf "crop=ih*${PORTRAIT_ASPECT}/${LANDSCAPE_ASPECT}:ih:(in_w-out_w)/2:0,scale=${TARGET_WIDTH}:${TARGET_HEIGHT}" \
        -c:v "$VIDEO_CODEC" -preset "$PRESET" \
        -c:a "$AUDIO_CODEC" \
        -y "$output_file"
done

echo "Done. Converted videos are in $OUTPUT_DIR (originals preserved unchanged)."
