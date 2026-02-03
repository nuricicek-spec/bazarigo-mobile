#!/bin/bash
set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}📊 Generating Coverage Report...${NC}"

# Check if coverage file exists
if [ ! -f "coverage/lcov.info" ]; then
    echo -e "${YELLOW}⚠️  No coverage data found${NC}"
    echo -e "${YELLOW}ℹ️  Running tests with coverage...${NC}"
    flutter test --coverage
fi

# Check again
if [ ! -f "coverage/lcov.info" ]; then
    echo -e "${RED}❌ Failed to generate coverage data${NC}"
    exit 1
fi

# Check if lcov is installed
if ! command -v lcov &> /dev/null; then
    echo -e "${RED}❌ lcov is not installed${NC}"
    echo -e "${YELLOW}ℹ️  Skipping detailed coverage report${NC}"
    exit 0  # Hata vermeden çık, workflow devam etsin
fi

# Remove generated files from coverage
echo -e "${YELLOW}🧹 Removing generated files from coverage...${NC}"
lcov --ignore-errors unused --remove coverage/lcov.info \
    '**/*.g.dart' \
    '**/*.freezed.dart' \
    '**/*.config.dart' \
    '**/generated/**' \
    -o coverage/lcov_filtered.info

mv coverage/lcov_filtered.info coverage/lcov.info

# Generate HTML report
if command -v genhtml &> /dev/null; then
    echo -e "${YELLOW}📄 Generating HTML report...${NC}"
    genhtml coverage/lcov.info -o coverage/html --title "Bazarigo Mobile Coverage"
    echo -e "${GREEN}✅ HTML report: coverage/html/index.html${NC}"
fi

# Calculate coverage percentage
echo -e "${YELLOW}📈 Calculating coverage...${NC}"

# Get summary
coverage_summary=$(lcov --ignore-errors unused --summary coverage/lcov.info 2>&1)

# Extract line coverage percentage
coverage_percentage=$(echo "$coverage_summary" | grep -oP 'lines......: \K[0-9.]+' || echo "0")

echo ""
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}📊 Coverage Summary${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo "$coverage_summary"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Read minimum coverage from config
MIN_COVERAGE=75  # Daha önce 80'den 75'e düşürmüştük
if [ -f ".ci/quality_gates/coverage_threshold.yaml" ]; then
    config_min=$(grep "^minimum_coverage:" .ci/quality_gates/coverage_threshold.yaml | awk '{print $2}')
    if [ ! -z "$config_min" ]; then
        MIN_COVERAGE=$config_min
    fi
fi

echo -e "Minimum required coverage: ${YELLOW}${MIN_COVERAGE}%${NC}"
echo -e "Current coverage: ${GREEN}${coverage_percentage}%${NC}"

# Compare coverage
if command -v bc &> /dev/null; then
    if (( $(echo "$coverage_percentage < $MIN_COVERAGE" | bc -l) )); then
        echo ""
        echo -e "${RED}❌ ERROR: Coverage (${coverage_percentage}%) is below minimum (${MIN_COVERAGE}%)${NC}"
        exit 1
    else
        echo ""
        echo -e "${GREEN}✅ Coverage meets minimum threshold${NC}"
    fi
else
    echo -e "${YELLOW}⚠️  bc not installed, skipping threshold check${NC}"
fi

echo ""
echo -e "${GREEN}🎉 Coverage report generation completed!${NC}"
