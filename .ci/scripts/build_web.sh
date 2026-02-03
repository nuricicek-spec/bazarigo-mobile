#!/bin/bash
set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}🌐 Building Web...${NC}"

# Parse arguments
RENDERER=${1:-canvaskit}  # canvaskit or html
BASE_HREF=${2:-/}
BUILD_TYPE=${3:-release}

echo "Renderer: $RENDERER"
echo "Base HREF: $BASE_HREF"
echo "Build Type: $BUILD_TYPE"

# Clean
echo -e "${YELLOW}🧹 Cleaning...${NC}"
flutter clean
rm -rf build/web

# Get dependencies
echo -e "${YELLOW}📦 Getting dependencies...${NC}"
flutter pub get

# Run code generation
if [ -f "pubspec.yaml" ] && grep -q "build_runner" pubspec.yaml; then
    echo -e "${YELLOW}⚙️  Running code generation...${NC}"
    flutter pub run build_runner build --delete-conflicting-outputs
fi

# Build
if [ "$BUILD_TYPE" = "release" ]; then
    echo -e "${GREEN}📦 Building Web Release...${NC}"
    flutter build web \
        --release \
        --web-renderer $RENDERER \
        --base-href $BASE_HREF \
        --no-source-maps \
        --pwa-strategy offline-first
    
elif [ "$BUILD_TYPE" = "debug" ]; then
    echo -e "${YELLOW}🔧 Building Web Debug...${NC}"
    flutter build web \
        --debug \
        --web-renderer $RENDERER \
        --base-href $BASE_HREF \
        --source-maps
else
    echo -e "${RED}❌ Unknown build type: $BUILD_TYPE${NC}"
    exit 1
fi

# Build info
echo -e "${GREEN}✅ Web Build Complete!${NC}"
echo -e "${GREEN}📊 Build Information:${NC}"

if [ -d "build/web" ]; then
    total_size=$(du -sh build/web | cut -f1)
    echo "Total build size: $total_size"
    
    # Check main bundle size
    if [ -f "build/web/main.dart.js" ]; then
        main_size=$(du -h build/web/main.dart.js | cut -f1)
        echo "Main JS bundle: $main_size"
        
        # Warning if > 2MB
        main_bytes=$(stat -f%z "build/web/main.dart.js" 2>/dev/null || stat -c%s "build/web/main.dart.js")
        if [ $main_bytes -gt 2097152 ]; then
            echo -e "${YELLOW}⚠️  Warning: Main bundle exceeds 2MB${NC}"
        fi
    fi
    
    # List key files
    echo ""
    echo "Key files:"
    ls -lh build/web/*.{js,html} 2>/dev/null || true
    
    # Total size check
    total_bytes=$(du -sb build/web | cut -f1)
    if [ $total_bytes -gt 10485760 ]; then
        echo -e "${YELLOW}⚠️  Warning: Total build size exceeds 10MB${NC}"
    fi
else
    echo -e "${RED}❌ Build directory not found${NC}"
    exit 1
fi

echo -e "${GREEN}🎉 Web build process completed!${NC}"
