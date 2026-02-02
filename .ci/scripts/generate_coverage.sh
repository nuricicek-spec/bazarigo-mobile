// .ci/scripts/generate_coverage.sh
#!/bin/bash
set -e

echo "📊 Generating Coverage Report..."

# Coverage raporu oluştur
if [ -f "coverage/lcov.info" ]; then
    # HTML raporu oluştur
    genhtml coverage/lcov.info -o coverage_report
    
    # Coverage yüzdesini hesapla
    coverage_percentage=$(lcov --summary coverage/lcov.info 2>/dev/null | grep lines | awk '{print $2}')
    
    echo "📈 Code Coverage: $coverage_percentage"
    echo "📄 Report generated: coverage_report/index.html"
    
    # Minimum coverage kontrolü
    min_coverage=80
    coverage_number=$(echo $coverage_percentage | sed 's/%//')
    
    if (( $(echo "$coverage_number < $min_coverage" | bc -l) )); then
        echo "❌ ERROR: Coverage below $min_coverage%"
        exit 1
    fi
else
    echo "⚠️  No coverage data found"
    exit 0
fi
