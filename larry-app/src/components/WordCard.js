import React from 'react';
import {
  View,
  Text,
  TouchableOpacity,
  StyleSheet,
  Dimensions,
  Alert,
  Image,
} from 'react-native';
import { Ionicons } from '@expo/vector-icons';

const { width, height } = Dimensions.get('window');
const CARD_HEIGHT = height * 0.7; // Card takes 70% of screen height

// Mock image URLs for different word categories
const getWordImage = (word) => {
  const term = word.term?.toLowerCase() || '';
  
  // Map words to relevant images (in a real app, these would be actual images)
  if (term.includes('ephemeral') || term.includes('temporary') || term.includes('blossom')) {
    return 'https://images.unsplash.com/photo-1522383225653-ed111181a951?w=400&h=200&fit=crop';
  } else if (term.includes('ubiquitous') || term.includes('everywhere') || term.includes('phone')) {
    return 'https://images.unsplash.com/photo-1511707171634-5f897ff02aa9?w=400&h=200&fit=crop';
  } else if (term.includes('mellifluous') || term.includes('voice') || term.includes('music')) {
    return 'https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=400&h=200&fit=crop';
  } else if (term.includes('serendipity') || term.includes('discovery') || term.includes('lightbulb')) {
    return 'https://images.unsplash.com/photo-1507146426996-ef05306b995a?w=400&h=200&fit=crop';
  } else if (term.includes('technology') || term.includes('computer') || term.includes('digital')) {
    return 'https://images.unsplash.com/photo-1518709268805-4e9042af2176?w=400&h=200&fit=crop';
  } else if (term.includes('psychology') || term.includes('mind') || term.includes('brain')) {
    return 'https://images.unsplash.com/photo-1559757148-5c350d0d3c56?w=400&h=200&fit=crop';
  } else {
    // Default image
    return 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400&h=200&fit=crop';
  }
};

export function WordCard({ 
  word, 
  onFavorite, 
  onLearnAgain, 
  onAskLarry,
  onSwipeUp,
  onSwipeDown,
  travelBoost,
  testID = "word-card"
}) {
  if (!word) {
    return (
      <View style={styles.container} testID={testID}>
        <View style={styles.loadingContainer}>
          <Text style={styles.loadingText}>Loading word...</Text>
        </View>
      </View>
    );
  }

  // Validate word object has required properties
  if (!word.term || !word.definition) {
    return (
      <View style={styles.container} testID={testID}>
        <View style={styles.loadingContainer}>
          <Text style={styles.loadingText}>Invalid word data</Text>
        </View>
      </View>
    );
  }

  const handleFavorite = () => {
    onFavorite?.(word.id);
  };

  const handleLearnAgain = () => {
    Alert.alert(
      'Learn Again',
      'This word will appear again sooner for review.',
      [
        { text: 'Cancel', style: 'cancel' },
        { text: 'Learn Again', onPress: () => onLearnAgain?.(word.id) }
      ]
    );
  };

  const handleAskLarry = () => {
    onAskLarry?.(word);
  };

  const handleMaster = () => {
    Alert.alert(
      'Mark as Mastered',
      'This word will be removed from your daily rotation.',
      [
        { text: 'Cancel', style: 'cancel' },
        { text: 'Master', onPress: () => console.log('Mastered:', word.id) }
      ]
    );
  };

  const getPartOfSpeech = (term) => {
    // Simple logic to determine part of speech based on word ending
    if (!term || typeof term !== 'string') {
      return '(n.)'; // Default to noun if term is undefined or not a string
    }
    const word = term.toLowerCase();
    if (word.endsWith('ly')) return '(adv.)';
    if (word.endsWith('ing')) return '(v.)';
    if (word.endsWith('ed')) return '(v.)';
    if (word.endsWith('s')) return '(n.)';
    if (word.endsWith('al') || word.endsWith('ous') || word.endsWith('ful')) return '(adj.)';
    return '(n.)';
  };

  return (
    <View style={styles.container} testID={testID}>
      {/* Background Image */}
      <Image
        source={{ uri: getWordImage(word) }}
        style={styles.backgroundImage}
        resizeMode="cover"
      />
      
      {/* White Content Area */}
      <View style={styles.contentArea}>
        {/* Word Header */}
        <View style={styles.wordHeader}>
          <View style={styles.wordInfo}>
            <Text style={styles.term}>{word.term}</Text>
            <View style={styles.pronunciationContainer}>
              <TouchableOpacity style={styles.speakerButton}>
                <Ionicons name="volume-high" size={16} color="#666" />
              </TouchableOpacity>
              <Text style={styles.pronunciation}>/{word.pronunciation || 'prəˌnʌnsiˈeɪʃən'}/</Text>
              <Text style={styles.partOfSpeech}>{getPartOfSpeech(word.term)}</Text>
            </View>
          </View>
        </View>

        {/* Definition */}
        <View style={styles.definitionContainer}>
          <Text style={styles.definition}>
            {word.definition}
          </Text>
        </View>

        {/* Separator Line */}
        <View style={styles.separator} />

        {/* Example Sentence */}
        {word.examples && word.examples.length > 0 && (
          <View style={styles.exampleContainer}>
            <Text style={styles.example}>
              "{word.examples[0]}"
            </Text>
          </View>
        )}

        {/* Action Buttons */}
        <View style={styles.actionsContainer}>
          <TouchableOpacity 
            style={styles.actionButton} 
            onPress={handleFavorite}
            testID="favorite-button"
          >
            <Ionicons 
              name={word.isFavorited ? "heart" : "heart-outline"} 
              size={24} 
              color={word.isFavorited ? "#FF6B6B" : "#000"} 
            />
            <Text style={styles.actionText}>Favorite</Text>
          </TouchableOpacity>

          <TouchableOpacity 
            style={styles.actionButton} 
            onPress={handleLearnAgain}
            testID="learn-again-button"
          >
            <Ionicons name="refresh" size={24} color="#000" />
            <Text style={styles.actionText}>Learn Again</Text>
          </TouchableOpacity>

          <TouchableOpacity 
            style={styles.actionButton} 
            onPress={handleMaster}
            testID="master-button"
          >
            <View style={styles.masterIconContainer}>
              <Ionicons name="checkmark" size={20} color="#007AFF" />
            </View>
            <Text style={[styles.actionText, styles.masterText]}>Master</Text>
          </TouchableOpacity>
        </View>
      </View>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    width: width - 32,
    height: CARD_HEIGHT,
    backgroundColor: '#fff',
    borderRadius: 16,
    overflow: 'hidden',
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.1,
    shadowRadius: 8,
    elevation: 4,
    borderWidth: 1,
    borderColor: '#E5E5E5',
    alignSelf: 'center',
  },
  backgroundImage: {
    width: '100%',
    height: CARD_HEIGHT * 0.4, // 40% of card height for image
  },
  loadingContainer: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    padding: 40,
  },
  loadingText: {
    fontSize: 14, // 20% smaller (18 * 0.8)
    color: '#666',
  },
  contentArea: {
    padding: 20,
    flex: 1,
    justifyContent: 'space-between',
  },
  wordHeader: {
    marginBottom: 6,
  },
  wordInfo: {
    marginBottom: 8,
  },
  term: {
    fontSize: 26, // 20% smaller (32 * 0.8)
    fontWeight: 'bold',
    color: '#000',
    marginBottom: 4,
  },
  pronunciationContainer: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  speakerButton: {
    marginRight: 8,
    width: 24,
    height: 24,
    justifyContent: 'center',
    alignItems: 'center',
  },
  pronunciation: {
    fontSize: 13, // 20% smaller (16 * 0.8)
    color: '#666',
    fontStyle: 'italic',
    marginRight: 8,
  },
  partOfSpeech: {
    fontSize: 11, // 20% smaller (14 * 0.8)
    color: '#666',
  },
  definitionContainer: {
    marginBottom: 16,
  },
  definition: {
    fontSize: 14, // 20% smaller (18 * 0.8)
    color: '#000',
    lineHeight: 19, // 20% smaller (24 * 0.8)
  },
  separator: {
    height: 1,
    backgroundColor: '#E5E5E5',
    marginBottom: 16,
  },
  exampleContainer: {
    marginBottom: 10,
  },
  example: {
    fontSize: 13, // 20% smaller (16 * 0.8)
    color: '#666',
    fontStyle: 'italic',
    lineHeight: 18, // 20% smaller (22 * 0.8)
  },
  actionsContainer: {
    flexDirection: 'row',
    justifyContent: 'space-around',
    alignItems: 'center',
    marginTop: 'auto',
  },
  actionButton: {
    alignItems: 'center',
    paddingVertical: 12,
    paddingHorizontal: 16,
    minWidth: 80,
  },
  masterIconContainer: {
    width: 32,
    height: 32,
    borderRadius: 16,
    borderWidth: 2,
    borderColor: '#007AFF',
    justifyContent: 'center',
    alignItems: 'center',
    marginBottom: 4,
  },
  actionText: {
    fontSize: 10, // 20% smaller (12 * 0.8)
    color: '#000',
    marginTop: 4,
    fontWeight: '500',
  },
  masterText: {
    color: '#007AFF',
  },
});
