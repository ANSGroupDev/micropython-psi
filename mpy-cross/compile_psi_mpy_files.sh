#!/bin/bash
# PLACE THIS SCRIPT IN: micropython-psi/mpy-cross/
# Usage: ./compile_psi_mpy_files.sh -p WINDOWS_PROJECT_PATH -s SRC_DIR [-k "file1.py file2.py ..."]
# Example: ./compile_psi_mpy_files.sh -p /mnt/d/project/psiutils -s src -k "main.py boot.py"

# ./compile_psi_mpy_files.sh -p /mnt/d/GitHub_Repos/ANS_PSI/NEP_PSI/build/NEP_PSI/src -s psiutils -k "main.py boot.py fs_mode.py"

# Function to display usage information
usage() {
    echo "Usage: $0 -p WINDOWS_PROJECT_PATH -s SRC_DIR [-k \"file1.py file2.py ...\"]"
    echo "  -p: Windows project path"
    echo "  -s: Source directory name"
    echo "  -k: Space-separated list of .py files to keep uncompiled (optional)"
    exit 1
}

# Default list of files to keep as .py (not compile to .mpy)
KEEP_PY_FILES="main.py boot.py fs_mode.py"

# Parse command-line options
while getopts "p:s:k:" opt; do
  case ${opt} in
    p )
      WINDOWS_PROJECT_PATH="$OPTARG"
      ;;
    s )
      SRC_DIR="$OPTARG"
      ;;
    k )
      KEEP_PY_FILES="$OPTARG"
      ;;
    * )
      usage
      ;;
  esac
done

# Ensure required options are provided
if [[ -z "$WINDOWS_PROJECT_PATH" || -z "$SRC_DIR" ]]; then
    usage
fi

# Since this script is located in the mpy-cross directory (Micropython source root),
# we assume the current working directory is the micropython source directory.
MPY_CROSS_DIR="$(pwd)"               
MPY_CROSS_BIN="$MPY_CROSS_DIR/build/mpy-cross"
TEMP_SRC_DIR="$MPY_CROSS_DIR/$SRC_DIR"
WINDOWS_SRC_PATH="$WINDOWS_PROJECT_PATH/$SRC_DIR"
BUILD_DIR="$WINDOWS_PROJECT_PATH/pyb_flash"
# BUILD_DIR="$WINDOWS_PROJECT_PATH/../pyb_flash/$SRC_DIR"

# Convert KEEP_PY_FILES string to array
read -ra KEEP_FILES_ARRAY <<< "$KEEP_PY_FILES"

# Remove any existing TEMP_SRC_DIR and create a fresh copy
rm -rf "$TEMP_SRC_DIR"
mkdir -p "$TEMP_SRC_DIR"

# Use rsync to copy the source files recursively from Windows into TEMP_SRC_DIR
echo "Copying source files from $WINDOWS_SRC_PATH to $TEMP_SRC_DIR..."
rsync -av \
    --exclude='__pycache__/' \
    --exclude='__init__.py' \
    --include='*/' \
    --include='*.py' \
    --exclude='*' \
    "$WINDOWS_SRC_PATH/" "$TEMP_SRC_DIR/"

# Change directory to the micropython source root so that file paths are relative.
cd "$MPY_CROSS_DIR" || { echo "Failed to cd into $MPY_CROSS_DIR"; exit 1; }

# Function to check if a file should be kept as .py
is_keep_file() {
    local filename="$1"
    for keep_file in "${KEEP_FILES_ARRAY[@]}"; do
        if [[ "$filename" == "$keep_file" ]]; then
            return 0  # true
        fi
    done
    return 1  # false
}

echo "Starting compilation..."
mkdir -p "$BUILD_DIR"

# Process each Python file
find "$SRC_DIR" -type f -name "*.py" ! -name "__init__.py" | while read -r rel_py; do
    filename=$(basename "$rel_py")
    
    if is_keep_file "$filename"; then
        # Copy .py file directly to build directory
        output_py="$BUILD_DIR/${rel_py#$SRC_DIR/}"
        mkdir -p "$(dirname "$output_py")"
        echo "Copying $rel_py -> $output_py (keeping as .py)"
        cp "$rel_py" "$output_py"
    else
        # Compile to .mpy and copy to build directory
        output_rel="${rel_py%.py}.mpy"
        mkdir -p "$(dirname "$output_rel")"
        
        echo "Compiling $rel_py -> $output_rel"
        "$MPY_CROSS_BIN" "$rel_py" -o "$output_rel"
        
        # Copy .mpy file to build directory
        output_mpy="$BUILD_DIR/${output_rel#$SRC_DIR/}"
        mkdir -p "$(dirname "$output_mpy")"
        cp "$output_rel" "$output_mpy"
    fi
done

echo "Compilation and file copying complete."