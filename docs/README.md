# Larry Documentation

This directory contains comprehensive documentation for the Larry vocabulary application.

## 🎯 **Current Setup (August 21st, 2025)**

**✅ WORKING LOCALHOST SETUP** - The application is now fully configured for localhost development and iOS Simulator testing. See [**LOCALHOST-SETUP.md**](../LOCALHOST-SETUP.md) for complete setup instructions and verification that authentication works end-to-end.

## 📚 **Core Documentation**

### **API & Architecture**
- [**Terms API**](./TERMS-API.md) - Public retrieval API for curators
- [**Real-time Pipeline**](./REALTIME-PIPELINE.md) - Universal content ingestion system
- [**Future Enhancements**](./FUTURE-ENHANCEMENTS.md) - Planned features and improvements

### **Development & Debugging**
- [**Route 404 Debugging**](./DEBUGGING-ROUTE-404.md) - Comprehensive guide for route issues

## 🛠️ **Quick Debugging Tools**

### **Route Issues (404 Errors)**
When routes return "Cannot GET/POST" errors:

```bash
# Automated diagnosis
./scripts/debug-routes.sh /admin/cost/status

# Manual debug server
cd api && npx tsx debug-index.ts
curl -H "x-admin-key: dev_admin_key_change_me" http://localhost:4001/admin/test
```

### **TypeScript Compilation**
```bash
cd api && npx tsc --noEmit
```

### **Process Cleanup**
```bash
lsof -ti:4000 | xargs kill -9 2>/dev/null || true
```

## 🔍 **Common Issues & Solutions**

| **Problem** | **Quick Fix** | **Documentation** |
|-------------|---------------|-------------------|
| Routes return 404 | `./scripts/debug-routes.sh` | [Route 404 Debugging](./DEBUGGING-ROUTE-404.md) |
| TypeScript errors | Fix iterators, exports | [Route 404 Debugging](./DEBUGGING-ROUTE-404.md#issue-1-typescript-compilation-errors) |
| Server won't start | Kill stale processes | [Route 404 Debugging](./DEBUGGING-ROUTE-404.md#2-check-for-stale-processes) |
| Import failures | Test individual imports | [Route 404 Debugging](./DEBUGGING-ROUTE-404.md#issue-2-importexport-conflicts) |

## 🎯 **Development Workflow**

### **Before Making Changes**
1. Run route debugging script to establish baseline
2. Check TypeScript compilation
3. Test affected endpoints

### **After Making Changes** 
1. Test routes immediately after creation
2. Run TypeScript checks before committing
3. Use debug server for isolated testing

### **When Debugging Issues**
1. Use automated debugging script first
2. Follow systematic approach in documentation
3. Document any new patterns found

## 📋 **Maintenance**

### **Regular Health Checks**
```bash
# Full system check
./scripts/debug-routes.sh

# API health
curl http://localhost:4000/health

# Admin endpoints
curl -H "x-admin-key: dev_admin_key_change_me" http://localhost:4000/admin/cost/status
```

### **Updating Documentation**
When you encounter new issues or solutions:
1. Update the relevant documentation file
2. Add to the common issues table above
3. Update debugging scripts if needed

---

**For specific debugging scenarios, always start with the [Route 404 Debugging Guide](./DEBUGGING-ROUTE-404.md)**
