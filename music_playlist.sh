#!/bin/bash

# Ensure required packages
for cmd in mpv figlet lolcat; do
    command -v $cmd >/dev/null 2>&1 || {
        echo "Installing $cmd..."
        pkg install -y $cmd
    }
done

# Typing effect
type() {
    text="$1"
    for ((i=0; i<${#text}; i++)); do
        echo -n "${text:$i:1}"
        sleep 0.03
    done
    echo
}

clear
figlet -f slant "HACKER JUKEBOX" | lolcat
sleep 1

type "Scanning for target audio files..."
sleep 2

# Common music folders to try
SEARCH_DIRS=(
    "$HOME/storage/shared/Music"
    "$HOME/storage/downloads"
    "/sdcard/Music"
    "/sdcard/Download"
    "$HOME/Music"
    "$HOME/Download"
)

FILES=()

# Search through common dirs
for DIR in "${SEARCH_DIRS[@]}"; do
    if [ -d "$DIR" ]; then
        mapfile -d '' FOUND < <(find "$DIR" -type f \( \
            -iname "*.mp3" -o -iname "*.wav" -o -iname "*.flac" -o \
            -iname "*.m4a" -o -iname "*.ogg" -o -iname "*.opus" \) -print0 2>/dev/null)
        if [ ${#FOUND[@]} -gt 0 ]; then
            FILES+=("${FOUND[@]}")
        fi
    fi
done

# If still no files, ask user
if [ ${#FILES[@]} -eq 0 ]; then
    read -rp "No audio found in common folders. Enter your music folder path: " MUSIC_DIR
    mapfile -d '' FILES < <(find "$MUSIC_DIR" -type f \( \
        -iname "*.mp3" -o -iname "*.wav" -o -iname "*.flac" -o \
        -iname "*.m4a" -o -iname "*.ogg" -o -iname "*.opus" \) -print0 2>/dev/null)
    if [ ${#FILES[@]} -eq 0 ]; then
        type "Still no audio files found. Exiting."
        exit 1
    fi
fi

# Shuffle playlist
SHUFFLED=($(shuf -e "${FILES[@]}"))

type "Found ${#FILES[@]} tracks."
sleep 1
type "Initializing playback sequence..."
sleep 1

# Loop through shuffled playlist
for SONG in "${SHUFFLED[@]}"; do
    clear
    figlet -f slant "NOW PLAYING" | lolcat
    echo "${SONG##*/}" | lolcat
    echo
    type "Decrypting audio stream..."
    for i in $(seq 1 30); do printf "#"; sleep 0.03; done
    echo " Done!"
    sleep 1
    echo
    echo "Controls: ↑/↓ volume | ←/→ seek | q quit | p pause"
    echo "------------------------------------------------------------"

    # Play song with interactive controls
    mpv --input-terminal=yes --really-quiet "$SONG"

    # Pause between tracks
    clear
    figlet -f slant "NEXT TRACK" | lolcat
    sleep 1
done

type "Playlist complete. Mission accomplished."
figlet -f slant "DONE" | lolcat
