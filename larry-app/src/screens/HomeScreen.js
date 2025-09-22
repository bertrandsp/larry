import React, { useRef, useEffect, useState } from 'react';
import {
  View,
  Text,
  StyleSheet,
  Dimensions,
  Animated,
  Alert,
  TouchableOpacity,
  StatusBar,
  ScrollView,
  ActivityIndicator,
} from 'react-native';
import { PanGestureHandler, State } from 'react-native-gesture-handler';
import { useDaily } from '../hooks/useDaily';
import { WordCard } from '../components/WordCard';
import { BottomNavigation } from '../components/BottomNavigation';
import { useAuth } from '../hooks/useAuth';
import { Ionicons } from '@expo/vector-icons';

const { width, height } = Dimensions.get('window');

export function HomeScreen({ navigation, onProfilePress, onWordbankPress }) {
  const { user } = useAuth();
  const {
    currentWord,
    loading,
    error,
    goToNextWord,
    goToPreviousWord,
    canGoPrevious,
    markWordForLearningAgain,
    dailyCount,
    maxDailyWords,
    canViewMoreWords,
    travelBoost,
  } = useDaily(user?.id); // Pass user ID to useDaily hook

  const [currentIndex, setCurrentIndex] = useState(0);
  const translateY = useRef(new Animated.Value(0)).current;
  const opacity = useRef(new Animated.Value(1)).current;

  // Show loading state if user is not fully loaded yet
  if (!user?.id) {
    return (
      <View style={styles.container}>
        <StatusBar barStyle="dark-content" backgroundColor="#fff" />
        <View style={styles.loadingContainer}>
          <ActivityIndicator size="large" color="#007AFF" />
          <Text style={styles.loadingText}>Loading your personalized content...</Text>
        </View>
      </View>
    );
  }

  // Handle swipe gestures
  const onGestureEvent = Animated.event(
    [{ nativeEvent: { translationY: translateY } }],
    { useNativeDriver: true }
  );

  const onHandlerStateChange = (event) => {
    if (event.nativeEvent.state === State.END) {
      const { translationY } = event.nativeEvent;
      
      if (translationY < -50) {
        // Swipe up - next word
        handleSwipeUp();
      } else if (translationY > 50 && canGoPrevious) {
        // Swipe down - previous word
        handleSwipeDown();
      } else {
        // Reset position
        resetCardPosition();
      }
    }
  };

  const handleSwipeUp = async () => {
    if (!canViewMoreWords) {
      Alert.alert(
        'Daily Limit Reached',
        'You\'ve reached your daily word limit. Upgrade to continue learning!',
        [
          { text: 'Cancel', style: 'cancel' },
          { text: 'Upgrade', onPress: () => navigation.navigate('Paywall') }
        ]
      );
      resetCardPosition();
      return;
    }

    // Animate card out
    Animated.parallel([
      Animated.timing(translateY, {
        toValue: -height,
        duration: 300,
        useNativeDriver: true,
      }),
      Animated.timing(opacity, {
        toValue: 0,
        duration: 300,
        useNativeDriver: true,
      }),
    ]).start(async () => {
      await goToNextWord();
      setCurrentIndex(prev => prev + 1);
      resetCardPosition();
    });
  };

  const handleSwipeDown = () => {
    // Animate card out
    Animated.parallel([
      Animated.timing(translateY, {
        toValue: height,
        duration: 300,
        useNativeDriver: true,
      }),
      Animated.timing(opacity, {
        toValue: 0,
        duration: 300,
        useNativeDriver: true,
      }),
    ]).start(() => {
      goToPreviousWord();
      setCurrentIndex(prev => Math.max(0, prev - 1));
      resetCardPosition();
    });
  };

  const resetCardPosition = () => {
    Animated.parallel([
      Animated.timing(translateY, {
        toValue: 0,
        duration: 200,
        useNativeDriver: true,
      }),
      Animated.timing(opacity, {
        toValue: 1,
        duration: 200,
        useNativeDriver: true,
      }),
    ]).start();
  };

  // Handle word actions
  const handleFavorite = (wordId) => {
    // TODO: Implement favorite functionality
    console.log('Favorite word:', wordId);
  };

  const handleLearnAgain = (wordId) => {
    markWordForLearningAgain(wordId);
  };

  const handleAskLarry = (word) => {
    navigation.navigate('LarryChat', { word });
  };

  // Handle navigation
  const handleNavigation = (screen) => {
    if (screen === 'profile') {
      onProfilePress();
    } else if (screen === 'wordbank') {
      onWordbankPress();
    }
    // Add other navigation handlers as needed
  };

  // Show loading state
  if (loading && !currentWord) {
    return (
      <View style={styles.container}>
        <StatusBar barStyle="dark-content" backgroundColor="#fff" />
        <View style={styles.loadingContainer}>
          <Text style={styles.loadingText}>Loading your daily words...</Text>
        </View>
      </View>
    );
  }

  // Show error state
  if (error) {
    return (
      <View style={styles.container}>
        <StatusBar barStyle="dark-content" backgroundColor="#fff" />
        <View style={styles.errorContainer}>
          <Text style={styles.errorText}>{error}</Text>
          <TouchableOpacity style={styles.retryButton}>
            <Text style={styles.retryButtonText}>Retry</Text>
          </TouchableOpacity>
        </View>
      </View>
    );
  }

  return (
    <View style={styles.container}>
      <StatusBar barStyle="dark-content" backgroundColor="#fff" />
      
      {/* Header */}
      <View style={styles.header}>
        <Text style={styles.headerTitle}>Daily Word</Text>
        <TouchableOpacity style={styles.notificationButton}>
          <Ionicons name="notifications-outline" size={24} color="#000" />
        </TouchableOpacity>
      </View>

      {/* Word Cards Container */}
      <ScrollView style={styles.scrollContainer} showsVerticalScrollIndicator={false}>
        {/* Current Word Card */}
        <PanGestureHandler
          onGestureEvent={onGestureEvent}
          onHandlerStateChange={onHandlerStateChange}
        >
          <Animated.View
            style={[
              styles.cardWrapper,
              {
                transform: [{ translateY }],
                opacity,
              },
            ]}
          >
            <WordCard
              word={currentWord}
              onFavorite={handleFavorite}
              onLearnAgain={handleLearnAgain}
              onAskLarry={handleAskLarry}
              travelBoost={travelBoost}
              testID="word-card"
            />
          </Animated.View>
        </PanGestureHandler>

        {/* Daily Limit Warning */}
        {!canViewMoreWords && (
          <View style={styles.limitWarning}>
            <Text style={styles.limitText}>
              You've reached your daily limit! 🎯
            </Text>
            <TouchableOpacity 
              style={styles.upgradeButton}
              onPress={() => navigation.navigate('Paywall')}
            >
              <Text style={styles.upgradeButtonText}>Upgrade to Continue</Text>
            </TouchableOpacity>
          </View>
        )}
      </ScrollView>

      {/* Shared Bottom Navigation */}
      <BottomNavigation 
        currentScreen="home" 
        onNavigate={handleNavigation}
      />
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#fff',
  },
  loadingContainer: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: '#fff',
  },
  loadingText: {
    marginTop: 16,
    fontSize: 16,
    color: '#666',
    textAlign: 'center',
  },
  errorContainer: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    padding: 20,
    backgroundColor: '#fff',
  },
  errorText: {
    fontSize: 16,
    color: '#E74C3C',
    textAlign: 'center',
    marginBottom: 20,
  },
  retryButton: {
    backgroundColor: '#3498DB',
    paddingHorizontal: 24,
    paddingVertical: 12,
    borderRadius: 8,
  },
  retryButtonText: {
    color: '#fff',
    fontSize: 16,
    fontWeight: '600',
  },
  header: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    paddingHorizontal: 20,
    paddingTop: 50,
    paddingBottom: 16,
    backgroundColor: '#fff',
    borderBottomWidth: 1,
    borderBottomColor: '#F0F0F0',
  },
  headerTitle: {
    fontSize: 24,
    fontWeight: 'bold',
    color: '#000',
  },
  notificationButton: {
    width: 40,
    height: 40,
    justifyContent: 'center',
    alignItems: 'center',
  },
  scrollContainer: {
    flex: 1,
  },
  cardWrapper: {
    marginVertical: 8,
  },
  limitWarning: {
    backgroundColor: '#FFF3CD',
    margin: 16,
    padding: 16,
    borderRadius: 12,
    alignItems: 'center',
  },
  limitText: {
    fontSize: 16,
    color: '#856404',
    fontWeight: '600',
    marginBottom: 12,
  },
  upgradeButton: {
    backgroundColor: '#FF6B6B',
    paddingHorizontal: 24,
    paddingVertical: 12,
    borderRadius: 8,
  },
  upgradeButtonText: {
    color: '#fff',
    fontSize: 16,
    fontWeight: '600',
  },
});
