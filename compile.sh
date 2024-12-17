#!/bin/sh

# Define output directory
OUTPUT_DIR="out"
PDF_FILE='main.pdf'
SECTIONS_DIR="sections"

# Define color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
RESET='\033[0m'

# Function to remove the main.pdf file in the root directory
remove_root_pdf() {
    if [ -f "$PDF_FILE" ]; then
        rm -f "$PDF_FILE"
        # printf "\n${GREEN}File ${PDF_FILE} removed from root directory.${RESET}\n"
    else
        printf "\n${YELLOW}File ${PDF_FILE} not found in root directory, nothing to remove.${RESET}\n"
    fi
}

# Check for "clean" argument
if [ "$1" = "clean" ]; then
    # Clean the output directory if it exists
    if [ -d "$OUTPUT_DIR" ]; then
        rm -rf "$OUTPUT_DIR"/*
        printf "\n${GREEN}Output directory cleaned.${RESET}\n"
    else
        printf "\n${YELLOW}Output directory does not exist, nothing to clean.${RESET}\n"
    fi

    # Remove main.pdf in the root directory
    remove_root_pdf
else
    # Create output directory if it doesn't exist
    [ ! -d "$OUTPUT_DIR" ] && mkdir "$OUTPUT_DIR" && printf "\n${CYAN}Output directory created.${RESET}\n"
    
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
    
    printf "\n${CYAN}Compiling ...${RESET}\n"

    # Compile the LaTeX document (double compilation)
    pdflatex -output-directory="$OUTPUT_DIR" main.tex
    pdflatex -output-directory="$OUTPUT_DIR" main.tex
    pdflatex -output-directory="$OUTPUT_DIR" main.tex
    
    # Check if the PDF file was generated successfully
    if [ -f "$OUTPUT_DIR/$PDF_FILE" ]; then
        # Remove any existing main.pdf in the root directory
        remove_root_pdf

        # Copy the PDF file to the root directory
        cp "$OUTPUT_DIR/$PDF_FILE" ./
        printf "\n${GREEN}File ${PDF_FILE} copied to root directory.${RESET}\n"
    else
        printf "\n${RED}Compilation failed. ${PDF_FILE} not found in ${OUTPUT_DIR}.${RESET}\n"
    fi

    printf "\n${GREEN}Compilation complete. Output available in ${CYAN}$OUTPUT_DIR/${RESET}\n"
fi
