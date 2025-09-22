#!/bin/bash

# Larry API Route Debugging Script
# Usage: ./scripts/debug-routes.sh [endpoint]
# Example: ./scripts/debug-routes.sh /admin/cost/status

set -e

ENDPOINT=${1:-"/admin/test"}
API_PORT=${2:-4000}
DEBUG_PORT=4001
ADMIN_KEY="dev_admin_key_change_me"

echo "🔍 Larry API Route Debugging Tool"
echo "=================================="
echo "Endpoint: $ENDPOINT"
echo "API Port: $API_PORT"
echo ""

# Change to API directory
cd "$(dirname "$0")/../api" || { echo "❌ Cannot find api directory"; exit 1; }

# Function to test endpoint
test_endpoint() {
    local port=$1
    local label=$2
    
    echo "Testing $label (port $port)..."
    
    if ! curl -s "http://localhost:$port/health" > /dev/null; then
        echo "❌ $label not responding on port $port"
        return 1
    fi
    
    local response=$(curl -s -H "x-admin-key: $ADMIN_KEY" "http://localhost:$port$ENDPOINT" 2>/dev/null || echo "FAILED")
    
    if [[ "$response" == *"Cannot GET"* ]] || [[ "$response" == *"Cannot POST"* ]] || [[ "$response" == "FAILED" ]]; then
        echo "❌ $label: 404 or error on $ENDPOINT"
        return 1
    else
        echo "✅ $label: $ENDPOINT working"
        echo "Response: ${response:0:100}..."
        return 0
    fi
}

# Step 1: Check for stale processes
echo "Step 1: Checking for stale processes..."
if lsof -ti:$API_PORT > /dev/null 2>&1; then
    echo "⚠️  Found process on port $API_PORT, killing..."
    lsof -ti:$API_PORT | xargs kill -9 2>/dev/null || true
    sleep 2
fi

if lsof -ti:$DEBUG_PORT > /dev/null 2>&1; then
    echo "⚠️  Found process on port $DEBUG_PORT, killing..."
    lsof -ti:$DEBUG_PORT | xargs kill -9 2>/dev/null || true
    sleep 2
fi

# Step 2: TypeScript compilation check
echo ""
echo "Step 2: Checking TypeScript compilation..."
if ! npx tsc --noEmit > /dev/null 2>&1; then
    echo "❌ TypeScript compilation errors found:"
    npx tsc --noEmit 2>&1 | grep -E "(error|src/)" | head -5
    echo ""
    echo "💡 Common fixes:"
    echo "   - Replace .entries() with traditional for-loops"
    echo "   - Remove duplicate export statements"
    echo "   - Check tsconfig.json target and flags"
    echo ""
else
    echo "✅ TypeScript compilation passes"
fi

# Step 3: Test debug server
echo ""
echo "Step 3: Testing debug server..."

# Create simple debug server if it doesn't exist
if [ ! -f "debug-simple.ts" ]; then
    cat > debug-simple.ts << 'EOF'
import 'dotenv/config';
import express from 'express';

const app = express();
app.use(express.json());
app.get('/health', (req, res) => res.json({ ok: true }));

try {
  const { adminRouter } = require('./src/routes/admin.ts');
  app.use('/admin', adminRouter);
  console.log('✅ Admin router mounted');
} catch (error) {
  console.error('❌ Router failed:', error.message);
}

app.listen(4001, () => console.log('Debug server ready'));
EOF
fi

# Start debug server
echo "Starting debug server..."
npx tsx debug-simple.ts > debug.log 2>&1 &
DEBUG_PID=$!
sleep 3

if test_endpoint $DEBUG_PORT "Debug server"; then
    echo "✅ Routes work in isolation - main server configuration issue"
    ISOLATION_WORKS=true
else
    echo "❌ Routes fail in isolation - route definition issue"
    ISOLATION_WORKS=false
fi

# Kill debug server
kill $DEBUG_PID 2>/dev/null || true
rm -f debug-simple.ts debug.log

# Step 4: Test main server
echo ""
echo "Step 4: Testing main server..."

echo "Starting main server..."
npm run dev:tsx > main.log 2>&1 &
MAIN_PID=$!
sleep 5

if test_endpoint $API_PORT "Main server"; then
    echo "✅ Main server working correctly"
    MAIN_WORKS=true
else
    echo "❌ Main server has issues"
    MAIN_WORKS=false
fi

# Kill main server
kill $MAIN_PID 2>/dev/null || true
rm -f main.log

# Step 5: Diagnosis and recommendations
echo ""
echo "🏁 Diagnosis Results"
echo "===================="

if [ "$ISOLATION_WORKS" = true ] && [ "$MAIN_WORKS" = false ]; then
    echo "🎯 ISSUE: Main server configuration problem"
    echo ""
    echo "📋 Recommended fixes:"
    echo "   1. Check for import conflicts in src/index.ts"
    echo "   2. Test individual router imports"
    echo "   3. Look for middleware that might interfere"
    echo "   4. Check server startup logs for silent failures"
    echo ""
    echo "🔧 Quick test:"
    echo "   npx tsx -e \"import { adminRouter } from './src/routes/admin.ts'; console.log('Success');\""

elif [ "$ISOLATION_WORKS" = false ]; then
    echo "🎯 ISSUE: Route definition problem"
    echo ""
    echo "📋 Recommended fixes:"
    echo "   1. Check router export statements"
    echo "   2. Verify route syntax and middleware"
    echo "   3. Look for TypeScript compilation errors"
    echo "   4. Test individual route imports"

elif [ "$ISOLATION_WORKS" = true ] && [ "$MAIN_WORKS" = true ]; then
    echo "✅ All systems working correctly!"
    echo "   The issue may have been a temporary process conflict"

else
    echo "🎯 ISSUE: System-wide problem"
    echo ""
    echo "📋 Recommended fixes:"
    echo "   1. Check Node.js and dependency versions"
    echo "   2. Clear node_modules and reinstall"
    echo "   3. Check environment variables"
    echo "   4. Review recent code changes"
fi

echo ""
echo "📖 For detailed debugging guide, see: docs/DEBUGGING-ROUTE-404.md"
echo "🛠️  For manual testing, use: npx tsx debug-simple.ts"
