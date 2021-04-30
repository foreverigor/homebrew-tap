#!/bin/bash

# ghidra-jar2app.sh | macOS standalone App Bundle creator for Ghidra
# Requires JDK 14+ or 11+ with jpackage available
#
# Arguments:
# $1 – Path to Ghidra single jar
# $2 – Working directory (optional)
# Example: ./ghidra-jar2app.sh <ghidra-jar>

if [ ! -f "$1" ]; then echo "ghidra jar not found!" >/dev/stderr; exit 1; fi
DIR=$2
if [ -z "$2" ]; then DIR="."; fi
GHIDRA="Ghidra"
GHIDRA_FILE=$1
GHIDRA_DIR="$DIR/$GHIDRA"
GHIDRA_JAR="ghidra.jar"

#### Extract icon & create icns:
ICON="$DIR/ghidraIcon.png"
ICONSET="$DIR/$GHIDRA.iconset"
GHIDRA_ICNS="$DIR/$GHIDRA.icns"
echo "Extracting icon"
unzip -p "$GHIDRA_FILE" images/GhidraIcon256.png > "$ICON"

mkdir "$ICONSET"
sips -z 16 16     "$ICON" --out "$ICONSET"/icon_16x16.png
sips -z 32 32     "$ICON" --out "$ICONSET"/icon_16x16@2x.png
sips -z 32 32     "$ICON" --out "$ICONSET"/icon_32x32.png
sips -z 64 64     "$ICON" --out "$ICONSET"/icon_32x32@2x.png
sips -z 128 128   "$ICON" --out "$ICONSET"/icon_128x128.png
sips -z 256 256   "$ICON" --out "$ICONSET"/icon_128x128@2x.png
sips -z 256 256   "$ICON" --out "$ICONSET"/icon_256x256.png
sips -z 512 512   "$ICON" --out "$ICONSET"/icon_256x256@2x.png
sips -z 512 512   "$ICON" --out "$ICONSET"/icon_512x512.png
mv "$ICON" "$ICONSET/icon_512x512@2x.png"
iconutil -c icns "$ICONSET"
rm -r "$ICONSET"

VERSION=$(unzip -p "$GHIDRA_FILE" _Root/Ghidra/application.properties | grep 'application.version' | sed "s/application.version=//")

# Order in which we search for java: explicit search for 14+ -> JAVA_HOME -> java_home (default one)
JAVA_BIN=$(/usr/libexec/java_home --failfast -v 14+)
if [ -n "$JAVA_BIN" ]; then
  JAVA_BIN="$JAVA_BIN/bin";
elif [ -n "$JAVA_HOME" ]; then
  JAVA_BIN="$JAVA_HOME/bin";
else
  JAVA_BIN="$(/usr/libexec/java_home)/bin";
fi

mkdir -p "$GHIDRA_DIR"
mv "$GHIDRA_FILE" "$GHIDRA_DIR/$GHIDRA_JAR"

JPACKAGE_OPTS="--type app-image --name Ghidra --mac-package-identifier org.ghidra-sre.Ghidra"
if [ -n "$VERSION" ]; then JPACKAGE_OPTS="$JPACKAGE_OPTS --app-version $VERSION"; fi
if [ -f $GHIDRA_ICNS ]; then JPACKAGE_OPTS="$JPACKAGE_OPTS --icon $GHIDRA_ICNS"; fi
JPACKAGE_OPTS="$JPACKAGE_OPTS --input $GHIDRA_DIR --main-jar $GHIDRA_JAR --main-class ghidra.JarRun"
JPACKAGE_OPTS="$JPACKAGE_OPTS --dest $DIR --java-options '--illegal-access=permit' --java-options -Dapple.laf.useScreenMenuBar=true --arguments -gui"

### Run jpackage:
echo "Running jpackage"
"${JAVA_BIN}"/jpackage $JPACKAGE_OPTS

# References:
# https://gist.github.com/saagarjha/777909b257dbfa98649476b7f5af41bb (useScreenMenuBar flag)
# https://gist.github.com/fuzyll/4db8aa6e6a00cb1a60630370236aab4b (icon extraction)
# https://www.baeldung.com/java14-jpackage (jpackage example)
