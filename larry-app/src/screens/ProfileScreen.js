import React, { useState } from 'react';
import {
  View,
  Text,
  StyleSheet,
  ScrollView,
  TouchableOpacity,
  Alert,
  Image,
  Dimensions,
} from 'react-native';
import { Ionicons } from '@expo/vector-icons';
import { BottomNavigation } from '../components/BottomNavigation';
import { useAuth } from '../hooks/useAuth';

const { width } = Dimensions.get('window');

export function ProfileScreen({ navigation, onSignOut }) {
  const { user } = useAuth();
  const [loading, setLoading] = useState(false);

  // Mock data
  const streakData = {
    currentStreak: 5,
    daysCompleted: ['Mo', 'Tu', 'We', 'Th', 'Fr'], // Monday to Friday completed
    daysOfWeek: ['Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa', 'Su']
  };

  // Handle navigation
  const handleNavigation = (screen) => {
    if (screen === 'home') {
      navigation.navigate('home');
    } else if (screen === 'wordbank') {
      navigation.navigate('wordbank');
    }
    // Add other navigation handlers as needed
  };

  const handleGoPremium = () => {
    Alert.alert('Go Premium', 'Premium features coming soon!');
  };

  const handleGetAppBundle = () => {
    Alert.alert('App Bundle', 'App bundle features coming soon!');
  };

  const handleSignOut = () => {
    Alert.alert(
      'Sign Out',
      'Are you sure you want to sign out?',
      [
        { text: 'Cancel', style: 'cancel' },
        { 
          text: 'Sign Out', 
          style: 'destructive',
          onPress: async () => {
            console.log('🚪 ProfileScreen - Starting sign out process...');
            setLoading(true);
            try {
              await onSignOut();
              console.log('🚪 ProfileScreen - Sign out completed successfully');
              // The App.js will automatically show LoginScreen
              // since isAuthenticated is now false
            } catch (error) {
              console.error('🚪 ProfileScreen - Sign out error:', error);
              Alert.alert('Error', 'Failed to sign out. Please try again.');
            } finally {
              setLoading(false);
              console.log('🚪 ProfileScreen - Sign out process finished');
            }
          }
        }
      ]
    );
  };

  return (
    <View style={styles.container}>
      <ScrollView style={styles.scrollContainer} showsVerticalScrollIndicator={false}>
        {/* Header */}
        <View style={styles.header}>
          <Text style={styles.headerTitle}>Your Profile</Text>
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

        {/* Go Premium Card */}
        <View style={styles.premiumCard}>
          <View style={styles.premiumContent}>
            <View style={styles.premiumText}>
              <Text style={styles.premiumTitle}>Go Premium, Buddy!</Text>
              <Text style={styles.premiumDescription}>
                Unlock all categories, words, and themes for an ad-free journey with Larry!
              </Text>
            </View>
            <View style={styles.premiumIcon}>
              <Text style={styles.cloudEmoji}>☁️</Text>
              <Text style={styles.keyEmoji}>🔑</Text>
            </View>
          </View>
        </View>

        {/* Your Vocabulary Journey Section */}
        <View style={styles.section}>
          <Text style={styles.sectionTitle}>Your Vocabulary Journey</Text>
          
          {/* Shared Streak Card */}
          <View style={styles.streakCard}>
            <View style={styles.streakHeader}>
              <View style={styles.streakTitle}>
                <Ionicons name="book-outline" size={16} color="#007AFF" />
                <Text style={styles.streakTitleText}>Our Shared Streak</Text>
              </View>
              <View style={styles.celebrateSection}>
                <Text style={styles.celebrateText}>Celebrate!</Text>
                <Ionicons name="flash" size={16} color="#FFD700" />
              </View>
            </View>
            
            <View style={styles.streakContent}>
              <View style={styles.streakNumber}>
                <Text style={styles.streakCount}>{streakData.currentStreak}</Text>
                <Text style={styles.streakLabel}>Our current vocabulary streak</Text>
                <Text style={styles.streakSubLabel}>Days in a row with Larry!</Text>
              </View>
              
              <View style={styles.streakIcon}>
                <Text style={styles.cloudEmoji}>☁️</Text>
                <Text style={styles.flagEmoji}>🏁</Text>
              </View>
            </View>
            
            {/* Days of Week */}
            <View style={styles.daysContainer}>
              {streakData.daysOfWeek.map((day, index) => (
                <View key={day} style={styles.dayCircle}>
                  <Text style={styles.dayText}>{day}</Text>
                  {streakData.daysCompleted.includes(day) && (
                    <Ionicons name="checkmark" size={12} color="#4CAF50" style={styles.checkmark} />
                  )}
                </View>
              ))}
            </View>
          </View>

          {/* Discovery and History Grid */}
          <View style={styles.discoveryGrid}>
            <TouchableOpacity style={styles.discoveryCard}>
              <Text style={styles.discoveryTitle}>Joint Discoveries</Text>
              <Text style={styles.discoveryDescription}>Revisit words we loved together.</Text>
            </TouchableOpacity>
            
            <TouchableOpacity style={styles.discoveryCard}>
              <Text style={styles.discoveryTitle}>Our Own Words</Text>
              <Text style={styles.discoveryDescription}>Explore the words we've added</Text>
            </TouchableOpacity>
            
            <TouchableOpacity style={styles.discoveryCard}>
              <Text style={styles.discoveryTitle}>Shared Collections</Text>
              <Text style={styles.discoveryDescription}>Organized words for our mutual</Text>
            </TouchableOpacity>
            
            <TouchableOpacity style={styles.discoveryCard}>
              <Text style={styles.discoveryTitle}>Journey History</Text>
              <Text style={styles.discoveryDescription}>A look back at our progress together.</Text>
            </TouchableOpacity>
          </View>
        </View>

        {/* Customize Your Buddy's App Section */}
        <View style={styles.section}>
          <Text style={styles.sectionTitle}>Customize Your Buddy's App</Text>
          
          <View style={styles.customizationGrid}>
            <TouchableOpacity style={styles.customizationCard}>
              <View style={styles.customizationIcon}>
                <Ionicons name="phone-portrait" size={24} color="#007AFF" />
              </View>
              <Text style={styles.customizationTitle}>Larry's Widgets</Text>
              <Text style={styles.customizationDescription}>Customize your home screen</Text>
            </TouchableOpacity>
            
            <TouchableOpacity style={styles.customizationCard}>
              <View style={styles.customizationIcon}>
                <Ionicons name="alarm" size={24} color="#FF6B9D" />
              </View>
              <Text style={styles.customizationTitle}>Reminder Rhythms</Text>
              <Text style={styles.customizationDescription}>Set your learning schedule</Text>
            </TouchableOpacity>
            
            <TouchableOpacity style={styles.customizationCard}>
              <View style={styles.customizationIcon}>
                <Ionicons name="color-palette" size={24} color="#4ECDC4" />
              </View>
              <Text style={styles.customizationTitle}>Theme Harmony</Text>
              <Text style={styles.customizationDescription}>Choose your visual style</Text>
            </TouchableOpacity>
            
            <TouchableOpacity style={styles.customizationCard}>
              <View style={styles.customizationIcon}>
                <Ionicons name="mic" size={24} color="#FF6B9D" />
              </View>
              <Text style={styles.customizationTitle}>Voice Vibes</Text>
              <Text style={styles.customizationDescription}>Personalize audio settings</Text>
            </TouchableOpacity>
            
            <TouchableOpacity style={styles.customizationCard}>
              <View style={styles.customizationIcon}>
                <Ionicons name="apps" size={24} color="#007AFF" />
              </View>
              <Text style={styles.customizationTitle}>Buddy Icon</Text>
              <Text style={styles.customizationDescription}>Customize app appearance</Text>
            </TouchableOpacity>
            
            <TouchableOpacity style={styles.customizationCard}>
              <View style={styles.customizationIcon}>
                <Ionicons name="watch" size={24} color="#4ECDC4" />
              </View>
              <Text style={styles.customizationTitle}>Wrist Companion</Text>
              <Text style={styles.customizationDescription}>Connect with smartwatch</Text>
            </TouchableOpacity>
          </View>
        </View>

        {/* Get the App Bundle Card */}
        <View style={styles.bundleCard}>
          <View style={styles.bundleContent}>
            <View style={styles.bundleText}>
              <Text style={styles.bundleTitle}>Get the App Bundle with Larry!</Text>
              <Text style={styles.bundleDescription}>
                The complete mental well-being and growth toolkit. Expand our horizons together.
              </Text>
            </View>
            <View style={styles.bundleIcon}>
              <Text style={styles.cloudEmoji}>☁️</Text>
              <View style={styles.bundleIcons}>
                <Text style={styles.bundleIconEmoji}>❤️</Text>
                <Text style={styles.bundleIconEmoji}>⭐</Text>
                <Text style={styles.bundleIconEmoji}>🌸</Text>
              </View>
            </View>
          </View>
        </View>

        {/* Sign Out Button */}
        <TouchableOpacity 
          style={styles.signOutButton} 
          onPress={handleSignOut}
          disabled={loading}
        >
          <Ionicons name="log-out-outline" size={20} color="#FF3B30" />
          <Text style={styles.signOutText}>
            {loading ? 'Signing out...' : 'Sign Out'}
          </Text>
        </TouchableOpacity>

        {/* App Version */}
        <View style={styles.versionSection}>
          <Text style={styles.versionText}>Larry v1.0.0</Text>
        </View>
      </ScrollView>

      {/* Shared Bottom Navigation */}
      <BottomNavigation 
        currentScreen="profile" 
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
  premiumCard: {
    backgroundColor: '#E3F2FD',
    marginHorizontal: 20,
    marginBottom: 24,
    borderRadius: 16,
    padding: 20,
  },
  premiumContent: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
  },
  premiumText: {
    flex: 1,
    marginRight: 16,
  },
  premiumTitle: {
    fontSize: 20,
    fontWeight: 'bold',
    color: '#000',
    marginBottom: 8,
  },
  premiumDescription: {
    fontSize: 14,
    color: '#666',
    lineHeight: 20,
  },
  premiumIcon: {
    alignItems: 'center',
  },
  cloudEmoji: {
    fontSize: 32,
  },
  keyEmoji: {
    fontSize: 20,
    position: 'absolute',
    top: 8,
    right: -8,
  },
  section: {
    marginBottom: 24,
  },
  sectionTitle: {
    fontSize: 20,
    fontWeight: 'bold',
    color: '#000',
    marginHorizontal: 20,
    marginBottom: 16,
  },
  streakCard: {
    backgroundColor: '#E3F2FD',
    marginHorizontal: 20,
    marginBottom: 20,
    borderRadius: 16,
    padding: 20,
  },
  streakHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: 16,
  },
  streakTitle: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  streakTitleText: {
    fontSize: 16,
    fontWeight: '600',
    color: '#000',
    marginLeft: 8,
  },
  celebrateSection: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  celebrateText: {
    fontSize: 14,
    color: '#FF6B6B',
    fontWeight: '600',
    marginRight: 4,
  },
  streakContent: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: 16,
  },
  streakNumber: {
    flex: 1,
  },
  streakCount: {
    fontSize: 48,
    fontWeight: 'bold',
    color: '#000',
    marginBottom: 4,
  },
  streakLabel: {
    fontSize: 14,
    color: '#666',
    marginBottom: 2,
  },
  streakSubLabel: {
    fontSize: 14,
    color: '#666',
  },
  streakIcon: {
    alignItems: 'center',
  },
  flagEmoji: {
    fontSize: 16,
    position: 'absolute',
    top: 8,
    right: -8,
  },
  daysContainer: {
    flexDirection: 'row',
    justifyContent: 'space-between',
  },
  dayCircle: {
    width: 32,
    height: 32,
    borderRadius: 16,
    backgroundColor: '#fff',
    justifyContent: 'center',
    alignItems: 'center',
    borderWidth: 1,
    borderColor: '#E0E0E0',
  },
  dayText: {
    fontSize: 10,
    fontWeight: '600',
    color: '#666',
  },
  checkmark: {
    position: 'absolute',
    bottom: -2,
    right: -2,
  },
  discoveryGrid: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    marginHorizontal: 20,
    justifyContent: 'space-between',
  },
  discoveryCard: {
    width: (width - 60) / 2,
    backgroundColor: '#fff',
    borderRadius: 12,
    padding: 16,
    marginBottom: 12,
    borderWidth: 1,
    borderColor: '#E0E0E0',
  },
  discoveryTitle: {
    fontSize: 16,
    fontWeight: '600',
    color: '#000',
    marginBottom: 8,
  },
  discoveryDescription: {
    fontSize: 12,
    color: '#666',
    lineHeight: 16,
  },
  customizationGrid: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    marginHorizontal: 20,
    justifyContent: 'space-between',
  },
  customizationCard: {
    width: (width - 60) / 2,
    backgroundColor: '#fff',
    borderRadius: 12,
    padding: 16,
    marginBottom: 12,
    borderWidth: 1,
    borderColor: '#E0E0E0',
    alignItems: 'center',
  },
  customizationIcon: {
    width: 48,
    height: 48,
    borderRadius: 24,
    backgroundColor: '#F5F5F5',
    justifyContent: 'center',
    alignItems: 'center',
    marginBottom: 12,
  },
  customizationTitle: {
    fontSize: 14,
    fontWeight: '600',
    color: '#000',
    marginBottom: 4,
    textAlign: 'center',
  },
  customizationDescription: {
    fontSize: 11,
    color: '#666',
    textAlign: 'center',
    lineHeight: 14,
  },
  bundleCard: {
    backgroundColor: '#E3F2FD',
    marginHorizontal: 20,
    marginBottom: 24,
    borderRadius: 16,
    padding: 20,
  },
  bundleContent: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
  },
  bundleText: {
    flex: 1,
    marginRight: 16,
  },
  bundleTitle: {
    fontSize: 18,
    fontWeight: 'bold',
    color: '#000',
    marginBottom: 8,
  },
  bundleDescription: {
    fontSize: 14,
    color: '#666',
    lineHeight: 20,
  },
  bundleIcon: {
    alignItems: 'center',
  },
  bundleIcons: {
    flexDirection: 'row',
    marginTop: 4,
  },
  bundleIconEmoji: {
    fontSize: 16,
    marginHorizontal: 2,
  },
  signOutButton: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
    marginHorizontal: 20,
    marginBottom: 20,
    paddingVertical: 12,
    borderWidth: 1,
    borderColor: '#FF3B30',
    borderRadius: 8,
  },
  signOutText: {
    fontSize: 16,
    color: '#FF3B30',
    marginLeft: 8,
    fontWeight: '500',
  },
  versionSection: {
    alignItems: 'center',
    paddingVertical: 20,
  },
  versionText: {
    fontSize: 14,
    color: '#999',
  },
});
