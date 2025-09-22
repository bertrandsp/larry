# Localhost Development Setup

**Date: August 21st, 2025**  
**Status: ✅ WORKING - Complete localhost-based authentication flow**

## 🎯 Current Setup (as of August 21st, 2025)

This project is now configured to run **entirely on localhost** for development. All ngrok dependencies have been removed for a simpler, more reliable development experience.

## 📱 iOS Simulator Testing

The app is designed and tested to work with **iOS Simulator**, which can access localhost directly:

- **Backend API**: `http://localhost:4000`
- **Frontend Metro**: `http://localhost:8081`
- **Authentication**: Works with localhost URLs
- **Deep Linking**: `larry://auth` callbacks function properly

## 🚀 Quick Start

1. **Start Backend Services**:
   ```bash
   docker-compose up -d
   ```

2. **Verify Backend Health**:
   ```bash
   curl http://localhost:4000/health
   # Should return: {"ok":true}
   ```

3. **Build & Run iOS App**:
   ```bash
   cd app && npx expo run:ios
   ```

4. **Test Authentication**:
   - Open app in iOS Simulator
   - Tap "Sign in with Apple" (recommended for iOS)
   - Authentication flow should complete successfully

## 🔧 Configuration Files

All configuration files use localhost:

- **`app/app.config.ts`**: `API_BASE_URL = 'http://localhost:4000'`
- **`app/app.json`**: `API_BASE_URL = 'http://localhost:4000'`
- **`api/src/config.ts`**: `MOBILE_REDIRECT_URI = 'http://localhost:4000/auth/mobile/callback'`
- **`api/.env`**: `MOBILE_REDIRECT_URI = http://localhost:4000/auth/mobile/callback`
- **`docker-compose.yaml`**: `MOBILE_REDIRECT_URI = http://localhost:4000/auth/mobile/callback`

## ✅ What Works (Verified August 21st)

- ✅ **Backend API**: Health check, authentication endpoints
- ✅ **Docker Services**: PostgreSQL, Redis, Backend API
- ✅ **iOS Build**: Expo/React Native compilation
- ✅ **iOS Simulator**: App launches and runs
- ✅ **Authentication Flow**: WorkOS integration with Apple/Google Sign-In
- ✅ **Deep Linking**: Auth callbacks via `larry://auth`

## 🚫 Removed Components

The following ngrok-related components were **completely removed**:

- `update-ngrok.js` - URL update script
- `get-ngrok-url.js` - URL detection script  
- `sync-ngrok.js` - Combined sync script
- `NGROK-SETUP.md` - ngrok documentation
- All `ngrok:*` npm scripts from `package.json`

## 📋 Troubleshooting

### Backend Issues
```bash
# Check container status
docker-compose ps

# View backend logs
docker-compose logs backend

# Restart backend
docker-compose restart backend
```

### iOS Build Issues
```bash
# Clean build
cd app && npx expo run:ios --clear

# Check Metro server
curl http://localhost:8081
```

### Authentication Issues
- Ensure WorkOS dashboard has correct redirect URI: `http://localhost:4000/auth/mobile/callback`
- Check backend logs for WorkOS API responses
- Verify deep linking setup in iOS simulator

## 🎯 Next Steps for Production

When ready for production deployment:

1. Update all localhost URLs to production domain
2. Configure proper HTTPS certificates
3. Update WorkOS dashboard with production redirect URIs
4. Set production environment variables

---

**This setup eliminates external tunnel dependencies and provides a reliable localhost development environment specifically optimized for iOS Simulator testing.**
