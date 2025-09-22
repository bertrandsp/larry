# Debugging Route 404 Issues

This document provides a systematic approach to debugging persistent 404 errors in the Larry API, particularly when routes appear to be defined correctly but return "Cannot GET/POST" errors.

## 🔍 **Quick Diagnosis Checklist**

When you encounter 404s on routes that should exist:

### 1. **Verify Server is Actually Running**
```bash
curl http://localhost:4000/health
# Should return: {"ok":true}
```

### 2. **Check for Stale Processes**
```bash
lsof -i :4000
# Kill any unexpected processes
kill <PID>
```

### 3. **Test with Debug Server**
Create a minimal test server to isolate the issue:
```bash
cd api
npx tsx debug-index.ts
curl http://localhost:4001/admin/test
```

## 🚨 **Common Root Causes**

### **Issue 1: TypeScript Compilation Errors**

**Symptoms:**
- Routes work in isolation but not in main server
- ESBuild "Transform failed" errors
- "Multiple exports with the same name" errors

**Diagnosis:**
```bash
cd api
npx tsc --noEmit src/routes/admin.ts
```

**Common Fixes:**
- **Iterator Compatibility**: Replace `.entries()` with traditional for-loops
- **Duplicate Exports**: Remove redundant export statements
- **TypeScript Target**: Ensure `tsconfig.json` has proper ES target

**Example Fixes:**
```typescript
// ❌ Problem
for (const [index, item] of array.entries()) { }

// ✅ Solution
for (let index = 0; index < array.length; index++) {
  const item = array[index];
}
```

### **Issue 2: Import/Export Conflicts**

**Symptoms:**
- "Unknown file extension .ts" errors
- Router imports fail silently
- Server starts but routes don't register

**Diagnosis:**
```bash
# Test individual imports
npx tsx -e "import { adminRouter } from './src/routes/admin.ts'; console.log('Success');"
```

**Common Fixes:**
- Check for missing export statements
- Verify file extensions in imports
- Ensure all dependencies are properly exported

### **Issue 3: Middleware Conflicts**

**Symptoms:**
- Routes work in debug server but not main server
- Specific routers fail while others work
- Authentication middleware errors

**Diagnosis:**
Create incremental test server adding imports one by one:
```typescript
// Test each router import separately
console.log('1. Importing admin router...');
const { adminRouter } = require('./src/routes/admin.ts');

console.log('2. Importing upload router...');
const { uploadRouter } = require('./src/routes/upload.ts');
// etc.
```

## 🛠️ **Debugging Tools**

### **Debug Server Template**
Save as `debug-index.ts`:
```typescript
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
  console.error('❌ Router failed:', error);
}

app.listen(4001, () => console.log('Debug API on :4001'));
```

### **TypeScript Check Script**
```bash
#!/bin/bash
echo "Checking TypeScript compilation..."
cd api
npx tsc --noEmit 2>&1 | grep -E "(error|src/)" | head -10
```

### **Port Cleanup Script**
```bash
#!/bin/bash
echo "Cleaning up port 4000..."
lsof -ti:4000 | xargs kill -9 2>/dev/null || true
sleep 1
echo "Port 4000 cleared"
```

## 📋 **Step-by-Step Resolution Process**

### **Phase 1: Basic Verification**
1. Check if server process is actually running
2. Verify health endpoint responds
3. Kill any stale processes on the port
4. Restart server and retest

### **Phase 2: Isolation Testing**
1. Create debug server with minimal imports
2. Test problematic routes in isolation
3. If routes work in debug → main server issue
4. If routes fail in debug → route definition issue

### **Phase 3: Compilation Analysis**
1. Run TypeScript compilation check
2. Look for iterator/export/import errors
3. Fix compilation issues one by one
4. Verify each fix with tsc --noEmit

### **Phase 4: Import Debugging**
1. Test router imports individually
2. Add imports incrementally to debug server
3. Identify which import causes failure
4. Fix the problematic import/dependency

### **Phase 5: Verification**
1. Clean restart of main server
2. Test all affected endpoints
3. Verify in both development and production modes
4. Document any environment-specific issues

## 🔧 **Specific Larry API Fixes**

### **Cost Gate Middleware Issues**
The cost gate middleware had multiple export conflicts:
```typescript
// ❌ Problem: Functions already exported individually
export { logTokenUsage, getCostGateStatus, ... }

// ✅ Solution: Remove duplicate exports
// Functions are already exported with individual export statements
```

### **Iterator Compatibility Issues**
Several files had ES6+ iterator issues:
```typescript
// ❌ Problem
for (const [index, url] of realSources.slice(0, maxSources).entries()) {}
for (const [id] of this.activeMonitors) {}

// ✅ Solution
const selectedSources = realSources.slice(0, maxSources);
for (let index = 0; index < selectedSources.length; index++) {
  const url = selectedSources[index];
}

const monitorIds = Array.from(this.activeMonitors.keys());
for (const id of monitorIds) {}
```

### **TypeScript Configuration**
Updated `tsconfig.json` for better compatibility:
```json
{
  "compilerOptions": {
    "target": "ES2020",
    "downlevelIteration": true,
    "allowSyntheticDefaultImports": true,
    "moduleResolution": "node",
    "resolveJsonModule": true
  }
}
```

## 🎯 **Prevention Strategies**

### **Development Practices**
1. **Test routes immediately** after creation
2. **Use debug server** for isolated testing
3. **Run TypeScript checks** before committing
4. **Avoid complex iterator patterns** in server code
5. **Monitor for duplicate exports** in large files

### **CI/CD Integration**
Add these checks to your pipeline:
```yaml
- name: TypeScript Check
  run: cd api && npx tsc --noEmit
  
- name: Route Health Check  
  run: |
    cd api && npm run dev &
    sleep 5
    curl -f http://localhost:4000/health
```

### **Code Review Checklist**
- [ ] All imports have corresponding exports
- [ ] No duplicate export statements
- [ ] Iterator patterns are ES5-compatible
- [ ] Routes tested in isolation
- [ ] TypeScript compilation passes

## 📚 **Related Documentation**
- [TypeScript Configuration Guide](./TYPESCRIPT-CONFIG.md)
- [API Testing Strategies](./API-TESTING.md)
- [Express Router Best Practices](./EXPRESS-PATTERNS.md)

---

**Last Updated:** August 2025  
**Tested With:** Node.js v22.13.1, TypeScript 5.9.2, tsx 4.20.4
