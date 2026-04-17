#!/data/data/com.termux/files/usr/bin/bash

# ==========================================
# LUSTRO: Universal Storage-to-Container Runner
# ==========================================

# 1. Directory Definitions
ORIGIN="$PWD"
PROJECT_NAME=$(basename "$ORIGIN")
CONTAINER_DIR="$HOME/container/$PROJECT_NAME"

# --- SAFETY GUARD ---
if [[ "$ORIGIN" == "/storage/emulated/0" || "$ORIGIN" == "/sdcard" || "$ORIGIN" == "$HOME" ]]; then
    echo -e "\033[31m[!] ERROR: Cannot run Lustro in root storage or Home directory.\033[0m"
    exit 1
fi

# File Counter & Confirmation
FILE_COUNT=$(find "$ORIGIN" -maxdepth 2 -type f | wc -l)
if [ "$FILE_COUNT" -gt 50 ]; then
    echo -e "\033[33m[!] WARNING: $FILE_COUNT files detected. Sync might be slow. Continue? (y/n): \033[0m"
    read -r response
    if [[ "$response" != "y" && "$response" != "Y" ]]; then
        echo "Operation aborted by user."
        exit 0
    fi
fi

# Setup & Mirroring
mkdir -p "$CONTAINER_DIR"
echo -e "[STATUS] \033[34mLustro:\033[0m Mirroring project to secure container..."

# Mirroring logic: Syncing files while excluding build targets
rsync -avz --delete --exclude 'target/' --exclude '.git/' "$ORIGIN/" "$CONTAINER_DIR/"

# Enter Execution Environment
cd "$CONTAINER_DIR"
echo -e "\n[STATUS] \033[32mExecuting program...\033[0m"

# Language Detection & Execution Logic
if [ -f "Cargo.toml" ]; then
    echo -e "[INFO] \033[36mDetected: Rust (Cargo Project)\033[0m"
    echo -e "————————————————————————————————————\n"
    cargo run
elif [ -f "$(ls *.rs 2>/dev/null | head -n 1)" ]; then
    FILE_RS=$(ls *.rs 2>/dev/null | head -n 1)
    echo -e "[INFO] \033[36mDetected: Rust Single File ($FILE_RS)\033[0m"
    echo -e "————————————————————————————————————\n"
    rustc "$FILE_RS" -o app && ./app
elif [ -f "$(ls *.cpp 2>/dev/null | head -n 1)" ]; then
    FILE_CPP=$(ls *.cpp 2>/dev/null | head -n 1)
    echo -e "[INFO] \033[36mDetected: C++ ($FILE_CPP)\033[0m"
    echo -e "————————————————————————————————————\n"
    clang++ "$FILE_CPP" -o app && ./app
elif [ -f "$(ls *.c 2>/dev/null | head -n 1)" ]; then
    FILE_C=$(ls *.c 2>/dev/null | head -n 1)
    echo -e "[INFO] \033[36mDetected: C ($FILE_C)\033[0m"
    echo -e "————————————————————————————————————\n"
    clang "$FILE_C" -o app && ./app
else
    echo -e "\033[31m[ERROR] No executable Rust, C, or C++ files found.\033[0m\n"
    echo -e "————————————————————————————————————\n"
fi

EXIT_CODE=$?

# Return to Origin
cd "$ORIGIN"
echo -e "\n————————————————————————————————————"
echo -e "[\033[93mSUCCESS\033[0m] Process finished with exit code: $EXIT_CODE"
