import React, { useState, useEffect } from 'react';
import { View, Text } from 'react-native';
import { GestureHandlerRootView } from 'react-native-gesture-handler';
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import { SafeAreaProvider } from 'react-native-safe-area-context';
import { useAuth } from './src/hooks/useAuth';
import LoginScreen from './src/screens/LoginScreen';
import { PagedHomeScreen } from './src/screens/PagedHomeScreen';
import { ProfileScreen } from './src/screens/ProfileScreen';
import { WordbankScreen } from './src/screens/WordbankScreen';
import { InterestDetailScreen } from './src/screens/InterestDetailScreen';
import Interests from './src/onboarding/Interests';

// Create a client
const queryClient = new QueryClient();

export default function App() {
  const { isAuthenticated, user, loading, signInWithApple, signInWithGoogle, signInWithEmail, signOut } = useAuth();
  const [currentScreen, setCurrentScreen] = useState('home');
  const [screenParams, setScreenParams] = useState({});
  const [hasCompletedOnboarding, setHasCompletedOnboarding] = useState(false);

  // Debug authentication state changes
  useEffect(() => {
    console.log('🔐 App.js - Authentication state changed:', { isAuthenticated, user: user?.name });
  }, [isAuthenticated, user]);

  // Check if user has completed onboarding
  useEffect(() => {
    const checkOnboardingStatus = async () => {
      // TODO: Replace with real API call to check onboarding status
      // For now, we'll assume new users haven't completed onboarding
      // This should be replaced with a proper API call to check user's onboarding status
      if (user?.id) {
        // For testing: assume users haven't completed onboarding
        // In production, this would be an API call like:
        // const response = await fetch(`/api/users/${user.id}/onboarding-status`);
        // const { hasCompletedOnboarding } = await response.json();
        // setHasCompletedOnboarding(hasCompletedOnboarding);
        
        // For now, set to false to show onboarding for all users
        setHasCompletedOnboarding(false);
      }
    };

    if (isAuthenticated && user?.id) {
      checkOnboardingStatus();
    }
  }, [isAuthenticated, user]);

  // Clear authentication state on app start for testing
  useEffect(() => {
    const clearAuthForTesting = async () => {
      // Uncomment the line below to force logout on app start for testing
      await signOut();
    };
    clearAuthForTesting();
  }, []);

  // Reset to home screen when user becomes authenticated
  useEffect(() => {
    if (isAuthenticated) {
      console.log('🔐 App.js - User authenticated, resetting to home screen');
      setCurrentScreen('home');
      setScreenParams({});
    }
  }, [isAuthenticated]);

  if (loading) {
    return (
      <SafeAreaProvider>
        <QueryClientProvider client={queryClient}>
          <GestureHandlerRootView style={{ flex: 1 }}>
            <View style={{ flex: 1, justifyContent: 'center', alignItems: 'center', backgroundColor: '#f9fafb' }}>
              <Text style={{ fontSize: 18, color: '#6b7280' }}>Loading...</Text>
            </View>
          </GestureHandlerRootView>
        </QueryClientProvider>
      </SafeAreaProvider>
    );
  }

  if (isAuthenticated && user?.id) {
    console.log('🔐 App.js - User is authenticated with valid ID, showing main app');
    
    // Show onboarding if user hasn't completed it
    if (!hasCompletedOnboarding) {
      return (
        <SafeAreaProvider>
          <QueryClientProvider client={queryClient}>
            <GestureHandlerRootView style={{ flex: 1 }}>
              <Interests
                user={user}
                onComplete={() => {
                  console.log('✅ Onboarding completed');
                  setHasCompletedOnboarding(true);
                }}
              />
            </GestureHandlerRootView>
          </QueryClientProvider>
        </SafeAreaProvider>
      );
    }
    
    // Simple navigation object
    const navigation = {
      navigate: (screen, params) => {
        console.log(`Navigate to ${screen}`, params);
        setCurrentScreen(screen);
        setScreenParams(params || {});
      },
      goBack: () => {
        // Simple back navigation - go to previous screen
        if (currentScreen === 'interestDetail') {
          setCurrentScreen('wordbank');
        } else {
          setCurrentScreen('home');
        }
        setScreenParams({});
      }
    };
    
    return (
      <SafeAreaProvider>
        <QueryClientProvider client={queryClient}>
          <GestureHandlerRootView style={{ flex: 1 }}>
            {currentScreen === 'home' ? (
              <PagedHomeScreen 
                user={user}
                navigation={navigation} 
                onProfilePress={() => setCurrentScreen('profile')}
                onWordbankPress={() => setCurrentScreen('wordbank')}
              />
            ) : currentScreen === 'profile' ? (
              <ProfileScreen navigation={navigation} onSignOut={signOut} />
            ) : currentScreen === 'wordbank' ? (
              <WordbankScreen navigation={navigation} />
            ) : currentScreen === 'interestDetail' ? (
              <InterestDetailScreen navigation={navigation} route={{ params: screenParams }} />
            ) : (
              <PagedHomeScreen 
                navigation={navigation} 
                onProfilePress={() => setCurrentScreen('profile')}
                onWordbankPress={() => setCurrentScreen('wordbank')}
              />
            )}
          </GestureHandlerRootView>
        </QueryClientProvider>
      </SafeAreaProvider>
    );
  }

  console.log('🔐 App.js - User is not authenticated or has invalid ID, showing login screen');
  console.log('🔐 App.js - Auth state:', { isAuthenticated, userId: user?.id });
  
  return (
    <SafeAreaProvider>
      <QueryClientProvider client={queryClient}>
        <GestureHandlerRootView style={{ flex: 1 }}>
          <LoginScreen 
            onAppleSignIn={signInWithApple}
            onGoogleSignIn={signInWithGoogle}
            onEmailSignIn={signInWithEmail}
          />
        </GestureHandlerRootView>
      </QueryClientProvider>
    </SafeAreaProvider>
  );
}
