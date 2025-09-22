import { useState, useEffect } from 'react';
import * as SecureStore from 'expo-secure-store';
import * as AppleAuthentication from 'expo-apple-authentication';
import * as AuthSession from 'expo-auth-session';
import * as WebBrowser from 'expo-web-browser';
import { startDirectGoogleOAuth, authenticateWithApple, refreshToken, signOut as apiSignOut, getUserProfile } from '../services/api';

export function useAuth() {
  const [isAuthenticated, setIsAuthenticated] = useState(false);
  const [user, setUser] = useState(null);
  const [loading, setLoading] = useState(false);
  const [accessToken, setAccessToken] = useState(null);
  const [refreshTokenValue, setRefreshTokenValue] = useState(null);

  // Load stored tokens on app start
  useEffect(() => {
    loadStoredTokens();
  }, []);

  const loadStoredTokens = async () => {
    try {
      const storedAccessToken = await SecureStore.getItemAsync('accessToken');
      const storedRefreshToken = await SecureStore.getItemAsync('refreshToken');
      const storedUser = await SecureStore.getItemAsync('user');

      if (storedAccessToken && storedRefreshToken && storedUser) {
        setAccessToken(storedAccessToken);
        setRefreshTokenValue(storedRefreshToken);
        setUser(JSON.parse(storedUser));
        setIsAuthenticated(true);
      }
    } catch (error) {
      console.error('Error loading stored tokens:', error);
    }
  };

  const storeTokens = async (accessToken, refreshToken, user) => {
    try {
      await SecureStore.setItemAsync('accessToken', accessToken);
      await SecureStore.setItemAsync('refreshToken', refreshToken);
      await SecureStore.setItemAsync('user', JSON.stringify(user));
    } catch (error) {
      console.error('Error storing tokens:', error);
    }
  };

  const clearStoredTokens = async () => {
    try {
      await SecureStore.deleteItemAsync('accessToken');
      await SecureStore.deleteItemAsync('refreshToken');
      await SecureStore.deleteItemAsync('user');
    } catch (error) {
      console.error('Error clearing tokens:', error);
    }
  };

  const signInWithApple = async () => {
    setLoading(true);
    try {
      console.log('🍎 Starting Apple Sign In...');
      
      const isAvailable = await AppleAuthentication.isAvailableAsync();
      if (!isAvailable) {
        throw new Error('Apple Sign In is not available on this device');
      }

      const credential = await AppleAuthentication.signInAsync({
        requestedScopes: [
          AppleAuthentication.AppleAuthenticationScope.FULL_NAME,
          AppleAuthentication.AppleAuthenticationScope.EMAIL,
        ],
      });

      console.log('🍎 Apple Sign In credential received:', credential);

      const authResult = await authenticateWithApple(
        credential.identityToken,
        credential.email,
        credential.fullName ? `${credential.fullName.givenName || ''} ${credential.fullName.familyName || ''}`.trim() : undefined,
        credential.user
      );

      console.log('🍎 Backend authentication successful:', authResult);

      await storeTokens(authResult.accessToken, authResult.refreshToken, authResult.user);
      
      setAccessToken(authResult.accessToken);
      setRefreshTokenValue(authResult.refreshToken);
      setUser(authResult.user);
      setIsAuthenticated(true);
      
      console.log('🍎 Apple Sign In completed successfully');
    } catch (error) {
      console.error('🍎 Apple Sign In error:', error);
      if (error.code === 'ERR_CANCELED') {
        console.log('User canceled Apple Sign In');
      }
    } finally {
      setLoading(false);
    }
  };

  const signInWithGoogle = async () => {
    setLoading(true);
    try {
      console.log('🔍 Starting direct Google OAuth...');
      
      const oauthResult = await startDirectGoogleOAuth();
      console.log('🔍 Direct OAuth URL received:', oauthResult.url);

      const result = await WebBrowser.openAuthSessionAsync(
        oauthResult.url,
        'larry://auth-callback'
      );

      console.log('🔍 WebBrowser result:', result);

      if (result.type === 'success' && result.url) {
        console.log('🔍 Callback URL received:', result.url);
        
        const url = new URL(result.url);
        const params = new URLSearchParams(url.search);
        
        const error = params.get('error');
        
        if (error) {
          console.error('🔍 OAuth error:', error);
          throw new Error(`OAuth error: ${error}`);
        }
        
        const accessToken = params.get('accessToken');
        const refreshToken = params.get('refreshToken');
        const userId = params.get('userId');
        const userEmail = params.get('userEmail');
        const userName = params.get('userName');
        const userAvatar = params.get('userAvatar');

        console.log('🔍 Extracted params:', { accessToken: !!accessToken, refreshToken: !!refreshToken, userId, userEmail, userName });

        if (accessToken && refreshToken && userId) {
          const userProfile = await getUserProfile(accessToken);
          console.log('🔍 User profile from database:', userProfile);

          await storeTokens(accessToken, refreshToken, userProfile);
          
          setAccessToken(accessToken);
          setRefreshTokenValue(refreshToken);
          setUser(userProfile);
          setIsAuthenticated(true);
          
          console.log('🔍 Google Sign In completed successfully');
        } else {
          throw new Error('Missing authentication data from callback');
        }
      } else if (result.type === 'cancel') {
        console.log('User canceled Google Sign In');
      } else {
        console.error('🔍 WebBrowser result:', result);
        throw new Error('Google Sign In failed');
      }
    } catch (error) {
      console.error('🔍 Google Sign In error:', error);
      alert(`Google Sign In failed: ${error.message}`);
    } finally {
      setLoading(false);
    }
  };

  const signInWithEmail = async () => {
    setLoading(true);
    try {
      console.log('Email Sign In pressed');
      // TODO: Implement real email authentication
      setTimeout(() => {
        setUser({ id: '3', name: 'Email User', email: 'email@example.com' });
        setIsAuthenticated(true);
        setLoading(false);
      }, 1000);
    } catch (error) {
      console.error('Email Sign In error:', error);
      setLoading(false);
    }
  };

  const signOut = async () => {
    try {
      if (accessToken) {
        await apiSignOut();
      }
    } catch (error) {
      console.error('Error signing out from backend:', error);
    } finally {
      await clearStoredTokens();
      setUser(null);
      setAccessToken(null);
      setRefreshTokenValue(null);
      setIsAuthenticated(false);
      console.log('✅ Signed out successfully');
    }
  };

  const refreshAccessToken = async () => {
    if (!refreshTokenValue) {
      throw new Error('No refresh token available');
    }

    try {
      const result = await refreshToken(refreshTokenValue);
      
      await storeTokens(result.accessToken, result.refreshToken, result.user);
      
      setAccessToken(result.accessToken);
      setRefreshTokenValue(result.refreshToken);
      setUser(result.user);
      
      return result.accessToken;
    } catch (error) {
      console.error('Token refresh failed:', error);
      await signOut();
      throw error;
    }
  };

  return {
    isAuthenticated,
    user,
    loading,
    accessToken,
    signInWithApple,
    signInWithGoogle,
    signInWithEmail,
    signOut,
    refreshAccessToken,
  };
}
