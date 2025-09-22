import React, { useState, useEffect } from 'react';
import {
  View,
  Text,
  StyleSheet,
  ScrollView,
  TouchableOpacity,
  Dimensions,
  Image,
  ActivityIndicator,
} from 'react-native';
import { Ionicons } from '@expo/vector-icons';
import { useAuth } from '../hooks/useAuth';
import { getInterestWords, favoriteWord } from '../services/api';

const { width } = Dimensions.get('window');

export function InterestDetailScreen({ navigation, route }) {
  const { interest } = route.params;
  const { user } = useAuth();
  const [words, setWords] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  useEffect(() => {
    fetchWordsForInterest();
  }, [interest, user?.id]);

  const fetchWordsForInterest = async () => {
    try {
      setLoading(true);
      setError(null);
      
      if (!user?.id) {
        console.log('No user ID available, skipping word fetch');
        return;
      }
      
      // TODO: Replace with real API call when backend endpoint is ready
      // const words = await getInterestWords(interest.id, user.id);
      
      // Mock data based on interest category
      let mockWords = [];
      
      switch (interest.name.toLowerCase()) {
        case 'technology':
          mockWords = [
            {
              id: '1',
              term: 'Algorithm',
              definition: 'A step-by-step procedure for solving a problem or accomplishing a task.',
              examples: ['The search algorithm quickly found the target value.'],
              isFavorited: true,
              difficulty: 'medium',
              lastReviewed: '2024-01-15',
            },
            {
              id: '2',
              term: 'Machine Learning',
              definition: 'A subset of artificial intelligence that enables computers to learn without being explicitly programmed.',
              examples: ['The machine learning model improved its accuracy over time.'],
              isFavorited: false,
              difficulty: 'hard',
              lastReviewed: '2024-01-14',
            },
            {
              id: '3',
              term: 'API',
              definition: 'Application Programming Interface - a set of rules that allows different software applications to communicate.',
              examples: ['The weather app uses an API to fetch current conditions.'],
              isFavorited: true,
              difficulty: 'easy',
              lastReviewed: '2024-01-13',
            },
            {
              id: '4',
              term: 'Database',
              definition: 'An organized collection of structured information or data, typically stored electronically.',
              examples: ['The company stores customer information in a secure database.'],
              isFavorited: false,
              difficulty: 'medium',
              lastReviewed: '2024-01-12',
            },
          ];
          break;
          
        case 'psychology':
          mockWords = [
            {
              id: '5',
              term: 'Cognitive Dissonance',
              definition: 'The mental discomfort experienced when holding two conflicting beliefs or values.',
              examples: ['She felt cognitive dissonance when her actions didn\'t match her beliefs.'],
              isFavorited: true,
              difficulty: 'hard',
              lastReviewed: '2024-01-15',
            },
            {
              id: '6',
              term: 'Confirmation Bias',
              definition: 'The tendency to search for, interpret, and remember information that confirms one\'s preexisting beliefs.',
              examples: ['His confirmation bias made him only notice articles that supported his viewpoint.'],
              isFavorited: false,
              difficulty: 'medium',
              lastReviewed: '2024-01-14',
            },
            {
              id: '7',
              term: 'Empathy',
              definition: 'The ability to understand and share the feelings of another person.',
              examples: ['Her empathy helped her connect with patients on a deeper level.'],
              isFavorited: true,
              difficulty: 'easy',
              lastReviewed: '2024-01-13',
            },
            {
              id: '8',
              term: 'Neuroplasticity',
              definition: 'The brain\'s ability to form and reorganize synaptic connections, especially in response to learning.',
              examples: ['Neuroplasticity allows the brain to adapt to new experiences and learning.'],
              isFavorited: false,
              difficulty: 'hard',
              lastReviewed: '2024-01-12',
            },
          ];
          break;
          
        case 'business':
          mockWords = [
            {
              id: '9',
              term: 'ROI',
              definition: 'Return on Investment - a performance measure used to evaluate the efficiency of an investment.',
              examples: ['The marketing campaign had a strong ROI of 300%.'],
              isFavorited: true,
              difficulty: 'medium',
              lastReviewed: '2024-01-15',
            },
            {
              id: '10',
              term: 'Scalability',
              definition: 'The ability of a system to handle increased workload without compromising performance.',
              examples: ['The cloud infrastructure provides excellent scalability for growing businesses.'],
              isFavorited: false,
              difficulty: 'medium',
              lastReviewed: '2024-01-14',
            },
            {
              id: '11',
              term: 'Synergy',
              definition: 'The interaction of elements that when combined produce a total effect greater than the sum of individual elements.',
              examples: ['The merger created synergy between the two companies\' strengths.'],
              isFavorited: true,
              difficulty: 'easy',
              lastReviewed: '2024-01-13',
            },
            {
              id: '12',
              term: 'Disruption',
              definition: 'A significant change in an industry or market that creates new opportunities and challenges.',
              examples: ['Uber caused major disruption in the traditional taxi industry.'],
              isFavorited: false,
              difficulty: 'medium',
              lastReviewed: '2024-01-12',
            },
          ];
          break;
          
        default:
          // Generic words for any other interest
          mockWords = [
            {
              id: '13',
              term: 'Innovation',
              definition: 'A new method, idea, or product that creates value.',
              examples: ['The company\'s innovation led to breakthrough products.'],
              isFavorited: true,
              difficulty: 'medium',
              lastReviewed: '2024-01-15',
            },
            {
              id: '14',
              term: 'Strategy',
              definition: 'A plan of action designed to achieve a long-term or overall aim.',
              examples: ['The team developed a comprehensive strategy for growth.'],
              isFavorited: false,
              difficulty: 'medium',
              lastReviewed: '2024-01-14',
            },
            {
              id: '15',
              term: 'Collaboration',
              definition: 'The action of working with someone to produce or create something.',
              examples: ['Effective collaboration led to successful project completion.'],
              isFavorited: true,
              difficulty: 'easy',
              lastReviewed: '2024-01-13',
            },
          ];
      }
      
      setWords(mockWords);
    } catch (err) {
      setError('Failed to load words');
      console.error('Error fetching words:', err);
    } finally {
      setLoading(false);
    }
  };

  const handleWordPress = (word) => {
    // TODO: Navigate to word detail or review screen
    console.log('Word pressed:', word.term);
  };

  const handleFavorite = async (wordId) => {
    if (!user?.id) {
      console.log('No user ID available, cannot toggle favorite');
      return;
    }

    try {
      // TODO: Implement favorite toggle with real API
      // await favoriteWord(wordId, user.id);
      console.log('Toggle favorite for word:', wordId);
    } catch (error) {
      console.error('Error toggling favorite:', error);
    }
  };

  const handleBack = () => {
    navigation.goBack();
  };

  const getDifficultyColor = (difficulty) => {
    switch (difficulty) {
      case 'easy': return '#4CAF50';
      case 'medium': return '#FF9800';
      case 'hard': return '#F44336';
      default: return '#666';
    }
  };

  const formatDate = (dateString) => {
    const date = new Date(dateString);
    return date.toLocaleDateString('en-US', { 
      month: 'short', 
      day: 'numeric' 
    });
  };

  if (loading) {
    return (
      <View style={styles.loadingContainer}>
        <ActivityIndicator size="large" color="#007AFF" />
        <Text style={styles.loadingText}>Loading words...</Text>
      </View>
    );
  }

  if (error) {
    return (
      <View style={styles.errorContainer}>
        <Ionicons name="alert-circle" size={48} color="#F44336" />
        <Text style={styles.errorText}>{error}</Text>
        <TouchableOpacity style={styles.retryButton} onPress={fetchWordsForInterest}>
          <Text style={styles.retryButtonText}>Retry</Text>
        </TouchableOpacity>
      </View>
    );
  }

  return (
    <View style={styles.container}>
      {/* Header */}
      <View style={styles.header}>
        <TouchableOpacity style={styles.backButton} onPress={handleBack}>
          <Ionicons name="chevron-back" size={24} color="#000" />
        </TouchableOpacity>
        <View style={styles.headerContent}>
          <Text style={styles.headerTitle}>{interest.name}</Text>
          <Text style={styles.wordCount}>{words.length} words learned</Text>
        </View>
        <TouchableOpacity style={styles.moreButton}>
          <Ionicons name="ellipsis-horizontal" size={24} color="#000" />
        </TouchableOpacity>
      </View>

      {/* Interest Banner */}
      <View style={styles.interestBanner}>
        <Image source={{ uri: interest.image }} style={styles.interestImage} />
        <View style={styles.interestOverlay}>
          <Text style={styles.interestName}>{interest.name}</Text>
          <Text style={styles.interestDescription}>
            Words you've learned in {interest.name.toLowerCase()}
          </Text>
        </View>
      </View>

      {/* Words List */}
      <ScrollView style={styles.wordsContainer} showsVerticalScrollIndicator={false}>
        {words.map((word) => (
          <TouchableOpacity
            key={word.id}
            style={styles.wordCard}
            onPress={() => handleWordPress(word)}
          >
            <View style={styles.wordHeader}>
              <View style={styles.wordInfo}>
                <Text style={styles.wordTerm}>{word.term}</Text>
                <View style={styles.wordMeta}>
                  <View style={[
                    styles.difficultyBadge,
                    { backgroundColor: getDifficultyColor(word.difficulty) }
                  ]}>
                    <Text style={styles.difficultyText}>
                      {word.difficulty.charAt(0).toUpperCase() + word.difficulty.slice(1)}
                    </Text>
                  </View>
                  <Text style={styles.lastReviewed}>
                    Last: {formatDate(word.lastReviewed)}
                  </Text>
                </View>
              </View>
              <TouchableOpacity
                style={styles.favoriteButton}
                onPress={() => handleFavorite(word.id)}
              >
                <Ionicons
                  name={word.isFavorited ? "heart" : "heart-outline"}
                  size={20}
                  color={word.isFavorited ? "#FF6B6B" : "#666"}
                />
              </TouchableOpacity>
            </View>
            
            <Text style={styles.wordDefinition} numberOfLines={2}>
              {word.definition}
            </Text>
            
            {word.examples && word.examples.length > 0 && (
              <Text style={styles.wordExample} numberOfLines={1}>
                "{word.examples[0]}"
              </Text>
            )}
          </TouchableOpacity>
        ))}
      </ScrollView>
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
  },
  errorContainer: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: '#fff',
    paddingHorizontal: 20,
  },
  errorText: {
    marginTop: 16,
    fontSize: 16,
    color: '#666',
    textAlign: 'center',
  },
  retryButton: {
    marginTop: 20,
    paddingHorizontal: 24,
    paddingVertical: 12,
    backgroundColor: '#007AFF',
    borderRadius: 8,
  },
  retryButtonText: {
    color: '#fff',
    fontSize: 16,
    fontWeight: '600',
  },
  header: {
    flexDirection: 'row',
    alignItems: 'center',
    paddingHorizontal: 20,
    paddingTop: 50,
    paddingBottom: 16,
    backgroundColor: '#fff',
    borderBottomWidth: 1,
    borderBottomColor: '#F0F0F0',
  },
  backButton: {
    marginRight: 16,
  },
  headerContent: {
    flex: 1,
  },
  headerTitle: {
    fontSize: 20,
    fontWeight: 'bold',
    color: '#000',
  },
  wordCount: {
    fontSize: 14,
    color: '#666',
    marginTop: 2,
  },
  moreButton: {
    marginLeft: 16,
  },
  interestBanner: {
    height: 120,
    position: 'relative',
    marginHorizontal: 20,
    marginTop: 16,
    borderRadius: 12,
    overflow: 'hidden',
  },
  interestImage: {
    width: '100%',
    height: '100%',
  },
  interestOverlay: {
    position: 'absolute',
    bottom: 0,
    left: 0,
    right: 0,
    backgroundColor: 'rgba(0,0,0,0.7)',
    padding: 16,
  },
  interestName: {
    color: '#fff',
    fontSize: 18,
    fontWeight: 'bold',
    marginBottom: 4,
  },
  interestDescription: {
    color: '#fff',
    fontSize: 14,
    opacity: 0.9,
  },
  wordsContainer: {
    flex: 1,
    paddingHorizontal: 20,
    paddingTop: 16,
  },
  wordCard: {
    backgroundColor: '#fff',
    borderRadius: 12,
    padding: 16,
    marginBottom: 12,
    borderWidth: 1,
    borderColor: '#F0F0F0',
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.1,
    shadowRadius: 4,
    elevation: 2,
  },
  wordHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'flex-start',
    marginBottom: 8,
  },
  wordInfo: {
    flex: 1,
  },
  wordTerm: {
    fontSize: 18,
    fontWeight: 'bold',
    color: '#000',
    marginBottom: 6,
  },
  wordMeta: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  difficultyBadge: {
    paddingHorizontal: 8,
    paddingVertical: 2,
    borderRadius: 12,
    marginRight: 8,
  },
  difficultyText: {
    color: '#fff',
    fontSize: 10,
    fontWeight: '600',
  },
  lastReviewed: {
    fontSize: 12,
    color: '#666',
  },
  favoriteButton: {
    padding: 4,
  },
  wordDefinition: {
    fontSize: 14,
    color: '#333',
    lineHeight: 20,
    marginBottom: 8,
  },
  wordExample: {
    fontSize: 13,
    color: '#666',
    fontStyle: 'italic',
  },
});
