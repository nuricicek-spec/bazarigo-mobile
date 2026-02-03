#!/bin/bash
set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}🍎 Building iOS...${NC}"

# Check if running on macOS
if [[ "$OSTYPE" != "darwin"* ]]; then
    echo -e "${RED}❌ iOS builds require macOS${NC}"
    echo -e "${YELLOW}ℹ️  Skipping iOS build on non-macOS platform${NC}"
    exit 0
fi

# Parse arguments
FLAVOR=${1:-production}
BUILD_TYPE=${2:-release}
BUILD_NUMBER=${3:-$(date +%s)}
EXPORT_METHOD=${4:-app-store}

echo "Flavor: $FLAVOR"
echo "Build Type: $BUILD_TYPE"
echo "Build Number: $BUILD_NUMBER"
echo "Export Method: $EXPORT_METHOD"

# Clean
echo -e "${YELLOW}🧹 Cleaning...${NC}"
flutter clean
rm -rf build/ios

# Get dependencies
echo -e "${YELLOW}📦 Getting dependencies...${NC}"
flutter pub get

# CocoaPods
echo -e "${YELLOW}📦 Installing CocoaPods...${NC}"
cd ios
pod install --repo-update
cd ..

# Run code generation
if [ -f "pubspec.yaml" ] && grep -q "build_runner" pubspec.yaml; then
    echo -e "${YELLOW}⚙️  Running code generation...${NC}"
    flutter pub run build_runner build --delete-conflicting-outputs
fi

# Build
if [ "$BUILD_TYPE" = "release" ]; then
    echo -e "${GREEN}📦 Building Release IPA...${NC}"
    flutter build ipa \
        --release \
        --flavor $FLAVOR \
        --build-number=$BUILD_NUMBER \
        --export-method=$EXPORT_METHOD \
        --obfuscate \
        --split-debug-info=build/ios/symbols
    
elif [ "$BUILD_TYPE" = "debug" ]; then
    echo -e "${YELLOW}📱 Building for Simulator (Debug)...${NC}"
    flutter build ios \
        --debug \
        --flavor $FLAVOR \
        --build-number=$BUILD_NUMBER \
        --simulator
else
    echo -e "${RED}❌ Unknown build type: $BUILD_TYPE${NC}"
    exit 1
fi

# Build info
echo -e "${GREEN}✅ iOS Build Complete!${NC}"
echo -e "${GREEN}📊 Build Information:${NC}"

if [ "$BUILD_TYPE" = "release" ]; then
    if [ -d "build/ios/ipa" ]; then
        echo "IPA files:"
        ls -lh build/ios/ipa/*.ipa 2>/dev/null || echo "No IPA found"
        
        # Check IPA size
        for ipa in build/ios/ipa/*.ipa; do
            if [ -f "$ipa" ]; then
                size=$(du -h "$ipa" | cut -f1)
                echo "  - $(basename $ipa): $size"
                
                size_bytes=$(stat -f%z "$ipa")
                if [ $size_bytes -gt 157286400 ]; then
                    echo -e "  ${YELLOW}⚠️  Warning: IPA size exceeds 150MB${NC}"
                fi
            fi
        done
    fi
else
    echo "Debug build for simulator completed"
    ls -lh build/ios/iphonesimulator/*.app 2>/dev/null || echo "No app found"
fi

echo -e "${GREEN}🎉 iOS build process completed!${NC}"
