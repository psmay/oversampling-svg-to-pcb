#!/bin/bash

log () {
	echo "$@" >&2
}

die_code () {
	code="$1"
	shift
	log "$@"
	exit "$code"
}

die () {
	die_code 2 "$@"
}

if [ "-$FACTOR-" = "--" ]; then
	FACTOR=100
fi
FACTOR="`expr $FACTOR + 0`" || die "FACTOR must be a number"

WORK="`mktemp -d`" || die "Failed to create temp directory"

RELATIVE_SCRIPT_PATH="$(realpath "${BASH_SOURCE[0]}")"
RELATIVE_DIR="$(dirname "$RELATIVE_SCRIPT_PATH")"
SCRIPT_DIR="$(cd "$RELATIVE_DIR" && pwd)"

ENLARGE_SVG_XSL="$SCRIPT_DIR/enlarge-svg.xsl"
EXTRACT_POLYGONS_TO_NM_JSON="$SCRIPT_DIR/extract-polygons-to-nm-json.pl"
FORMAT_POLYGONS_FROM_NM_JSON="$SCRIPT_DIR/format-polygons-from-nm-json.pl"
ORIGINAL_SVG="$WORK/0_original.svg"
MAGNIFIED_SVG="$WORK/1_magnified.svg"
MAGNIFIED_EPS="$WORK/2_magnified.eps"
MAGNIFIED_PCB="$WORK/3_magnified.pcb"
MAGNIFIED_JSON="$WORK/4_magnified-polygons-nm-scale.json"
CORRECTED_PCB="$WORK/5_corrected.pcb"

log "Reading original SVG" &&
cat > "$ORIGINAL_SVG" &&
log "Scaling to $FACTOR x" &&
xsltproc --param factor "$FACTOR" "$ENLARGE_SVG_XSL" "$ORIGINAL_SVG" > "$MAGNIFIED_SVG" &&
log "Exporting to EPS" &&
inkscape --without-gui --file "$MAGNIFIED_SVG" --export-eps "$MAGNIFIED_EPS" &&
log "Converting to PCB" &&
pstoedit -f "pcb:-forcepoly -mm -stdnames" "$MAGNIFIED_EPS" > "$MAGNIFIED_PCB" &&
log "Extracting nm-scale polygons to JSON" &&
"$EXTRACT_POLYGONS_TO_NM_JSON" < "$MAGNIFIED_PCB" > "$MAGNIFIED_JSON" &&
log "Formatting polygons to new PCB" &&
"$FORMAT_POLYGONS_FROM_NM_JSON" < "$MAGNIFIED_JSON" > "$CORRECTED_PCB" &&
log "Writing PCB file to stdout" &&
cat "$CORRECTED_PCB" &&
log "Removing temp files" &&
rm -rf "$WORK" &&
log "Done"
