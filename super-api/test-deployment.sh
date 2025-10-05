#!/bin/bash

# OpenAI Optimization Deployment Test
# Tests the optimization system end-to-end

echo "🧪 OpenAI Optimization Deployment Test"
echo "======================================"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Test configuration
BASE_URL="http://localhost:4001"
TEST_TOPIC="cooking"
NUM_REQUESTS=3

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if backend is running
check_backend() {
    print_status "Checking if backend is running..."
    
    if curl -s "$BASE_URL/health" > /dev/null; then
        print_success "Backend is running"
        return 0
    else
        print_error "Backend is not running"
        echo "Please start the backend first:"
        echo "  cd super-api && npm start"
        return 1
    fi
}

# Test health endpoint
test_health() {
    print_status "Testing health endpoint..."
    
    response=$(curl -s "$BASE_URL/health")
    if echo "$response" | grep -q '"status":"ok"'; then
        print_success "Health endpoint working"
        return 0
    else
        print_error "Health endpoint failed"
        return 1
    fi
}

# Test cost analysis endpoint
test_cost_analysis() {
    print_status "Testing cost analysis endpoint..."
    
    response=$(curl -s "$BASE_URL/cost-analysis")
    if echo "$response" | grep -q "estimatedSavings"; then
        print_success "Cost analysis endpoint working"
        echo "   Cost analysis response received"
        return 0
    else
        print_warning "Cost analysis endpoint not available yet"
        return 1
    fi
}

# Test optimized generation endpoint
test_optimized_generation() {
    print_status "Testing optimized generation endpoint..."
    
    # Make a test request
    response=$(curl -s -X POST "$BASE_URL/generate-optimized" \
        -H "Content-Type: application/json" \
        -d "{\"topic\":\"$TEST_TOPIC\",\"numTerms\":3,\"complexity\":\"basic\"}")
    
    if echo "$response" | grep -q '"success":true'; then
        print_success "Optimized generation working"
        
        # Extract cost information
        cost=$(echo "$response" | grep -o '"cost":[0-9.]*' | cut -d':' -f2)
        model=$(echo "$response" | grep -o '"model":"[^"]*"' | cut -d'"' -f4)
        cached=$(echo "$response" | grep -o '"cached":[^,]*' | cut -d':' -f2)
        
        echo "   Cost: \$${cost}"
        echo "   Model: $model"
        echo "   Cached: $cached"
        
        return 0
    else
        print_error "Optimized generation failed"
        echo "   Response: $response"
        return 1
    fi
}

# Test caching
test_caching() {
    print_status "Testing caching mechanism..."
    
    # Make first request
    response1=$(curl -s -X POST "$BASE_URL/generate-optimized" \
        -H "Content-Type: application/json" \
        -d "{\"topic\":\"$TEST_TOPIC\",\"numTerms\":3,\"complexity\":\"basic\"}")
    
    # Make second identical request
    response2=$(curl -s -X POST "$BASE_URL/generate-optimized" \
        -H "Content-Type: application/json" \
        -d "{\"topic\":\"$TEST_TOPIC\",\"numTerms\":3,\"complexity\":\"basic\"}")
    
    cached1=$(echo "$response1" | grep -o '"cached":[^,]*' | cut -d':' -f2)
    cached2=$(echo "$response2" | grep -o '"cached":[^,]*' | cut -d':' -f2)
    
    if [ "$cached1" = "false" ] && [ "$cached2" = "true" ]; then
        print_success "Caching mechanism working"
        return 0
    else
        print_warning "Caching mechanism needs setup"
        echo "   First request cached: $cached1"
        echo "   Second request cached: $cached2"
        return 1
    fi
}

# Test rate limiting
test_rate_limiting() {
    print_status "Testing rate limiting..."
    
    local rate_limited=false
    
    # Make multiple requests quickly
    for i in $(seq 1 5); do
        response=$(curl -s -w "%{http_code}" -X POST "$BASE_URL/generate-optimized" \
            -H "Content-Type: application/json" \
            -d "{\"topic\":\"$TEST_TOPIC\",\"numTerms\":3,\"userId\":\"test-user-$i\"}")
        
        http_code="${response: -3}"
        
        if [ "$http_code" = "429" ]; then
            rate_limited=true
            break
        fi
    done
    
    if [ "$rate_limited" = true ]; then
        print_success "Rate limiting working"
        return 0
    else
        print_warning "Rate limiting not triggered (may be working correctly)"
        return 1
    fi
}

# Calculate cost savings estimate
calculate_savings() {
    print_status "Calculating estimated cost savings..."
    
    # Get cost from a sample request
    response=$(curl -s -X POST "$BASE_URL/generate-optimized" \
        -H "Content-Type: application/json" \
        -d "{\"topic\":\"$TEST_TOPIC\",\"numTerms\":3,\"complexity\":\"basic\"}")
    
    optimized_cost=$(echo "$response" | grep -o '"cost":[0-9.]*' | cut -d':' -f2)
    original_cost=0.025  # Estimated original cost
    
    if [ -n "$optimized_cost" ] && [ "$optimized_cost" != "null" ]; then
        savings=$(echo "scale=1; (($original_cost - $optimized_cost) / $original_cost) * 100" | bc)
        
        echo "   Original cost (estimated): \$$original_cost"
        echo "   Optimized cost: \$$optimized_cost"
        echo "   Savings: ${savings}%"
        
        if (( $(echo "$savings > 80" | bc -l) )); then
            print_success "Excellent cost reduction achieved!"
        elif (( $(echo "$savings > 60" | bc -l) )); then
            print_success "Good cost reduction achieved"
        else
            print_warning "Cost reduction needs improvement"
        fi
    else
        print_warning "Could not calculate cost savings"
    fi
}

# Main test execution
main() {
    echo "Starting deployment tests..."
    echo ""
    
    local tests_passed=0
    local total_tests=6
    
    # Run tests
    if check_backend; then
        ((tests_passed++))
    fi
    
    if test_health; then
        ((tests_passed++))
    fi
    
    if test_cost_analysis; then
        ((tests_passed++))
    fi
    
    if test_optimized_generation; then
        ((tests_passed++))
    fi
    
    if test_caching; then
        ((tests_passed++))
    fi
    
    if test_rate_limiting; then
        ((tests_passed++))
    fi
    
    calculate_savings
    
    echo ""
    echo "======================================"
    echo "📊 TEST RESULTS: $tests_passed/$total_tests tests passed"
    
    if [ $tests_passed -eq $total_tests ]; then
        print_success "🎉 All tests passed! Optimization system is ready."
        echo ""
        echo "Next steps:"
        echo "1. Update iOS app to use /generate-optimized endpoint"
        echo "2. Monitor costs for 24-48 hours"
        echo "3. Set up cost alerts"
    elif [ $tests_passed -ge 4 ]; then
        print_success "✅ Most tests passed. System is mostly ready."
        echo ""
        echo "Review failed tests and deploy when ready."
    else
        print_error "❌ Several tests failed. Review before deployment."
        echo ""
        echo "Common issues:"
        echo "- Backend not running"
        echo "- Missing environment variables"
        echo "- Database connection issues"
    fi
}

# Run main function
main
