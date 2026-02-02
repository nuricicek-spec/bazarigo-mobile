// .ci/scripts/build_android.sh
#!/bin/bash
set -e

echo "🤖 Building Android..."

# Temizle
flutter clean

# Paketleri yükle
flutter pub get

# Release build
echo "📦 Building AAB (Play Store)..."
flutter build appbundle --release

# Debug build (test için)
echo "🔧 Building APK (Debug)..."
flutter build apk --debug

# Build bilgilerini göster
echo "✅ Android Build Complete!"
ls -la build/app/outputs/
