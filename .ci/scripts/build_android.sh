#!/bin/bash
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}🤖 Building Android...${NC}"

# Parse arguments
FLAVOR=${1:-production}
BUILD_TYPE=${2:-release}
BUILD_NUMBER=${3:-$(date +%s)}

echo "Flavor: $FLAVOR"
echo "Build Type: $BUILD_TYPE"
echo "Build Number: $BUILD_NUMBER"

# Clean previous builds
echo -e "${YELLOW}🧹 Cleaning previous builds...${NC}"
flutter clean
rm -rf build/

# Get dependencies
echo -e "${YELLOW}📦 Getting dependencies...${NC}"
flutter pub get

# Run code generation if needed
if [ -f "pubspec.yaml" ] && grep -q "build_runner" pubspec.yaml; then
    echo -e "${YELLOW}⚙️  Running code generation...${NC}"
    flutter pub run build_runner build --delete-conflicting-outputs
fi

# Build based on type
if [ "$BUILD_TYPE" = "release" ]; then
    echo -e "${GREEN}📦 Building Release AAB (Google Play)...${NC}"
    flutter build appbundle \
        --release \
        --flavor $FLAVOR \
        --build-number=$BUILD_NUMBER \
        --obfuscate \
        --split-debug-info=build/app/outputs/symbols
    
    echo -e "${GREEN}📦 Building Release APK (split per ABI)...${NC}"
    flutter build apk \
        --release \
        --flavor $FLAVOR \
        --build-number=$BUILD_NUMBER \
        --split-per-abi \
        --obfuscate \
        --split-debug-info=build/app/outputs/symbols
    
elif [ "$BUILD_TYPE" = "debug" ]; then
    echo -e "${YELLOW}🔧 Building Debug APK...${NC}"
    flutter build apk \
        --debug \
        --flavor $FLAVOR \
        --build-number=$BUILD_NUMBER
else
    echo -e "${RED}❌ Unknown build type: $BUILD_TYPE${NC}"
    exit 1
fi

# Display build info
echo -e "${GREEN}✅ Android Build Complete!${NC}"
echo -e "${GREEN}📊 Build Information:${NC}"

if [ "$BUILD_TYPE" = "release" ]; then
    echo "AAB:"
    ls -lh build/app/outputs/bundle/${FLAVOR}Release/*.aab 2>/dev/null || echo "No AAB found"
    
    echo ""
    echo "APKs:"
    ls -lh build/app/outputs/flutter-apk/*.apk 2>/dev/null || echo "No APK found"
    
    # Check APK sizes
    for apk in build/app/outputs/flutter-apk/*.apk; do
        if [ -f "$apk" ]; then
            size=$(du -h "$apk" | cut -f1)
            echo "  - $(basename $apk): $size"
            
            # Warning if APK > 50MB
            size_bytes=$(stat -f%z "$apk" 2>/dev/null || stat -c%s "$apk")
            if [ $size_bytes -gt 52428800 ]; then
                echo -e "  ${YELLOW}⚠️  Warning: APK size exceeds 50MB${NC}"
            fi
        fi
    done
else
    echo "Debug APK:"
    ls -lh build/app/outputs/flutter-apk/*.apk 2>/dev/null || echo "No APK found"
fi

echo -e "${GREEN}🎉 Build process completed successfully!${NC}"
