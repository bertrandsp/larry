import React, { useState } from 'react';
import {
  View,
  Text,
  StyleSheet,
  TextInput,
  TouchableOpacity,
  ScrollView,
  Dimensions,
  StatusBar,
} from 'react-native';
import { Ionicons } from '@expo/vector-icons';

const { width } = Dimensions.get('window');

export function OnboardingScreen({ navigation, onComplete }) {
  const [customInterest, setCustomInterest] = useState('');
  const [selectedInterests, setSelectedInterests] = useState([]);
  const [preferredTime, setPreferredTime] = useState('9:00 AM');
  const [frequency, setFrequency] = useState('Daily');

  const availableInterests = [
    'Business', 'Arts', 'Science', 'Technology', 'Social',
    'Product Management', 'React Native', 'Roller Skating', 'Running', 'Nintendo'
  ];

  const frequencyOptions = ['Daily', 'Every other day', 'Weekly'];

  const handleInterestToggle = (interest) => {
    if (selectedInterests.includes(interest)) {
      setSelectedInterests(selectedInterests.filter(i => i !== interest));
    } else {
      setSelectedInterests([...selectedInterests, interest]);
    }
  };

  const handleAddCustomInterest = () => {
    if (customInterest.trim() && !selectedInterests.includes(customInterest.trim())) {
      setSelectedInterests([...selectedInterests, customInterest.trim()]);
      setCustomInterest('');
    }
  };

  const handleRemoveInterest = (interest) => {
    setSelectedInterests(selectedInterests.filter(i => i !== interest));
  };

  const handleContinue = () => {
    // TODO: Save onboarding data and complete onboarding
    console.log('Onboarding completed:', {
      selectedInterests,
      preferredTime,
      frequency
    });
    
    if (onComplete) {
      onComplete({
        selectedInterests,
        preferredTime,
        frequency
      });
    }
  };

  return (
    <View style={styles.container}>
      <StatusBar barStyle="dark-content" backgroundColor="#fff" />
      
      <ScrollView style={styles.scrollContainer} showsVerticalScrollIndicator={false}>
        {/* Header */}
        <View style={styles.header}>
          <View style={styles.logoContainer}>
            <Text style={styles.logoIcon}>★</Text>
            <Text style={styles.logoText}>logo</Text>
            <Text style={styles.logoName}>Larry</Text>
          </View>
          <Text style={styles.welcomeTitle}>Welcome to Larry!</Text>
          <Text style={styles.welcomeSubtitle}>
            Let's get you set up to expand your vocabulary.
          </Text>
        </View>

        {/* Larry's Interests Section */}
        <View style={styles.section}>
          <Text style={styles.sectionTitle}>Larry's Interests</Text>
          <Text style={styles.sectionDescription}>
            What is Larry passionate about - they love to share vocabulary and facts to help you learn.
          </Text>
          
          <View style={styles.customInterestContainer}>
            <TextInput
              style={styles.customInterestInput}
              placeholder="Add custom interest"
              value={customInterest}
              onChangeText={setCustomInterest}
            />
            <TouchableOpacity
              style={styles.addButton}
              onPress={handleAddCustomInterest}
            >
              <Ionicons name="add" size={20} color="#fff" />
            </TouchableOpacity>
          </View>

          <View style={styles.interestsGrid}>
            {availableInterests.map((interest) => (
              <TouchableOpacity
                key={interest}
                style={[
                  styles.interestTag,
                  selectedInterests.includes(interest) && styles.selectedInterestTag
                ]}
                onPress={() => handleInterestToggle(interest)}
              >
                <Text style={[
                  styles.interestTagText,
                  selectedInterests.includes(interest) && styles.selectedInterestTagText
                ]}>
                  {interest}
                </Text>
                {selectedInterests.includes(interest) && (
                  <TouchableOpacity
                    style={styles.removeButton}
                    onPress={() => handleRemoveInterest(interest)}
                  >
                    <Ionicons name="remove" size={12} color="#fff" />
                  </TouchableOpacity>
                )}
              </TouchableOpacity>
            ))}
          </View>
        </View>

        {/* Daily Bites Section */}
        <View style={styles.section}>
          <Text style={styles.sectionTitle}>Daily Bites</Text>
          <Text style={styles.sectionDescription}>
            When and how often would you like to hear from Larry?
          </Text>

          {/* Preferred Time */}
          <Text style={styles.label}>Preferred Time</Text>
          <TouchableOpacity style={styles.timeButton}>
            <Text style={styles.timeButtonText}>{preferredTime}</Text>
          </TouchableOpacity>

          {/* Frequency */}
          <Text style={styles.label}>Frequency</Text>
          <View style={styles.frequencyContainer}>
            {frequencyOptions.map((option) => (
              <TouchableOpacity
                key={option}
                style={[
                  styles.frequencyButton,
                  frequency === option && styles.selectedFrequencyButton
                ]}
                onPress={() => setFrequency(option)}
              >
                <Text style={[
                  styles.frequencyButtonText,
                  frequency === option && styles.selectedFrequencyButtonText
                ]}>
                  {option}
                </Text>
              </TouchableOpacity>
            ))}
          </View>
        </View>
      </ScrollView>

      {/* Continue Button */}
      <View style={styles.bottomContainer}>
        <TouchableOpacity
          style={styles.continueButton}
          onPress={handleContinue}
        >
          <Text style={styles.continueButtonText}>Continue</Text>
        </TouchableOpacity>
      </View>
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
    paddingHorizontal: 20,
    paddingTop: 60,
    paddingBottom: 30,
  },
  logoContainer: {
    flexDirection: 'row',
    alignItems: 'center',
    marginBottom: 20,
  },
  logoIcon: {
    fontSize: 24,
    color: '#007AFF',
    marginRight: 8,
  },
  logoText: {
    fontSize: 16,
    fontStyle: 'italic',
    color: '#666',
    marginRight: 4,
  },
  logoName: {
    fontSize: 20,
    fontWeight: 'bold',
    color: '#000',
  },
  welcomeTitle: {
    fontSize: 28,
    fontWeight: 'bold',
    color: '#000',
    marginBottom: 8,
  },
  welcomeSubtitle: {
    fontSize: 16,
    color: '#666',
    lineHeight: 22,
  },
  section: {
    paddingHorizontal: 20,
    marginBottom: 30,
  },
  sectionTitle: {
    fontSize: 20,
    fontWeight: 'bold',
    color: '#000',
    marginBottom: 8,
  },
  sectionDescription: {
    fontSize: 14,
    color: '#666',
    lineHeight: 20,
    marginBottom: 16,
  },
  customInterestContainer: {
    flexDirection: 'row',
    alignItems: 'center',
    marginBottom: 16,
  },
  customInterestInput: {
    flex: 1,
    backgroundColor: '#F5F5F5',
    borderRadius: 12,
    paddingHorizontal: 16,
    paddingVertical: 14,
    fontSize: 16,
    marginRight: 12,
    borderWidth: 1,
    borderColor: '#E0E0E0',
  },
  addButton: {
    backgroundColor: '#007AFF',
    borderRadius: 20,
    width: 40,
    height: 40,
    justifyContent: 'center',
    alignItems: 'center',
  },
  interestsGrid: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    gap: 8,
  },
  interestTag: {
    backgroundColor: '#F5F5F5',
    borderRadius: 20,
    paddingHorizontal: 16,
    paddingVertical: 8,
    flexDirection: 'row',
    alignItems: 'center',
    borderWidth: 1,
    borderColor: '#E0E0E0',
  },
  selectedInterestTag: {
    backgroundColor: '#007AFF',
    borderColor: '#007AFF',
  },
  interestTagText: {
    fontSize: 14,
    color: '#000',
    marginRight: 4,
  },
  selectedInterestTagText: {
    color: '#fff',
  },
  removeButton: {
    backgroundColor: 'rgba(255,255,255,0.3)',
    borderRadius: 10,
    width: 20,
    height: 20,
    justifyContent: 'center',
    alignItems: 'center',
  },
  label: {
    fontSize: 16,
    fontWeight: '600',
    color: '#000',
    marginBottom: 8,
  },
  timeButton: {
    backgroundColor: '#007AFF',
    borderRadius: 12,
    paddingHorizontal: 20,
    paddingVertical: 14,
    marginBottom: 20,
    alignItems: 'center',
  },
  timeButtonText: {
    fontSize: 16,
    color: '#fff',
    fontWeight: '600',
  },
  frequencyContainer: {
    gap: 12,
  },
  frequencyButton: {
    backgroundColor: '#F5F5F5',
    borderRadius: 12,
    paddingHorizontal: 20,
    paddingVertical: 14,
    alignItems: 'center',
    borderWidth: 1,
    borderColor: '#E0E0E0',
  },
  selectedFrequencyButton: {
    backgroundColor: '#007AFF',
    borderColor: '#007AFF',
  },
  frequencyButtonText: {
    fontSize: 16,
    color: '#000',
    fontWeight: '500',
  },
  selectedFrequencyButtonText: {
    color: '#fff',
  },
  bottomContainer: {
    paddingHorizontal: 20,
    paddingVertical: 20,
    borderTopWidth: 1,
    borderTopColor: '#F0F0F0',
    backgroundColor: '#fff',
  },
  continueButton: {
    backgroundColor: '#007AFF',
    borderRadius: 12,
    paddingVertical: 16,
    alignItems: 'center',
  },
  continueButtonText: {
    fontSize: 18,
    color: '#fff',
    fontWeight: '600',
  },
});
