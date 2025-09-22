import React, { useState, useCallback, useEffect } from 'react';
import {
  View,
  Text,
  StyleSheet,
  StatusBar,
  ActivityIndicator,
  Alert,
  TouchableOpacity,
} from 'react-native';
import { Ionicons } from '@expo/vector-icons';
import { PagedList } from '../components/PagedList';
import { useCardPrefetch } from '../hooks/useCardPrefetch';
import { WordCard } from '../components/WordCard';
import { BottomNavigation } from '../components/BottomNavigation';
import { getDailyWord } from '../services/api';
import { mapDailyWordResponse } from '../utils/wordMapper';

export function PagedHomeScreen({ user, navigation, onProfilePress, onWordbankPress }) {
  const [currentIndex, setCurrentIndex] = useState(0);
  const [wordQueue, setWordQueue] = useState([]);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState(null);
  const [hasNextCursor, setHasNextCursor] = useState(true);
  const [hasPreviousCursor, setHasPreviousCursor] = useState(false);

  // Fetch next word from API
  const fetchNextWord = useCallback(async () => {
    if (!user?.id) {
      console.log('No user ID available yet, skipping word fetch');
      return null;
    }

    setLoading(true);
    setError(null);

    try {
      const response = await getDailyWord(user.id);
      
      const word = mapDailyWordResponse(response);
      if (word) {
        setWordQueue(prev => [...prev, word]);
        return word;
      } else {
        setHasNextCursor(false);
      }
    } catch (error) {
      console.error('Error fetching daily word:', error);
      setError(error.message);
    } finally {
      setLoading(false);
    }

    return null;
  }, [user?.id]);

  // Fetch previous word (placeholder for now)
  const fetchPreviousWord = useCallback(async () => {
    // TODO: Implement previous word fetching
    console.log('Fetching previous word...');
  }, []);

  // Handle near end trigger
  const handleNearEnd = useCallback((index) => {
    console.log('Near end triggered at index:', index);
    if (hasNextCursor && !loading) {
      fetchNextWord();
    }
  }, [hasNextCursor, loading, fetchNextWord]);

  // Handle index change
  const handleIndexChange = useCallback((newIndex) => {
    console.log('Index changed to:', newIndex);
    setCurrentIndex(newIndex);
  }, []);

  // Load initial words
  useEffect(() => {
    if (user?.id && wordQueue.length === 0) {
      // Load initial batch of words
      const loadInitialWords = async () => {
        for (let i = 0; i < 5; i++) {
          await fetchNextWord();
        }
      };
      loadInitialWords();
    }
  }, [user?.id, wordQueue.length, fetchNextWord]);

  // Render word card
  const renderWordCard = useCallback((word, index) => {
    if (!word || word.isLoading) {
      return (
        <View style={styles.loadingCard}>
          <ActivityIndicator size="large" color="#007AFF" />
          <Text style={styles.loadingText}>Loading word...</Text>
        </View>
      );
    }

    return (
      <WordCard
        word={word}
        onFavorite={(wordId) => console.log('Favorite:', wordId)}
        onLearnAgain={(wordId) => console.log('Learn again:', wordId)}
        onAskLarry={(word) => navigation.navigate('LarryChat', { word })}
        travelBoost={null}
        testID={`word-card-${index}`}
      />
    );
  }, [navigation]);

  // Handle navigation
  const handleNavigation = useCallback((screen) => {
    if (screen === 'profile') {
      onProfilePress();
    } else if (screen === 'wordbank') {
      onWordbankPress();
    }
  }, [onProfilePress, onWordbankPress]);

  // Show loading state
  if (loading && wordQueue.length === 0) {
    return (
      <View style={styles.container}>
        <StatusBar barStyle="dark-content" backgroundColor="#fff" />
        <View style={styles.loadingContainer}>
          <ActivityIndicator size="large" color="#007AFF" />
          <Text style={styles.loadingText}>Loading your daily words...</Text>
        </View>
      </View>
    );
  }

  // Show error state
  if (error && wordQueue.length === 0) {
    return (
      <View style={styles.container}>
        <StatusBar barStyle="dark-content" backgroundColor="#fff" />
        <View style={styles.errorContainer}>
          <Text style={styles.errorText}>Failed to load words</Text>
          <TouchableOpacity style={styles.retryButton} onPress={fetchNextWord}>
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

      {/* Paged List */}
      <View style={styles.listContainer}>
        <PagedList
          data={wordQueue}
          index={currentIndex}
          onIndexChange={handleIndexChange}
          onNearEnd={handleNearEnd}
          renderItem={renderWordCard}
        />
      </View>

      {/* Loading indicator for more words */}
      {loading && wordQueue.length > 0 && (
        <View style={styles.loadingMoreContainer}>
          <ActivityIndicator size="small" color="#007AFF" />
          <Text style={styles.loadingMoreText}>Loading more words...</Text>
        </View>
      )}

      {/* End of feed indicator */}
      {!hasNextCursor && wordQueue.length > 0 && (
        <View style={styles.endOfFeedContainer}>
          <Text style={styles.endOfFeedText}>You're all caught up! 🎯</Text>
          <TouchableOpacity style={styles.refreshButton} onPress={fetchNextWord}>
            <Text style={styles.refreshButtonText}>Refresh</Text>
          </TouchableOpacity>
        </View>
      )}

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
  listContainer: {
    flex: 1,
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
  loadingCard: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: '#fff',
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
  loadingMoreContainer: {
    position: 'absolute',
    bottom: 100,
    left: 0,
    right: 0,
    alignItems: 'center',
    paddingVertical: 16,
  },
  loadingMoreText: {
    marginTop: 8,
    fontSize: 14,
    color: '#666',
  },
  endOfFeedContainer: {
    position: 'absolute',
    bottom: 100,
    left: 0,
    right: 0,
    alignItems: 'center',
    paddingVertical: 16,
  },
  endOfFeedText: {
    fontSize: 16,
    color: '#666',
    textAlign: 'center',
    marginBottom: 12,
  },
  refreshButton: {
    backgroundColor: '#007AFF',
    paddingHorizontal: 24,
    paddingVertical: 12,
    borderRadius: 8,
  },
  refreshButtonText: {
    color: '#fff',
    fontSize: 16,
    fontWeight: '600',
  },
});
