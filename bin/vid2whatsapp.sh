#!/bin/bash
#
# vid2whatsapp.sh - convert any video into an MP4 that WhatsApp accepts.
#
# WhatsApp only plays MP4 files with H.264 video and AAC audio, and rejects
# videos over 16 MB. This script re-encodes the input (webm, mkv, mov, ...)
# to that format, keeps the original aspect ratio, and picks a bitrate from
# the video's duration so the result fits under the size limit.
#
# Usage:
#   vid2whatsapp.sh [-o output.mp4] [-s size_mb] [-f] input [input ...]
#
# Options:
#   -o FILE   Output file (only with a single input).
#             Default: same folder and name as the input, with .mp4
#             (or "-whatsapp.mp4" when the input is already an .mp4).
#   -s MB     Maximum output size in MB. Default: 16 (WhatsApp's limit).
#   -f        Overwrite the output file if it already exists.
#   -h        Show this help.
#
# Examples:
#   vid2whatsapp.sh clip.webm                 # -> clip.mp4
#   vid2whatsapp.sh -o ~/Desktop/a.mp4 a.mkv
#   vid2whatsapp.sh -s 8 *.webm               # smaller files, many inputs
#
# How the quality is chosen:
#   - Video bitrate = what fits in the size limit for this duration, capped
#     at 1500 kb/s (more than that is wasted, WhatsApp recompresses anyway).
#   - If less than 900 kb/s is available (long videos), the short side is
#     scaled down to 720 px so the picture stays clean. The ratio is kept.
#   - If less than 250 kb/s is available the video is too long to look
#     acceptable, so the script stops and suggests a larger -s.
#
# Requires: ffmpeg and ffprobe (brew install ffmpeg)

set -euo pipefail

SIZE_MB=16          # target maximum file size
AUDIO_KBPS=128      # AAC audio bitrate
MAX_VIDEO_KBPS=1500 # never spend more than this on video
DOWNSCALE_KBPS=900  # below this, scale down to 720p
MIN_VIDEO_KBPS=250  # below this, refuse to convert
OUTPUT=""
OVERWRITE="-n"

usage() {
    # Print the header comment of this file as the help text
    sed -n '3,/^$/p' "$0" | sed 's/^# \{0,1\}//'
}

while getopts ":o:s:fh" opt; do
    case "$opt" in
        o) OUTPUT="$OPTARG" ;;
        s) SIZE_MB="$OPTARG" ;;
        f) OVERWRITE="-y" ;;
        h) usage; exit 0 ;;
        :) echo "Error: -$OPTARG needs a value" >&2; exit 1 ;;
        *) echo "Error: unknown option -$OPTARG" >&2; usage >&2; exit 1 ;;
    esac
done
shift $((OPTIND - 1))

if [ $# -eq 0 ]; then
    usage >&2
    exit 1
fi

if [ -n "$OUTPUT" ] && [ $# -gt 1 ]; then
    echo "Error: -o can only be used with a single input file" >&2
    exit 1
fi

for cmd in ffmpeg ffprobe; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
        echo "Error: $cmd not found (brew install ffmpeg)" >&2
        exit 1
    fi
done

convert() {
    local input="$1" output="$2"

    if [ ! -f "$input" ]; then
        echo "Error: file not found: $input" >&2
        return 1
    fi

    if [ -e "$output" ] && [ "$OVERWRITE" = "-n" ]; then
        echo "Error: $output already exists (use -f to overwrite)" >&2
        return 1
    fi

    local duration
    duration=$(ffprobe -v error -show_entries format=duration -of csv=p=0 "$input")
    if [ -z "$duration" ] || [ "$duration" = "N/A" ]; then
        echo "Error: could not read the duration of $input" >&2
        return 1
    fi

    # Video bitrate that fits the size limit: 5% is left as headroom for
    # the container, and the audio bitrate is subtracted from the total.
    local video_kbps
    video_kbps=$(awk -v mb="$SIZE_MB" -v dur="$duration" -v audio="$AUDIO_KBPS" -v max="$MAX_VIDEO_KBPS" \
        'BEGIN { v = int(mb * 8192 * 0.95 / dur) - audio; if (v > max) v = max; print v }')

    if [ "$video_kbps" -lt "$MIN_VIDEO_KBPS" ]; then
        echo "Error: $input is too long to fit in ${SIZE_MB} MB with acceptable quality." >&2
        echo "       Try a larger limit (e.g. -s 64) and send it as a document." >&2
        return 1
    fi

    # Dimensions must be even for H.264. On tight bitrates, first bring the
    # short side down to 720 px (never upscaling); -2 keeps the ratio.
    local filter="scale=trunc(iw/2)*2:trunc(ih/2)*2"
    if [ "$video_kbps" -lt "$DOWNSCALE_KBPS" ]; then
        filter="scale='if(gt(iw,ih),-2,min(720,iw))':'if(gt(iw,ih),min(720,ih),-2)',$filter"
    fi

    echo "Converting: $input"
    echo "        to: $output (video ${video_kbps} kb/s, limit ${SIZE_MB} MB)"

    # -crf 23 sets the quality, -maxrate caps it so the size limit holds.
    # yuv420p + high@4.1 play on every phone; faststart lets playback begin
    # before the whole file has loaded.
    ffmpeg -nostdin "$OVERWRITE" -v error -stats -i "$input" \
        -vf "$filter" \
        -c:v libx264 -preset medium -crf 23 \
        -maxrate "${video_kbps}k" -bufsize "$((video_kbps * 2))k" \
        -profile:v high -level 4.1 -pix_fmt yuv420p \
        -c:a aac -b:a "${AUDIO_KBPS}k" -ar 44100 \
        -movflags +faststart \
        "$output"

    local bytes
    bytes=$(stat -f%z "$output" 2>/dev/null || stat -c%s "$output")
    echo "Done: $(awk -v b="$bytes" 'BEGIN { printf "%.1f", b / 1048576 }') MB"
}

failed=0
for input in "$@"; do
    if [ -n "$OUTPUT" ]; then
        output="$OUTPUT"
    else
        case "$input" in
            *.mp4|*.MP4) output="${input%.*}-whatsapp.mp4" ;;
            *)           output="${input%.*}.mp4" ;;
        esac
    fi
    convert "$input" "$output" || failed=1
done

exit $failed
