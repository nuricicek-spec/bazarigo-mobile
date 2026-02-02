// .ci/scripts/build_ios.sh
#!/bin/bash
set -e

echo "🍎 Building iOS..."

# Temizle
flutter clean

# Paketleri yükle
flutter pub get

# iOS build
echo "📦 Building IPA..."
flutter build ipa --release

# Simülatör için build
echo "📱 Building for Simulator..."
flutter build ios --debug

echo "✅ iOS Build Complete!"
ls -la build/ios/
