import { useState, useEffect, useCallback } from 'react';
import { getDailyWord, markLearnAgain } from '../services/api';
import { mapDailyWordResponse } from '../utils/wordMapper';
import AsyncStorage from '@react-native-async-storage/async-storage';

export function useDaily(userId) {
  const [currentWord, setCurrentWord] = useState(null);
  const [wordQueue, setWordQueue] = useState([]);
  const [currentIndex, setCurrentIndex] = useState(0);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState(null);
  const [dailyCount, setDailyCount] = useState(0);
  const [maxDailyWords, setMaxDailyWords] = useState(999); // Temporary: no limit for testing

  // Load daily count from storage on mount
  useEffect(() => {
    const loadDailyCount = async () => {
      try {
        const stored = await AsyncStorage.getItem(`dailyCount_${userId}`);
        const lastDate = await AsyncStorage.getItem(`lastDailyDate_${userId}`);
        const today = new Date().toDateString();
        
        if (lastDate === today && stored) {
          setDailyCount(parseInt(stored, 10));
        } else {
          // Reset for new day
          setDailyCount(0);
          await AsyncStorage.setItem(`lastDailyDate_${userId}`, today);
        }
      } catch (error) {
        console.error('Error loading daily count:', error);
      }
    };
    
    if (userId) {
      loadDailyCount();
    }
  }, [userId]);

  // Save daily count to storage
  const saveDailyCount = useCallback(async (count) => {
    try {
      if (userId) {
        await AsyncStorage.setItem(`dailyCount_${userId}`, count.toString());
      }
    } catch (error) {
      console.error('Error saving daily count:', error);
    }
  }, [userId]);

  // Fetch next word from API
  const fetchNextWord = useCallback(async () => {
    if (!userId) {
      console.log('No user ID available yet, skipping word fetch');
      return null;
    }

    if (dailyCount >= maxDailyWords) {
      setError('Daily limit reached');
      return null;
    }

    console.log('Fetching next word...');
    setLoading(true);
    setError(null);

    try {
      const response = await getDailyWord(userId);
      
      const word = mapDailyWordResponse(response);
      if (word) {
        console.log('Word fetched successfully:', word.term);
        setWordQueue(prev => {
          const newQueue = [...prev, word];
          console.log('Updated queue length:', newQueue.length);
          return newQueue;
        });
        setDailyCount(prev => {
          const newCount = prev + 1;
          saveDailyCount(newCount);
          return newCount;
        });
        return word;
      }
    } catch (error) {
      console.error('Error fetching daily word:', error);
      setError(error.message);
    } finally {
      setLoading(false);
    }

    return null;
  }, [userId, dailyCount, maxDailyWords, saveDailyCount]);

  // Load initial word only when userId is available
  useEffect(() => {
    if (userId && wordQueue.length === 0 && !loading) {
      fetchNextWord();
    }
  }, [userId, wordQueue.length, loading, fetchNextWord]);

  // Force preload multiple words on mount
  useEffect(() => {
    if (userId && wordQueue.length > 0 && wordQueue.length < 5 && !loading) {
      console.log('Force preloading to get more words...');
      // Fetch multiple words to ensure we have enough
      const preloadWords = async () => {
        for (let i = 0; i < 3; i++) {
          await fetchNextWord();
        }
      };
      preloadWords();
    }
  }, [userId, wordQueue.length, loading, fetchNextWord]);

  // Preload words when getting close to end of queue
  useEffect(() => {
    console.log('Preload check:', {
      userId: !!userId,
      wordQueueLength: wordQueue.length,
      currentIndex,
      canViewMoreWords,
      loading,
      shouldPreload: currentIndex >= wordQueue.length - 2
    });
    
    if (userId && wordQueue.length > 0 && wordQueue.length <= 3 && canViewMoreWords && !loading) {
      console.log('Preloading next word...');
      fetchNextWord();
    }
  }, [userId, wordQueue.length, currentIndex, canViewMoreWords, loading, fetchNextWord]);

  // Get current word
  useEffect(() => {
    if (wordQueue.length > 0 && currentIndex < wordQueue.length) {
      setCurrentWord(wordQueue[currentIndex]);
    }
  }, [wordQueue, currentIndex]);

  // Navigate to next word
  const goToNextWord = useCallback(async () => {
    const nextIndex = currentIndex + 1;
    
    // If we're at the end of the queue, fetch more words
    if (nextIndex >= wordQueue.length) {
      await fetchNextWord();
    }
    
    if (nextIndex < wordQueue.length + 1) { // +1 for the word we just fetched
      setCurrentIndex(nextIndex);
    }
  }, [currentIndex, wordQueue.length, fetchNextWord]);

  // Navigate to previous word
  const goToPreviousWord = useCallback(() => {
    if (currentIndex > 0) {
      setCurrentIndex(currentIndex - 1);
    }
  }, [currentIndex]);

  // Mark word for learning again
  const markWordForLearningAgain = useCallback(async (wordId) => {
    if (!userId) {
      console.log('No user ID available, cannot mark word for learning again');
      return;
    }

    try {
      // Optimistic update
      setCurrentWord(prev => prev ? { ...prev, learnAgain: true } : null);
      
      // API call
      await markLearnAgain(wordId, userId);
      
      // Remove from current queue to avoid repeats
      setWordQueue(prev => prev.filter(word => word.id !== wordId));
      
      // If this was the current word, move to next
      if (currentWord?.id === wordId) {
        goToNextWord();
      }
    } catch (error) {
      console.error('Error marking word for learning again:', error);
      // Revert optimistic update
      setCurrentWord(prev => prev ? { ...prev, learnAgain: false } : null);
    }
  }, [currentWord, goToNextWord, userId]);

  // Check if user can view more words
  const canViewMoreWords = dailyCount < maxDailyWords;

  // Get travel boost info (placeholder for now)
  const getTravelBoost = useCallback(() => {
    // TODO: Implement travel boost logic
    return null;
  }, []);

  return {
    // Current word data
    currentWord,
    loading,
    error,
    
    // Word queue for peek functionality
    wordQueue,
    currentIndex,
    
    // Navigation
    goToNextWord,
    goToPreviousWord,
    canGoPrevious: currentIndex > 0,
    
    // Actions
    markWordForLearningAgain,
    
    // Entitlements
    dailyCount,
    maxDailyWords,
    canViewMoreWords,
    
    // Travel boost
    travelBoost: getTravelBoost(),
    
    // Refresh
    refresh: fetchNextWord,
  };
}
