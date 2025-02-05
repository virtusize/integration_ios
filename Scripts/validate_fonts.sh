#!/bin/bash

FONTS_DIR=./Virtusize/Sources/Resources/Fonts
LOCALIZATION_DIR=./VirtusizeCore/Sources/Resources/Localizations
TMP_DIR=./.build/tmp/font
SKIP_CHARS=("0000c6d0") # skip '%' symbol, as it breaks the parsing

# Strategy:
#   1. Fetch all the glyphs from the font file
#   2. Prepare a list of unique unicode characters supported by font
#   3. Prepare a list of unique unicode characters used in localisation file
#   4. Compare lists
#
# Note:
#   Unfortuntely, old bash version doesn't support a feature 
#   when `echo '\ub6c7'` converts encoded symbol into actual character.
#   If it would, we could simply convert TTX unicodes into characters and
#   compare with localization files.
#
#   Instead, to ensure the script runs everywhere, we convert both - localization characters
#   and font subset glyphs into UTF-32 format: \U0000aaaa
#   And match those. Which works.
validate_font_symbols() {
    local font_file=$1
    local text_file=$2

    # Make TMP directory to save intermidiate files
    mkdir -p $tmp_dir

    # Prepare the unicode lists from both, localization file and font subset
    {
        # Extract Font metadata
        ttx -q -t cmap -o $TMP_DIR/font.ttx $font_file

        # Prepare Expected characters
        grep -o . $text_file | sort | uniq > $TMP_DIR/text_chars.txt

        # Convert Font glyphs into list of unicodes in a UTF-32 format: \U12345678
        awk -F'"' '/<map code=/{print $2}' $TMP_DIR/font.ttx | sort | uniq | while IFS= read -r code; do
            hex="$(printf '%08x' "$((code))")"
            echo "\\U$hex"
        done > $TMP_DIR/font_unicodes.txt

        # Convert Text characters into list of unicodes in a UTF-32 format: \U12345678
        while IFS= read -r char; do
            hex="$(printf "$char" | iconv -f UTF-8 -t UTF-32BE | xxd -p)"
            # Skip some characters
            if [[ " ${SKIP_CHARS[@]} " =~ " $hex " ]]; then
                continue
            fi
            echo "\\U$hex"
        done < $TMP_DIR/text_chars.txt | tee > $TMP_DIR/text_unicodes.txt
    }

    # Validate all the necessary Unicode characters are preset in the font subset
    {
        local missing=0

        # Check if each Unicode in text_unicodes.txt is present in the font_unicodes.txt
        while IFS= read -r unicode; do
            if ! grep -q "$unicode" $TMP_DIR/font_unicodes.txt; then
                echo "Missing character: $unicode"
                missing=1
            fi
        done < $TMP_DIR/text_unicodes.txt

        # Output the result
        if [ $missing -eq 0 ]; then
            echo "SUCCESS: Localization texts are fully supported by the font '$(basename "$font_file")'."
        else
            echo "ERROR: Localization file '$text_file' is NOT fully supported by the font '$(basename "$font_file")'. See missing characters above."
            exit 1
        fi    
    }

}

# Wrapper function 
validate_font() {
  local font=$1
  local language=$2

  # Make TMP directory to save intermidiate files
  mkdir -p $TMP_DIR

  # Merge local strings with remote json-strings and use this merged file for validation
  local text_file="$TMP_DIR/strings_$language.txt"
  cp "$LOCALIZATION_DIR/$language.lproj/VirtusizeLocalizable.strings" $text_file
  curl "https://i18n.virtusize.com/stg/bundle-payloads/aoyama/${language}" >> $text_file

  validate_font_symbols "$FONTS_DIR/$font" $text_file

  # Clean up tmp directory
  rm -r $tmp_dir
}


# Japanese Regular
validate_font Subset-NotoSansJP-Regular.ttf ja

# Japanese Bold
validate_font Subset-NotoSansJP-Bold.ttf ja

# Korean Regular
validate_font Subset-NotoSansKR-Regular.ttf ko

# Korean Bold
validate_font Subset-NotoSansKR-Bold.ttf ko
