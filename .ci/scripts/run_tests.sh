#!/bin/bash
set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${GREEN}🧪 Running Tests...${NC}"

# Parse arguments
TEST_TYPE=${1:-all}  # all, unit, widget, integration
COVERAGE=${2:-true}

# YENİ SATIR: Build cache temizle
echo -e "${YELLOW}🧹 Cleaning build cache...${NC}"
flutter clean

# Ensure dependencies are installed
echo -e "${YELLOW}📦 Ensuring dependencies...${NC}"
flutter pub get

# Run code generation if needed
if [ -f "pubspec.yaml" ] && grep -q "build_runner" pubspec.yaml; then
    echo -e "${YELLOW}⚙️  Running code generation...${NC}"
    flutter pub run build_runner build --delete-conflicting-outputs
fi

# Function to run tests
run_tests() {
    local test_path=$1
    local test_name=$2
    
    if [ -d "$test_path" ] || [ -f "$test_path" ]; then
        echo -e "${BLUE}Running $test_name...${NC}"
        
        if [ "$COVERAGE" = "true" ]; then
            # Asset yükleme olmadan test çalıştır
            flutter test --no-test-assets $test_path --coverage --reporter expanded
        else
            # Asset yükleme olmadan test çalıştır
            flutter test --no-test-assets $test_path --reporter expanded
        fi
        
        echo -e "${GREEN}✅ $test_name completed${NC}"
    else
        echo -e "${YELLOW}⚠️  $test_name directory not found, skipping${NC}"
    fi
}

# Run based on type
case "$TEST_TYPE" in
    unit)
        echo -e "${BLUE}🔬 Running Unit Tests Only${NC}"
        run_tests "test/unit" "Unit Tests"
        ;;
    
    widget)
        echo -e "${BLUE}🎯 Running Widget Tests Only${NC}"
        run_tests "test/widget" "Widget Tests"
        ;;
    
    integration)
        echo -e "${BLUE}🔗 Running Integration Tests Only${NC}"
        if [ -d "integration_test" ]; then
            echo -e "${BLUE}Running Integration Tests...${NC}"
            # Integration testlerde de asset yükleme olmadan
            flutter test --no-test-assets integration_test --reporter expanded
            echo -e "${GREEN}✅ Integration Tests completed${NC}"
        else
            echo -e "${YELLOW}⚠️  Integration test directory not found${NC}"
        fi
        ;;
    
    all|*)
        echo -e "${BLUE}🎯 Running All Tests${NC}"
        
        # Unit tests
        run_tests "test/unit" "Unit Tests"
        
        # Widget tests
        run_tests "test/widget" "Widget Tests"
        
        # All other tests
        if [ "$COVERAGE" = "true" ]; then
            echo -e "${BLUE}🔬 Running remaining tests with coverage...${NC}"
            # Asset yükleme olmadan
            flutter test --no-test-assets --coverage --reporter expanded --exclude-tags=integration
        else
            echo -e "${BLUE}🔬 Running remaining tests...${NC}"
            # Asset yükleme olmadan
            flutter test --no-test-assets --reporter expanded --exclude-tags=integration
        fi
        
        # Integration tests (without coverage)
        if [ -d "integration_test" ]; then
            echo -e "${BLUE}🔗 Running Integration Tests...${NC}"
            # Asset yükleme olmadan
            flutter test --no-test-assets integration_test --reporter expanded
            echo -e "${GREEN}✅ Integration Tests completed${NC}"
        fi
        ;;
esac

# Test summary
echo ""
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}✅ All Tests Completed Successfully!${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

# Coverage info
if [ "$COVERAGE" = "true" ] && [ -f "coverage/lcov.info" ]; then
    echo -e "${YELLOW}📊 Coverage data generated: coverage/lcov.info${NC}"
    echo -e "${YELLOW}ℹ️  Run './ci/scripts/generate_coverage.sh' for detailed report${NC}"
fi

echo ""
echo -e "${GREEN}🎉 Test execution completed!${NC}"
