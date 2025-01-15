#!/bin/bash

# Ensure to install FontTools:
#   pip install fonttools

SOURCE_FONT_DIR=./Fonts
SDK_FONT_DIR=./Virtusize/Sources/Resources/Fonts
LOCALIZATION_DIR=./VirtusizeCore/Sources/Resources/Localizations

# Rename the font file name and it's metadata to ensure they match.
# The inner font name change is important, so it can be loaded as:
#   let font = UIFont(name: "NewFontName") 
rename_font() {
  local font_dir="$1"
  local font="$2"
  
  local font_name=$(basename "$font" .ttf)
  local new_name="Subset-$font_name"

  # Extract TTX XML
  ttx -q "$font_dir/$font"
  local ttx_file="$font_dir/$font_name.ttx"

  # Rename Font inside the TTX file
  sed -i '' "s/$font_name/$new_name/g" "$ttx_file"

  # Re-generate font
  ttx -q -o "$font_dir/$new_name.ttf" "$ttx_file"

  # Clean up TTX file
  rm "$ttx_file"

  # Clean up original font file
  rm "$font_dir/$font"

  echo "Font renamed: $new_name"
}

# Reduce font size by using only the characters from the localization files.
# The font is copied into the Virtusize Resources directory
# The font is also renamed (file and metadata), to ensure it's properly loaded by the iOS
generate_subset_font() {
  local font="$1"
  local language="$2"

  echo "Processing '$font' ..."

  # create subset font
  pyftsubset ${SOURCE_FONT_DIR}/${font} \
    --output-file=${SDK_FONT_DIR}/${font} \
    --unicodes=U+0020-007E \
    --text-file=${LOCALIZATION_DIR}/${language}.lproj/VirtusizeLocalizable.strings

  # rename font
  rename_font ${SDK_FONT_DIR} ${font}
}

# Japanese Regular
generate_subset_font NotoSansJP-Regular.ttf ja

# Japanese Bold
generate_subset_font NotoSansJP-Bold.ttf ja

# Korean Regular
generate_subset_font NotoSansKR-Regular.ttf ko

# Korean Bold
generate_subset_font NotoSansKR-Bold.ttf ko