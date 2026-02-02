// .ci/scripts/run_tests.sh
#!/bin/bash
set -e

echo "🧪 Running Tests..."

# Unit testler
echo "🔬 Running Unit Tests..."
flutter test --coverage

# Widget testleri
echo "🎯 Running Widget Tests..."
flutter test test/widget/

# İntegrasyon testleri (eğer varsa)
if [ -d "integration_test" ]; then
    echo "🔗 Running Integration Tests..."
    flutter test integration_test/
fi

echo "✅ All Tests Completed!"
