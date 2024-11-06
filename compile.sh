#!/bin/sh

# Define output directory
OUTPUT_DIR="out"
SECTIONS_DIR="sections"

# Check for "clean" argument
if [ "$1" = "clean" ]; then
    # Clean the output directory if it exists
    if [ -d "$OUTPUT_DIR" ]; then
        rm -rf "$OUTPUT_DIR"/*
        echo "Output directory cleaned."
    else
        echo "Output directory does not exist, nothing to clean."
    fi
else
    # Create output directory if it doesn't exist
    [ ! -d "$OUTPUT_DIR" ] && mkdir "$OUTPUT_DIR"
    
    # Check if "sections" directory exists and contains files
    if [ -d "$SECTIONS_DIR" ] && [ "$(ls -A $SECTIONS_DIR)" ]; then
        # Create the "sections" directory inside "out" if it doesn't exist
        [ ! -d "$OUTPUT_DIR/sections" ] && mkdir "$OUTPUT_DIR/sections"
        
        # Loop through all files in the "sections" directory
        for file in $SECTIONS_DIR/*; do
            if [ -f "$file" ]; then
                # Strip the ".tex" extension and create corresponding .aux files inside the "out/sections" directory
                filename_without_ext="${file%.*}"
                touch "$OUTPUT_DIR/sections/$(basename "$filename_without_ext").aux"
            fi
        done
    fi

    # Compile the LaTeX document (double compilation)
    pdflatex -output-directory="$OUTPUT_DIR" main.tex
    pdflatex -output-directory="$OUTPUT_DIR" main.tex

    # Open the PDF automatically if on macOS (uncomment if desired)
    # [ "$(uname)" = "Darwin" ] && open "$OUTPUT_DIR/main.pdf"

    echo "Compilation complete. Output available in $OUTPUT_DIR/"
fi
