// .ci/scripts/build_web.sh
#!/bin/bash
set -e

echo "🌐 Building Web..."

# Temizle
flutter clean

# Paketleri yükle
flutter pub get

# Web build
echo "📦 Building Web Release..."
flutter build web --release

# Build boyutunu kontrol et
echo "📊 Build Size:"
du -sh build/web/

echo "✅ Web Build Complete!"
