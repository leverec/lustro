#!/data/data/com.termux/files/usr/bin/bash

# ==========================================
# LUSTRO: Universal Storage-to-Container Runner
# ==========================================

ORIGIN="$PWD"
PROJECT_NAME=$(basename "$ORIGIN")
CONTAINER_DIR="$HOME/container/$PROJECT_NAME"

# --- SAFETY GUARD ---
if [[ "$ORIGIN" == "/storage/emulated/0" || "$ORIGIN" == "/sdcard" || "$ORIGIN" == "$HOME" ]]; then
    echo -e "\033[31m[!] ERROR: Jangan jalankan di root storage atau Home langsung, Brother!\033[0m"
    exit 1
fi

# -- FILE COUNT --
FILE_COUNT=$(find "$ORIGIN" -maxdepth 2 -type f | wc -l)
if [ "$FILE_COUNT" -gt 50 ]; then
    echo -e "\033[33m[!] WARNING: there are $FILE_COUNT files in here. Please confirm if you wan [Y/n]: \033[0m"
    read -r jawaban
    if [[ "$answer" != "y" && "$answer" != "Y" ]]; then
        echo "Operation cancelled."
        exit 0
    fi
fi

# -- MIRRORING --
mkdir -p "$CONTAINER_DIR"
echo -e "\033[34mLustro:\033[0m Mirroring project ke container..."

rsync -avz --delete --exclude 'target/' --exclude '.git/' "$ORIGIN/" "$CONTAINER_DIR/"

# -- MOVE TO CONTAINER --
cd "$CONTAINER_DIR"
echo -e "\n🚀 \033[32mExecuting...\033[0m"

# -- DETECT LANGUAGE --
if [ -f "Cargo.toml" ]; then
    echo -e "📦 \033[36mDetected: Rust (Cargo)\033[0m"
    cargo run
elif [ -f "$(ls *.rs 2>/dev/null | head -n 1)" ]; then
    FILE_RS=$(ls *.rs 2>/dev/null | head -n 1)
    echo -e "🦀 \033[36mDetected: Rust Single File ($FILE_RS)\033[0m"
    rustc "$FILE_RS" -o app && ./app
elif [ -f "$(ls *.cpp 2>/dev/null | head -n 1)" ]; then
    FILE_CPP=$(ls *.cpp 2>/dev/null | head -n 1)
    echo -e "🔵 \033[36mDetected: C++ ($FILE_CPP)\033[0m"
    clang++ "$FILE_CPP" -o app && ./app
elif [ -f "$(ls *.c 2>/dev/null | head -n 1)" ]; then
    FILE_C=$(ls *.c 2>/dev/null | head -n 1)
    echo -e "⚪ \033[36mDetected: C ($FILE_C)\033[0m"
    clang "$FILE_C" -o app && ./app
else
    echo -e "\033[31m FileNotFoundError: This folder doesn't has any C/C++/Rust File\033[0m"
fi

EXIT_CODE=$?

# -- BACK TO ORIGINAL FOLDER --
cd "$ORIGIN"
echo -e "\nDone (exit code: $EXIT_CODE)"
