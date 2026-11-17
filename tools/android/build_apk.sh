#!/usr/bin/env bash
# Bip için imzalı Android APK üretir. Her APK aynı anahtarla imzalanır ve
# sürüm kodu her seferinde büyür; bu yüzden telefondaki eski sürümün ÜSTÜNE kurulur.
#
# Kullanım:  tools/android/build_apk.sh
# Ortam değişkenleri:
#   GODOT          Godot 4.7 çalıştırılabilir dosyası (varsayılan: godot)
#   BIP_KEYSTORE   imza anahtarı (varsayılan: tools/android/keystore/bip-release.p12)
#   BIP_KEY_PASS   anahtar şifresi (varsayılan: tools/android/keystore/password.txt içeriği)
#   APKSIG_JAR     apksig kütüphanesi (yoksa Maven Central'dan indirilir)
set -euo pipefail
cd "$(dirname "$0")/../.."

GODOT="${GODOT:-godot}"
KS="${BIP_KEYSTORE:-tools/android/keystore/bip-release.p12}"
PASS="${BIP_KEY_PASS:-$(cat tools/android/keystore/password.txt 2>/dev/null || true)}"
CACHE="${XDG_CACHE_HOME:-$HOME/.cache}/bip-build"
APKSIG_JAR="${APKSIG_JAR:-$CACHE/apksig-2.3.0.jar}"

[ -f "$KS" ] || { echo "HATA: imza anahtarı yok: $KS (bkz. tools/android/README.md)"; exit 1; }
[ -n "$PASS" ] || { echo "HATA: anahtar şifresi yok"; exit 1; }

# 1) apksig (Google'ın APK imzalama kütüphanesi)
if [ ! -f "$APKSIG_JAR" ]; then
  mkdir -p "$(dirname "$APKSIG_JAR")"
  curl -sSL -o "$APKSIG_JAR" https://repo1.maven.org/maven2/com/android/tools/build/apksig/2.3.0/apksig-2.3.0.jar
fi

# 2) Godot, Android SDK yolunda adb/apksigner dosyalarını arıyor. Gerçek SDK yoksa
#    boş yer tutucular oluştur (imzalamayı aşağıda kendimiz yapıyoruz).
SETTINGS=$(ls "$HOME"/.config/godot/editor_settings-4.*.tres 2>/dev/null | tail -1 || true)
if [ -z "$SETTINGS" ]; then
  "$GODOT" --headless --path . --quit >/dev/null 2>&1 || true
  SETTINGS=$(ls "$HOME"/.config/godot/editor_settings-4.*.tres | tail -1)
fi
SDK=$(grep -oP '^export/android/android_sdk_path = "\K[^"]*' "$SETTINGS" || true)
if [ -z "$SDK" ] || [ ! -d "$SDK/build-tools" ]; then
  SDK="$CACHE/placeholder-sdk"
  mkdir -p "$SDK/platform-tools" "$SDK/build-tools/35.0.0"
  for f in "$SDK/platform-tools/adb" "$SDK/build-tools/35.0.0/apksigner"; do
    printf '#!/bin/sh\nexit 1\n' > "$f"; chmod +x "$f"
  done
  if grep -q '^export/android/android_sdk_path' "$SETTINGS"; then
    sed -i "s|^export/android/android_sdk_path = .*|export/android/android_sdk_path = \"$SDK\"|" "$SETTINGS"
  else
    echo "export/android/android_sdk_path = \"$SDK\"" >> "$SETTINGS"
  fi
fi

# 3) Sürüm: kod = commit sayısı (her commit'te büyür), ad = 0.<kilometre taşı>.<kod>
CODE=$(git rev-list --count HEAD)
MILESTONE=$(cat tools/android/milestone.txt 2>/dev/null || echo 1)
NAME="0.${MILESTONE}.${CODE}"
sed -i "s/^version\/code=.*/version\/code=${CODE}/; s/^version\/name=.*/version\/name=\"${NAME}\"/" export_presets.cfg

# 4) Dışa aktar (imzasız) ve imzala
mkdir -p build
rm -f build/Bip-unsigned.apk
"$GODOT" --headless --path . --export-release Android build/Bip-unsigned.apk 2>&1 | grep -E "ERROR|HATA" || true
[ -f build/Bip-unsigned.apk ] || { echo "HATA: Godot APK üretemedi"; exit 1; }

OUT="build/Bip-${NAME}.apk"
java --add-exports java.base/sun.security.x509=ALL-UNNAMED \
     --add-exports java.base/sun.security.pkcs=ALL-UNNAMED \
     --add-exports java.base/sun.security.util=ALL-UNNAMED \
     -cp "$APKSIG_JAR" tools/android/ApkSign.java "$KS" "$PASS" bip build/Bip-unsigned.apk "$OUT" 2>&1 | grep -v JAVA_TOOL_OPTIONS
rm -f build/Bip-unsigned.apk
echo "Hazır: $OUT  (versionCode=$CODE)"
