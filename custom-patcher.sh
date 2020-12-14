#!/bin/bash

#-------------------------------------------------------------------------------
# FORMAT
#-------------------------------------------------------------------------------
declare -A FMT         # (R,G,B)
FMT[k]=$(tput setaf 0) # (0,0,0) Black
FMT[r]=$(tput setaf 1) # (1,0,0) Red
FMT[g]=$(tput setaf 2) # (0,1,0) Green
FMT[y]=$(tput setaf 3) # (1,1,0) Yellow
FMT[b]=$(tput setaf 4) # (0,0,1) Blue
FMT[m]=$(tput setaf 5) # (1,0,1) Magenta
FMT[c]=$(tput setaf 6) # (0,1,1) Cyan
FMT[w]=$(tput setaf 7) # (1,1,1) White
FMT[s]=$(tput bold) # Strong
FMT[t]=$(tput dim)  # Transparent
FMT[z]=$(tput sgr0) # Reset
#-------------------------------------------------------------------------------
# FUNCTIONS
#-------------------------------------------------------------------------------
function NewLine {
    echo ""
}
#-------------------------------------------------------------------------------
function Error {
    echo "${FMT[s]}${FMT[r]}Error:${FMT[z]} $1" >&2
    exit 1
}
#-------------------------------------------------------------------------------
function UsageError {
    echo "${FMT[s]}${FMT[r]}Usage error:${FMT[z]} $1" >&2
    NewLine
    echo "${FMT[s]}${FMT[y]}USAGE:${FMT[z]}"
    echo "    $0 [OPTIONS] <ARGS>"
    NewLine
    echo "For more information try ${FMT[g]}--help${FMT[z]}"
    exit 0
}
#-------------------------------------------------------------------------------
function DisplayUsage {
    echo -e "${FMT[s]}${FMT[g]}wham ${FMT[b]}0.1.0${FMT[z]}"
    echo -e "Patch fonts using nerdfont utility."
    NewLine
    echo -e "${FMT[s]}${FMT[y]}USAGE:${FMT[z]}"
    echo -e "    ./custom-patcher.sh [OPTIONS] <ARGS>"
    NewLine
    echo -e "${FMT[s]}${FMT[y]}OPTIONS${FMT[z]}"
    echo -e "${FMT[s]}${FMT[g]}    -o, --output-dir <PATH>${FMT[z]}"
    echo -e "\tOutput directory for patched fonts (Default: ./out)."
    NewLine
    echo -e "${FMT[s]}${FMT[g]}    --out-name <ARG>${FMT[z]}"
    echo -e "\tFont output name (Default: font-patcher output)."
    NewLine
    echo -e "${FMT[s]}${FMT[g]}    -h, --help${FMT[z]}"
    echo -e "\tPrint this information."
    NewLine
    echo -e "${FMT[s]}${FMT[y]}ARGS${FMT[z]}"
    echo -e "\t${FMT[s]}${FMT[g]}<PATH>${FMT[z]}"
    echo -e "\tPath to font to be patched."
    NewLine
}
#-------------------------------------------------------------------------------
# Argument parser
#-------------------------------------------------------------------------------
#*******************************************************************************
echo -n "${FMT[s]}[  ] Parsing arguments...${FMT[z]}"
#*******************************************************************************
declare -x ARGS_OUTPUT_DIR="./out"
while [ "$#" -gt 0 ]; do
    case "$1" in
        # Output directory
        -o|--output-dir)
            if [ -n "$2" ] && [ ${2:0:1} != "-" ]; then
                declare -r ARGS_OUTPUT_DIR="$2"
                shift 2
            else
                UsageError "Argument for ${FMT[s]}${1}${FMT[z]} is missing"
            fi
            ;;
        # Out name
        --out-name)
            if [ -n "$2" ] && [ ${2:0:1} != "-" ]; then
                declare -r ARGS_OUT_NAME="$2"
                shift 2
            else
                UsageError "Argument for ${FMT[s]}${1}${FMT[z]} is missing"
            fi
            ;;
        # help flag
        -h|--help)
            DisplayUsage
            exit 0
            ;;
        # Unknown flags
        -*|--*)
            UsageError "Unsoported flag $1"
            ;;
        # Positional arguments
        *)
            if [ -v ARGS_PATH ]; then
                UsageError "Unexpected argument: ${FMT[s]}${1}${FMT[z]}"
            fi
            declare -r ARGS_PATH="${1}"
            shift
            ;;
    esac
done
#*******************************************************************************
echo -e "\r${FMT[s]}[${FMT[g]}OK${FMT[z]}${FMT[s]}] Parsing arguments${FMT[z]}"
#*******************************************************************************
#-------------------------------------------------------------------------------
# Validate arguments
#-------------------------------------------------------------------------------
#*******************************************************************************
echo -n "${FMT[s]}[  ] Validating arguments...${FMT[z]}"
#*******************************************************************************
if [[ ! -v ARGS_PATH ]]; then
    UsageError "Missing argument: ${FMT[s]}${FMT[g]}<PATH>${FMT[z]}"
elif [[ ! -f $ARGS_PATH ]]; then
    Error "Invalid path: ${FMT[s]}${ARGS_PATH}${FMT[z]}"
fi

if [[ ! -v ARGS_OUTPUT_DIR ]]; then
    declare -r  ARGS_OUTPUT_DIR="$(pwd)/out"
fi

case "${ARGS_PATH^^}" in
    *"BLACK"*|*"BOLD"*|*"SEMIBOLD"*)
        declare -r FONT_AWESOME_1="font-awesome-6-pro-solid-900.otf"
        ;;
    *"MEDIUM"*|*"REGULAR"*)
        declare -r FONT_AWESOME_1="font-awesome-6-pro-regular-400.otf"
        ;;
    *"THIN"*|*"EXTRALIGHT"*)
        declare -r FONT_AWESOME_1="font-awesome-6-pro-thin-100.otf"
        ;;
    *"LIGHT"*)
        declare -r FONT_AWESOME_1="font-awesome-6-pro-light-300.otf"
        ;;
esac

declare -r FONT_AWESOME_2="font-awesome-6-duotone-solid-900.otf"
declare -r FONT_AWESOME_3="font-awesome-6-brands-regular-400.otf"

#*******************************************************************************
echo -e "\r${FMT[s]}[${FMT[g]}OK${FMT[z]}${FMT[s]}] Validating arguments...${FMT[z]}"
#*******************************************************************************
#-------------------------------------------------------------------------------
# Patch fonts
#-------------------------------------------------------------------------------
#*******************************************************************************
#echo -n "${FMT[s]}[  ] Patching fonts...${FMT[z]}"
#*******************************************************************************
# Create output directory
mkdir -p ${ARGS_OUTPUT_DIR}

# Create temporary working directory
TMP_DIR=$(mktemp -d -t font-patcher-XXXXX)
declare -r PATCH_1="${TMP_DIR}/PATCH_1"; mkdir -p "${PATCH_1}"
declare -r PATCH_2="${TMP_DIR}/PATCH_2"; mkdir -p "${PATCH_2}"
declare -r PATCH_3="${TMP_DIR}/PATCH_3"; mkdir -p "${PATCH_3}"
declare -r PATCH_4="${TMP_DIR}/PATCH_4"; mkdir -p "${PATCH_4}"

# Patch with font awesome font
fontforge -script font-patcher --progressbar --careful --custom "${FONT_AWESOME_1}" --out ${PATCH_1} "${ARGS_PATH}" 2>/dev/null
declare -r OUT_1="$(ls $PATCH_1/*)"
fontforge -script font-patcher --progressbar --careful --custom "${FONT_AWESOME_2}" --out ${PATCH_2} "${OUT_1}" 2>/dev/null
declare -r OUT_2="$(ls $PATCH_2/*)"
fontforge -script font-patcher --progressbar --careful --custom "${FONT_AWESOME_3}" --out ${PATCH_3} "${OUT_2}" 2>/dev/null
declare -r OUT_3="$(ls $PATCH_3/*)"

# Patch with nerd fonts
if [[ -v  ARGS_OUT_NAME ]]; then
    fontforge -script font-patcher --progressbar --careful --powerline --powerlineextra \
        --weather --octicons --pomicons --powersymbols --fontlinux \
        --font-custom-name "${ARGS_OUT_NAME}" --out ${PATCH_4} "${OUT_3}"
#        --out ${PATCH_4} "${OUT_3}" 2>/dev/null
else
    fontforge -script font-patcher --progressbar --careful --powerline --powerlineextra \
        --weather --octicons --pomicons --powersymbols --fontlinux --out ${PATCH_4} \
        "${OUT_3}" 2>/dev/null
fi
declare -r OUT_4="$(ls $PATCH_4/*)"

# Place patched font in output directory
mv "${OUT_4}" "${ARGS_OUTPUT_DIR}/$(basename ${ARGS_PATH})"

# Cleal temporary directory
rm -rf "${TMP_DIR}"
#*******************************************************************************
echo -e "\r${FMT[s]}[${FMT[g]}OK${FMT[z]}${FMT[s]}] Patching fonts...${FMT[z]}"
#*******************************************************************************
