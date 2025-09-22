import React, { useState, useEffect } from 'react';
import { View, Text, StyleSheet, TouchableOpacity, SafeAreaView, ActivityIndicator, RefreshControl, ScrollView } from 'react-native';
import { getDailyWord } from '../services/api';
import { mapDailyWordResponse } from '../utils/wordMapper';

export default function HomeScreen({ user, onSignOut }) {
  const [dailyWord, setDailyWord] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [refreshing, setRefreshing] = useState(false);

  const fetchDailyWord = async () => {
    try {
      setError(null);
      const response = await getDailyWord();
      
      const wordData = mapDailyWordResponse(response);
      if (wordData) {
        setDailyWord(wordData);
      }
    } catch (err) {
      console.error('Failed to fetch daily word:', err);
      setError(err.message);
    } finally {
      setLoading(false);
      setRefreshing(false);
    }
  };

  const onRefresh = () => {
    setRefreshing(true);
    fetchDailyWord();
  };

  useEffect(() => {
    fetchDailyWord();
  }, []);

  const renderWordCard = () => {
    if (loading) {
      return (
        <View style={styles.card}>
          <View style={styles.loadingContainer}>
            <ActivityIndicator size="large" color="#3b82f6" />
            <Text style={styles.loadingText}>Loading today's word...</Text>
          </View>
        </View>
      );
    }

    if (error) {
      return (
        <View style={styles.card}>
          <View style={styles.errorContainer}>
            <Text style={styles.errorTitle}>❌ Error Loading Word</Text>
            <Text style={styles.errorText}>{error}</Text>
            <TouchableOpacity style={styles.retryButton} onPress={fetchDailyWord}>
              <Text style={styles.retryText}>Try Again</Text>
            </TouchableOpacity>
          </View>
        </View>
      );
    }

    if (!dailyWord) {
      return (
        <View style={styles.card}>
          <Text style={styles.errorText}>No word available today</Text>
        </View>
      );
    }

    return (
      <View style={styles.card}>
        <Text style={styles.cardTitle}>Today's Word</Text>
        <Text style={styles.word}>{dailyWord.term}</Text>
        <Text style={styles.definition}>{dailyWord.definition}</Text>
        {dailyWord.examples && dailyWord.examples.length > 0 && (
          <Text style={styles.example}>Example: {dailyWord.examples[0]}</Text>
        )}
        <Text style={styles.topic}>Topic: {dailyWord.topic}</Text>
      </View>
    );
  };

  return (
    <SafeAreaView style={styles.container}>
      <ScrollView 
        style={styles.content}
        refreshControl={
          <RefreshControl refreshing={refreshing} onRefresh={onRefresh} />
        }
      >
        <Text style={styles.title}>📚 Larry</Text>
        <Text style={styles.welcome}>Welcome back, {user?.name}!</Text>
        
        {renderWordCard()}
        
        <TouchableOpacity style={styles.signOutButton} onPress={onSignOut}>
          <Text style={styles.signOutText}>Sign Out</Text>
        </TouchableOpacity>
      </ScrollView>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#f9fafb',
  },
  content: {
    flex: 1,
    padding: 20,
  },
  title: {
    fontSize: 32,
    fontWeight: 'bold',
    color: '#1f2937',
    textAlign: 'center',
    marginTop: 20,
  },
  welcome: {
    fontSize: 18,
    color: '#6b7280',
    textAlign: 'center',
    marginBottom: 30,
  },
  card: {
    backgroundColor: '#ffffff',
    padding: 20,
    borderRadius: 12,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.1,
    shadowRadius: 4,
    elevation: 3,
    marginBottom: 20,
  },
  cardTitle: {
    fontSize: 14,
    color: '#6b7280',
    textTransform: 'uppercase',
    fontWeight: '600',
    marginBottom: 8,
  },
  word: {
    fontSize: 24,
    fontWeight: 'bold',
    color: '#1f2937',
    marginBottom: 8,
  },
  definition: {
    fontSize: 16,
    color: '#374151',
    lineHeight: 24,
    marginBottom: 12,
  },
  topic: {
    fontSize: 14,
    color: '#059669',
    fontWeight: '600',
  },
  signOutButton: {
    backgroundColor: '#ef4444',
    paddingVertical: 12,
    paddingHorizontal: 24,
    borderRadius: 8,
    alignItems: 'center',
    marginTop: 'auto',
  },
  signOutText: {
    color: '#ffffff',
    fontSize: 16,
    fontWeight: '600',
  },
  loadingContainer: {
    alignItems: 'center',
    paddingVertical: 20,
  },
  loadingText: {
    marginTop: 10,
    fontSize: 16,
    color: '#6b7280',
  },
  errorContainer: {
    alignItems: 'center',
    paddingVertical: 20,
  },
  errorTitle: {
    fontSize: 18,
    fontWeight: 'bold',
    color: '#dc2626',
    marginBottom: 10,
  },
  errorText: {
    fontSize: 14,
    color: '#6b7280',
    textAlign: 'center',
    marginBottom: 15,
  },
  retryButton: {
    backgroundColor: '#3b82f6',
    paddingVertical: 8,
    paddingHorizontal: 16,
    borderRadius: 6,
  },
  retryText: {
    color: '#ffffff',
    fontSize: 14,
    fontWeight: '600',
  },
  example: {
    fontSize: 14,
    color: '#6b7280',
    fontStyle: 'italic',
    marginBottom: 12,
    lineHeight: 20,
  },
});
