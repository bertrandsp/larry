import React, { useState, useEffect } from 'react';
import {
  View,
  Text,
  StyleSheet,
  ScrollView,
  TouchableOpacity,
  TextInput,
  Dimensions,
  Image,
  ActivityIndicator,
} from 'react-native';
import { Ionicons } from '@expo/vector-icons';
import { BottomNavigation } from '../components/BottomNavigation';
import { useAuth } from '../hooks/useAuth';
import { getUserInterests } from '../services/api';

const { width } = Dimensions.get('window');

export function WordbankScreen({ navigation }) {
  const { user } = useAuth();
  const [searchQuery, setSearchQuery] = useState('');
  const [activeFilter, setActiveFilter] = useState('All');
  const [userInterests, setUserInterests] = useState([]);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState(null);

  // Fetch user's actual interests from API
  useEffect(() => {
    const fetchUserInterests = async () => {
      if (!user?.id) return;
      
      setLoading(true);
      setError(null);
      
      try {
        // TODO: Replace with real API call when backend endpoint is ready
        // const interests = await getUserInterests(user.id);
        
        // Mock data based on user ID for now
        const interests = [
          { id: '1', name: 'Technology', image: 'https://images.unsplash.com/photo-1518709268805-4e9042af2176?w=200&h=200&fit=crop' },
          { id: '2', name: 'Psychology', image: 'https://images.unsplash.com/photo-1559757148-5c350d0d3c56?w=200&h=200&fit=crop' },
          { id: '3', name: 'Business', image: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=200&h=200&fit=crop' },
        ];
        setUserInterests(interests);
      } catch (err) {
        console.error('Error fetching user interests:', err);
        setError('Failed to load your interests');
      } finally {
        setLoading(false);
      }
    };

    fetchUserInterests();
  }, [user?.id]);

  const filterOptions = ['History', 'Favorites', 'Want to Master', 'All'];

  const handleNavigation = (screen) => {
    if (screen === 'home') {
      navigation.navigate('home');
    } else if (screen === 'profile') {
      navigation.navigate('profile');
    }
    // Add other navigation handlers as needed
  };

  const handleGoPremium = () => {
    // TODO: Implement premium upgrade flow
    console.log('Go Premium pressed');
  };

  const handleInterestPress = (interest) => {
    // Navigate to interest detail screen
    navigation.navigate('interestDetail', { interest });
  };

  const handleSearch = (query) => {
    setSearchQuery(query);
    // TODO: Implement search functionality
  };

  return (
    <View style={styles.container}>
      <ScrollView style={styles.scrollContainer} showsVerticalScrollIndicator={false}>
        {/* Header */}
        <View style={styles.header}>
          <Text style={styles.headerTitle}>My Wordbank</Text>
          <View style={styles.headerRight}>
            <TouchableOpacity style={styles.notificationButton}>
              <Ionicons name="notifications-outline" size={24} color="#000" />
            </TouchableOpacity>
            <View style={styles.avatarContainer}>
              {user?.avatar ? (
                <Image source={{ uri: user.avatar }} style={styles.avatar} />
              ) : (
                <View style={styles.avatarPlaceholder}>
                  <Ionicons name="person" size={20} color="#fff" />
                </View>
              )}
            </View>
          </View>
        </View>

        {/* Search Bar */}
        <View style={styles.searchContainer}>
          <View style={styles.searchBar}>
            <Ionicons name="search" size={20} color="#666" style={styles.searchIcon} />
            <TextInput
              style={styles.searchInput}
              placeholder="Search Larry's words..."
              placeholderTextColor="#666"
              value={searchQuery}
              onChangeText={handleSearch}
            />
          </View>
        </View>

        {/* Filter Tabs */}
        <ScrollView 
          horizontal 
          showsHorizontalScrollIndicator={false}
          style={styles.filterContainer}
          contentContainerStyle={styles.filterContent}
        >
          {filterOptions.map((filter) => (
            <TouchableOpacity
              key={filter}
              style={[
                styles.filterButton,
                activeFilter === filter && styles.activeFilterButton
              ]}
              onPress={() => setActiveFilter(filter)}
            >
              <Text style={[
                styles.filterText,
                activeFilter === filter && styles.activeFilterText
              ]}>
                {filter}
              </Text>
            </TouchableOpacity>
          ))}
        </ScrollView>

        {/* Premium Upgrade Card */}
        <View style={styles.premiumCard}>
          <Text style={styles.premiumTitle}>Unlock Larry's Full Potential!</Text>
          <Text style={styles.premiumDescription}>
            Upgrade to premium for unlimited word categories, advanced analytics, and exclusive learning tools from Larry's vast knowledge.
          </Text>
          
          <View style={styles.progressContainer}>
            <Text style={styles.progressText}>65% Complete</Text>
            <View style={styles.progressBar}>
              <View style={[styles.progressFill, { width: '65%' }]} />
            </View>
          </View>
          
          <TouchableOpacity style={styles.premiumButton} onPress={handleGoPremium}>
            <Text style={styles.premiumButtonText}>Go Premium</Text>
          </TouchableOpacity>
        </View>

        {/* Larry's Interests Section */}
        <View style={styles.interestsSection}>
          <Text style={styles.sectionTitle}>Larry's Interests</Text>
          
          <View style={styles.interestsGrid}>
            {loading ? (
              <ActivityIndicator size="large" color="#0000ff" />
            ) : error ? (
              <Text style={styles.errorText}>{error}</Text>
            ) : (
              userInterests.map((interest) => (
                <TouchableOpacity
                  key={interest.id}
                  style={styles.interestCard}
                  onPress={() => handleInterestPress(interest)}
                >
                  <Image source={{ uri: interest.image }} style={styles.interestImage} />
                  <View style={styles.interestOverlay}>
                    <Text style={styles.interestName}>{interest.name}</Text>
                    <Ionicons name="chevron-forward" size={16} color="#fff" />
                  </View>
                </TouchableOpacity>
              ))
            )}
          </View>
        </View>
      </ScrollView>

      {/* Shared Bottom Navigation */}
      <BottomNavigation 
        currentScreen="wordbank" 
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
  scrollContainer: {
    flex: 1,
  },
  header: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    paddingHorizontal: 20,
    paddingTop: 50,
    paddingBottom: 16,
    backgroundColor: '#fff',
  },
  headerTitle: {
    fontSize: 24,
    fontWeight: 'bold',
    color: '#000',
  },
  headerRight: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  notificationButton: {
    marginRight: 12,
  },
  avatarContainer: {
    width: 32,
    height: 32,
    borderRadius: 16,
    overflow: 'hidden',
  },
  avatar: {
    width: '100%',
    height: '100%',
  },
  avatarPlaceholder: {
    width: '100%',
    height: '100%',
    backgroundColor: '#007AFF',
    justifyContent: 'center',
    alignItems: 'center',
  },
  searchContainer: {
    paddingHorizontal: 20,
    marginBottom: 16,
  },
  searchBar: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: '#F5F5F5',
    borderRadius: 12,
    paddingHorizontal: 16,
    paddingVertical: 12,
  },
  searchIcon: {
    marginRight: 12,
  },
  searchInput: {
    flex: 1,
    fontSize: 16,
    color: '#000',
  },
  filterContainer: {
    marginBottom: 20,
  },
  filterContent: {
    paddingHorizontal: 20,
  },
  filterButton: {
    paddingHorizontal: 20,
    paddingVertical: 8,
    marginRight: 12,
    borderRadius: 20,
    backgroundColor: '#F5F5F5',
  },
  activeFilterButton: {
    backgroundColor: '#4CAF50',
  },
  filterText: {
    fontSize: 14,
    color: '#666',
    fontWeight: '500',
  },
  activeFilterText: {
    color: '#fff',
  },
  premiumCard: {
    backgroundColor: '#FFF3CD',
    marginHorizontal: 20,
    marginBottom: 24,
    padding: 20,
    borderRadius: 16,
    borderLeftWidth: 4,
    borderLeftColor: '#FF9800',
  },
  premiumTitle: {
    fontSize: 18,
    fontWeight: 'bold',
    color: '#000',
    marginBottom: 8,
  },
  premiumDescription: {
    fontSize: 14,
    color: '#666',
    lineHeight: 20,
    marginBottom: 16,
  },
  progressContainer: {
    marginBottom: 16,
  },
  progressText: {
    fontSize: 14,
    color: '#666',
    marginBottom: 8,
  },
  progressBar: {
    height: 6,
    backgroundColor: '#E0E0E0',
    borderRadius: 3,
    overflow: 'hidden',
  },
  progressFill: {
    height: '100%',
    backgroundColor: '#FF9800',
    borderRadius: 3,
  },
  premiumButton: {
    backgroundColor: '#FF9800',
    paddingVertical: 12,
    paddingHorizontal: 24,
    borderRadius: 8,
    alignItems: 'center',
  },
  premiumButtonText: {
    color: '#fff',
    fontSize: 16,
    fontWeight: '600',
  },
  interestsSection: {
    marginBottom: 24,
  },
  sectionTitle: {
    fontSize: 20,
    fontWeight: 'bold',
    color: '#000',
    marginHorizontal: 20,
    marginBottom: 16,
  },
  interestsGrid: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    paddingHorizontal: 20,
    justifyContent: 'space-between',
  },
  interestCard: {
    width: (width - 60) / 2,
    height: 120,
    marginBottom: 12,
    borderRadius: 12,
    overflow: 'hidden',
    position: 'relative',
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
    backgroundColor: 'rgba(0,0,0,0.6)',
    padding: 12,
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
  },
  interestName: {
    color: '#fff',
    fontSize: 14,
    fontWeight: '600',
  },
  errorText: {
    color: '#FF0000',
    textAlign: 'center',
    marginTop: 20,
    fontSize: 16,
  },
});
