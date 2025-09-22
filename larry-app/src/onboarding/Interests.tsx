import React, { useState, useEffect } from 'react';
import {
  View,
  Text,
  StyleSheet,
  ScrollView,
  TouchableOpacity,
  TextInput,
  Alert,
  ActivityIndicator,
  Dimensions,
  Platform,
  Modal,
  Animated,
} from 'react-native';
import { Ionicons } from '@expo/vector-icons';
import * as Notifications from 'expo-notifications';
import { useAuth } from '../hooks/useAuth';
import { getAvailableInterests, saveUserInterests, saveUserNotifications } from '../services/api';

const { width } = Dimensions.get('window');

// Configure notifications
Notifications.setNotificationHandler({
  handleNotification: async () => ({
    shouldShowAlert: true,
    shouldPlaySound: true,
    shouldSetBadge: false,
  }),
});

interface Interest {
  id: string;
  slug: string;
  name: string;
  locale: string;
}

interface NotificationSchedule {
  localTz: string;
  localHHmm: string;
  frequency: 'daily' | 'every_other' | 'weekly' | 'twice_daily' | 'thrice_daily';
  pushToken?: string;
}

interface TimePickerWheelProps {
  currentTime: string;
  onTimeChange: (hours: number, minutes: number) => void;
}

interface FrequencyPickerWheelProps {
  currentFrequency: string;
  onFrequencyChange: (frequency: string) => void;
}



// Animated interest chip component
const AnimatedInterestChip: React.FC<{
  interest: Interest;
  isSelected: boolean;
  onToggle: () => void;
  delay?: number;
}> = ({ interest, isSelected, onToggle, delay = 0 }) => {
  const scaleAnim = React.useRef(new Animated.Value(0)).current;
  const opacityAnim = React.useRef(new Animated.Value(0)).current;

  useEffect(() => {
    Animated.sequence([
      Animated.delay(delay),
      Animated.parallel([
        Animated.spring(scaleAnim, {
          toValue: 1,
          useNativeDriver: true,
          tension: 100,
          friction: 8,
        }),
        Animated.timing(opacityAnim, {
          toValue: 1,
          duration: 300,
          useNativeDriver: true,
        }),
      ]),
    ]).start();
  }, []);

  const handlePress = () => {
    Animated.sequence([
      Animated.timing(scaleAnim, {
        toValue: 0.95,
        duration: 100,
        useNativeDriver: true,
      }),
      Animated.spring(scaleAnim, {
        toValue: 1,
        useNativeDriver: true,
        tension: 100,
        friction: 8,
      }),
    ]).start();
    onToggle();
  };

  return (
    <Animated.View
      style={[
        styles.interestChipContainer,
        {
          transform: [{ scale: scaleAnim }],
          opacity: opacityAnim,
        },
      ]}
    >
      <TouchableOpacity
        style={[
          styles.interestChip,
          isSelected && styles.selectedChip,
        ]}
        onPress={handlePress}
        activeOpacity={0.7}
      >
        <Text style={[
          styles.interestText,
          isSelected && styles.selectedInterestText,
        ]}>
          {interest.name}
        </Text>
        {isSelected && (
          <Animated.View style={styles.checkIconContainer}>
            <Ionicons name="checkmark" size={16} color="#fff" />
          </Animated.View>
        )}
      </TouchableOpacity>
    </Animated.View>
  );
};

// Animated custom interest chip
const AnimatedCustomInterestChip: React.FC<{
  interest: string;
  isSelected: boolean;
  onToggle: () => void;
  onRemove: () => void;
  delay?: number;
}> = ({ interest, isSelected, onToggle, onRemove, delay = 0 }) => {
  const scaleAnim = React.useRef(new Animated.Value(0)).current;
  const opacityAnim = React.useRef(new Animated.Value(0)).current;

  useEffect(() => {
    Animated.sequence([
      Animated.delay(delay),
      Animated.parallel([
        Animated.spring(scaleAnim, {
          toValue: 1,
          useNativeDriver: true,
          tension: 100,
          friction: 8,
        }),
        Animated.timing(opacityAnim, {
          toValue: 1,
          duration: 300,
          useNativeDriver: true,
        }),
      ]),
    ]).start();
  }, []);

  const handlePress = () => {
    Animated.sequence([
      Animated.timing(scaleAnim, {
        toValue: 0.95,
        duration: 100,
        useNativeDriver: true,
      }),
      Animated.spring(scaleAnim, {
        toValue: 1,
        useNativeDriver: true,
        tension: 100,
        friction: 8,
      }),
    ]).start();
    onToggle();
  };

  return (
    <Animated.View
      style={[
        styles.interestChipContainer,
        {
          transform: [{ scale: scaleAnim }],
          opacity: opacityAnim,
        },
      ]}
    >
      <TouchableOpacity
        style={[
          styles.interestChip,
          isSelected && styles.selectedChip,
        ]}
        onPress={handlePress}
        activeOpacity={0.7}
      >
        <Text style={[
          styles.interestText,
          isSelected && styles.selectedInterestText,
        ]}>
          {interest}
        </Text>
        {isSelected && (
          <Animated.View style={styles.checkIconContainer}>
            <Ionicons name="checkmark" size={16} color="#fff" />
          </Animated.View>
        )}
      </TouchableOpacity>
    </Animated.View>
  );
};

const convertTo24Hour = (hour12: number, isPM: boolean): number => {
  if (hour12 === 12) {
    return isPM ? 12 : 0;
  }
  return isPM ? hour12 + 12 : hour12;
};

const convertFrom24Hour = (hour24: number): { hour12: number; isPM: boolean } => {
  if (hour24 === 0) return { hour12: 12, isPM: false };
  if (hour24 === 12) return { hour12: 12, isPM: true };
  if (hour24 > 12) return { hour12: hour24 - 12, isPM: true };
  return { hour12: hour24, isPM: false };
};

const TimePickerWheel: React.FC<TimePickerWheelProps> = ({ currentTime, onTimeChange }) => {
  const initialHours = parseInt(currentTime.split(':')[0]);
  const initialMinutes = parseInt(currentTime.split(':')[1]);
  const { hour12: initialHour12, isPM: initialIsPM } = convertFrom24Hour(initialHours);
  
  const [hour12, setHour12] = useState(initialHour12);
  const [minutes, setMinutes] = useState(initialMinutes);
  const [isPM, setIsPM] = useState(initialIsPM);
  
  // Refs for scrolling to the correct position
  const hourScrollRef = React.useRef<ScrollView>(null);
  const minuteScrollRef = React.useRef<ScrollView>(null);

  useEffect(() => {
    const hours24 = convertTo24Hour(hour12, isPM);
    onTimeChange(hours24, minutes);
  }, [hour12, minutes, isPM, onTimeChange]);

  // Scroll to the correct position when component mounts
  useEffect(() => {
    const scrollToPosition = () => {
      // Scroll hour wheel to show the selected hour
      if (hourScrollRef.current) {
        const hourIndex = hour12 - 1; // Convert to 0-based index
        hourScrollRef.current.scrollTo({ y: hourIndex * 40, animated: false });
      }
      
      // Scroll minute wheel to show the selected minute
      if (minuteScrollRef.current) {
        minuteScrollRef.current.scrollTo({ y: minutes * 40, animated: false });
      }
    };
    
    // Small delay to ensure the ScrollView is rendered
    setTimeout(scrollToPosition, 100);
  }, [hour12, minutes]);

  const hourOptions = Array.from({ length: 12 }, (_, i) => i + 1); // 1-12
  const minuteOptions = Array.from({ length: 60 }, (_, i) => i);

  return (
    <View style={styles.timePickerWheel}>
      <View style={styles.wheelColumn}>
        <Text style={styles.wheelLabel}>Hour</Text>
        <ScrollView 
          ref={hourScrollRef}
          style={styles.wheelScroll}
          showsVerticalScrollIndicator={false}
          snapToInterval={40}
        >
          {hourOptions.map((hour) => (
            <TouchableOpacity
              key={hour}
              style={[
                styles.wheelOption,
                hour12 === hour && styles.wheelOptionSelected,
              ]}
              onPress={() => setHour12(hour)}
            >
              <Text style={[
                styles.wheelOptionText,
                hour12 === hour && styles.wheelOptionTextSelected,
              ]}>
                {hour}
              </Text>
            </TouchableOpacity>
          ))}
        </ScrollView>
      </View>
      
      <Text style={styles.timeSeparator}>:</Text>
      
      <View style={styles.wheelColumn}>
        <Text style={styles.wheelLabel}>Minute</Text>
        <ScrollView 
          ref={minuteScrollRef}
          style={styles.wheelScroll}
          showsVerticalScrollIndicator={false}
          snapToInterval={40}
        >
          {minuteOptions.map((minute) => (
            <TouchableOpacity
              key={minute}
              style={[
                styles.wheelOption,
                minutes === minute && styles.wheelOptionSelected,
              ]}
              onPress={() => setMinutes(minute)}
            >
              <Text style={[
                styles.wheelOptionText,
                minutes === minute && styles.wheelOptionTextSelected,
              ]}>
                {minute.toString().padStart(2, '0')}
              </Text>
            </TouchableOpacity>
          ))}
        </ScrollView>
      </View>

      <View style={styles.wheelColumn}>
        <Text style={styles.wheelLabel}>AM/PM</Text>
        <ScrollView 
          style={styles.wheelScroll}
          showsVerticalScrollIndicator={false}
          snapToInterval={40}
        >
          <TouchableOpacity
            style={[
              styles.wheelOption,
              !isPM && styles.wheelOptionSelected,
            ]}
            onPress={() => setIsPM(false)}
          >
            <Text style={[
              styles.wheelOptionText,
              !isPM && styles.wheelOptionTextSelected,
            ]}>
              AM
            </Text>
          </TouchableOpacity>
          <TouchableOpacity
            style={[
              styles.wheelOption,
              isPM && styles.wheelOptionSelected,
            ]}
            onPress={() => setIsPM(true)}
          >
            <Text style={[
              styles.wheelOptionText,
              isPM && styles.wheelOptionTextSelected,
            ]}>
              PM
            </Text>
          </TouchableOpacity>
        </ScrollView>
      </View>
    </View>
  );
};

const FrequencyPickerWheel: React.FC<FrequencyPickerWheelProps> = ({ currentFrequency, onFrequencyChange }) => {
  const [selectedFrequency, setSelectedFrequency] = useState(currentFrequency);
  
  // Ref for scrolling to the correct position
  const frequencyScrollRef = React.useRef<ScrollView>(null);

  const frequencyOptions = [
    { value: 'thrice_daily', label: '3x a day' },
    { value: 'twice_daily', label: '2x a day' },
    { value: 'daily', label: 'Daily' },
    { value: 'every_other', label: 'Every other day' },
    { value: 'weekly', label: 'Weekly' },
  ];

  const handleScroll = (event: any) => {
    const y = event.nativeEvent.contentOffset.y;
    const index = Math.round(y / 50);
    if (index >= 0 && index < frequencyOptions.length) {
      const newFrequency = frequencyOptions[index].value;
      if (newFrequency !== selectedFrequency) {
        setSelectedFrequency(newFrequency);
        onFrequencyChange(newFrequency);
      }
    }
  };

  useEffect(() => {
    onFrequencyChange(selectedFrequency);
  }, [selectedFrequency, onFrequencyChange]);

  // Scroll to the correct position when component mounts
  useEffect(() => {
    const scrollToPosition = () => {
      if (frequencyScrollRef.current) {
        const frequencyIndex = frequencyOptions.findIndex(option => option.value === selectedFrequency);
        if (frequencyIndex !== -1) {
          frequencyScrollRef.current.scrollTo({ y: frequencyIndex * 50, animated: false });
        }
      }
    };
    
    // Small delay to ensure the ScrollView is rendered
    setTimeout(scrollToPosition, 100);
  }, [selectedFrequency, frequencyOptions]);

  return (
    <View style={styles.frequencyPickerWheel}>
      <View style={styles.wheelContainer}>
        {/* Selection indicator overlay */}
        <View style={styles.selectionIndicator} />
        
        <ScrollView 
          ref={frequencyScrollRef}
          style={styles.frequencyWheelScroll}
          showsVerticalScrollIndicator={false}
          snapToInterval={50}
          decelerationRate="fast"
          onScroll={handleScroll}
          scrollEventThrottle={16}
        >
          {/* Add padding at top and bottom for visual balance */}
          <View style={styles.wheelPadding} />
          
          {frequencyOptions.map((option) => (
            <View
              key={option.value}
              style={styles.frequencyWheelOption}
            >
              <Text style={[
                styles.frequencyWheelOptionText,
                selectedFrequency === option.value && styles.frequencyWheelOptionTextSelected,
              ]}>
                {option.label}
              </Text>
            </View>
          ))}
          
          {/* Add padding at bottom for visual balance */}
          <View style={styles.wheelPadding} />
        </ScrollView>
      </View>
    </View>
  );
};

export default function Interests({ user, onComplete }: { user: any, onComplete: () => void }) {
  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);
  const [availableInterests, setAvailableInterests] = useState<Interest[]>([]);
  const [selectedInterests, setSelectedInterests] = useState<string[]>([]);
  const [selectedCustomInterests, setSelectedCustomInterests] = useState<string[]>([]);
  const [customInterest, setCustomInterest] = useState('');
  const [customInterests, setCustomInterests] = useState<string[]>([]);
  const [showTimePicker, setShowTimePicker] = useState(false);
  const [tempTime, setTempTime] = useState('09:00');
  const [hasSelectedTime, setHasSelectedTime] = useState(false);
  const [hasSelectedFrequency, setHasSelectedFrequency] = useState(true);
  const [notificationSchedule, setNotificationSchedule] = useState<NotificationSchedule>({
    localTz: 'America/Los_Angeles', // Default timezone
    localHHmm: '09:00', // Default 9 AM
    frequency: 'daily', // Default to daily
  });
  
  // Animation values
  const fadeAnim = React.useRef(new Animated.Value(0)).current;
  const slideAnim = React.useRef(new Animated.Value(50)).current;
  


  // Ref for the frequency scroll view
  const frequencyScrollRef = React.useRef<ScrollView>(null);

  // Scroll to "Daily" (index 2) when component mounts
  useEffect(() => {
    const scrollToDaily = () => {
      if (frequencyScrollRef.current) {
        // "Daily" is at index 2 in the new order: ['thrice_daily', 'twice_daily', 'daily', 'every_other', 'weekly']
        frequencyScrollRef.current.scrollTo({ y: 2 * 40, animated: false });
      }
    };
    
    // Small delay to ensure the ScrollView is rendered
    setTimeout(scrollToDaily, 100);
  }, []);

  // Load available interests on component mount
  useEffect(() => {
    loadAvailableInterests();
    requestNotificationPermissions();
    
    // Start entrance animation
    Animated.parallel([
      Animated.timing(fadeAnim, {
        toValue: 1,
        duration: 800,
        useNativeDriver: true,
      }),
      Animated.timing(slideAnim, {
        toValue: 0,
        duration: 800,
        useNativeDriver: true,
      }),
    ]).start();
  }, []);

  const loadAvailableInterests = async () => {
    try {
      setLoading(true);
      const response = await getAvailableInterests();
      setAvailableInterests(response.items || []);
    } catch (error) {
      console.error('Failed to load interests:', error);
      Alert.alert('Error', 'Failed to load available interests. Please try again.');
    } finally {
      setLoading(false);
    }
  };

  const requestNotificationPermissions = async () => {
    try {
      const { status: existingStatus } = await Notifications.getPermissionsAsync();
      let finalStatus = existingStatus;
      
      if (existingStatus !== 'granted') {
        const { status } = await Notifications.requestPermissionsAsync();
        finalStatus = status;
      }
      
      if (finalStatus !== 'granted') {
        console.log('Notification permissions not granted');
        return;
      }

      // Get push token (optional - don't fail if it doesn't work)
      try {
        const token = await Notifications.getExpoPushTokenAsync({
          projectId: 'your-expo-project-id', // Replace with your actual project ID
        });
        
        setNotificationSchedule(prev => ({
          ...prev,
          pushToken: token.data,
        }));
        
        console.log('Push token:', token.data);
      } catch (error) {
        console.log('Push notifications not available (this is normal in development):', error.message);
        // Continue without push token - it's optional
      }
    } catch (error) {
      console.error('Failed to get push token:', error);
    }
  };

  const handleInterestToggle = (interestId: string) => {
    setSelectedInterests(prev => 
      prev.includes(interestId)
        ? prev.filter(id => id !== interestId)
        : [...prev, interestId]
    );
  };

  const handleAddCustomInterest = () => {
    const trimmed = customInterest.trim();
    if (trimmed && !customInterests.includes(trimmed)) {
      setCustomInterests(prev => [...prev, trimmed]);
      setSelectedCustomInterests(prev => [...prev, trimmed]); // Auto-select when added
      setCustomInterest('');
    }
  };

  const handleCustomInterestToggle = (interest: string) => {
    setSelectedCustomInterests(prev => 
      prev.includes(interest)
        ? prev.filter(i => i !== interest)
        : [...prev, interest]
    );
  };

  const handleRemoveCustomInterest = (interest: string) => {
    setCustomInterests(prev => prev.filter(i => i !== interest));
    setSelectedCustomInterests(prev => prev.filter(i => i !== interest)); // Also deselect when removed
  };

  const handleTimeChange = (time: string) => {
    setNotificationSchedule(prev => ({
      ...prev,
      localHHmm: time,
    }));
  };

  const openTimePicker = () => {
    // Default to 9:00 AM if no time has been selected yet
    const timeToShow = notificationSchedule.localHHmm === '09:00' ? '09:00' : notificationSchedule.localHHmm;
    setTempTime(timeToShow);
    setShowTimePicker(true);
  };

  const closeTimePicker = () => {
    setShowTimePicker(false);
  };

  const confirmTimePicker = () => {
    setNotificationSchedule(prev => ({
      ...prev,
      localHHmm: tempTime,
    }));
    setHasSelectedTime(true);
    setShowTimePicker(false);
  };

  const updateTempTime = (hours: number, minutes: number) => {
    const formattedHours = hours.toString().padStart(2, '0');
    const formattedMinutes = minutes.toString().padStart(2, '0');
    setTempTime(`${formattedHours}:${formattedMinutes}`);
  };

  const formatTimeForDisplay = (time24: string): string => {
    const [hours, minutes] = time24.split(':').map(Number);
    const { hour12, isPM } = convertFrom24Hour(hours);
    return `${hour12}:${minutes.toString().padStart(2, '0')} ${isPM ? 'PM' : 'AM'}`;
  };

  const getFrequencyLabel = (frequency: string): string => {
    const labels = {
      'daily': 'Daily',
      'twice_daily': '2x a day',
      'thrice_daily': '3x a day',
      'every_other': 'Every other day',
      'weekly': 'Weekly',
    };
    return labels[frequency as keyof typeof labels] || 'Daily';
  };



  const handleFrequencyChange = (frequency: 'daily' | 'every_other' | 'weekly' | 'twice_daily' | 'thrice_daily') => {
    setNotificationSchedule(prev => ({
      ...prev,
      frequency,
    }));
  };



  const getTimezone = () => {
    // Get user's timezone
    const timezone = Intl.DateTimeFormat().resolvedOptions().timeZone;
    return timezone || 'America/Los_Angeles';
  };

  const canContinue = () => {
    const hasInterests = selectedInterests.length > 0 || selectedCustomInterests.length > 0;
    const hasNotificationSettings = hasSelectedTime && hasSelectedFrequency;
    return hasInterests && hasNotificationSettings && !saving;
  };

  const handleContinue = async () => {
    if (!user?.id) {
      Alert.alert('Error', 'User not authenticated');
      return;
    }

    try {
      setSaving(true);
      
      // Add a small delay to show the loading state
      await new Promise(resolve => setTimeout(resolve, 500));

      // Use the actual logged-in user's ID
      const userId = user.id;
      console.log('Using authenticated user ID:', userId);
      
      // Validate user ID
      if (!userId) {
        Alert.alert('Authentication Error', 'User ID not found. Please sign in again.');
        return;
      }

      // Track analytics
      trackAnalytics('onboarding_interest_selected', {
        presetCount: selectedInterests.length,
        customCount: selectedCustomInterests.length,
      });

      // Save interests
      try {
        await saveUserInterests(selectedInterests, selectedCustomInterests, userId);
      } catch (error) {
        console.error('Failed to save interests:', error);
        if (error.message && error.message.includes('Network request failed')) {
          Alert.alert('Error', 'Unable to connect to server. Please check your internet connection and try again.');
        } else {
          Alert.alert('Error', 'Failed to save your interests. Please try again.');
        }
        return;
      }

      // Update timezone if not set
      const timezone = getTimezone();
      const updatedSchedule = {
        ...notificationSchedule,
        localTz: timezone,
      };

      // Track analytics
      trackAnalytics('onboarding_notification_set', {
        frequency: updatedSchedule.frequency,
        time: updatedSchedule.localHHmm,
      });

      // Save notification preferences
      try {
        await saveUserNotifications(
          updatedSchedule.localTz,
          updatedSchedule.localHHmm,
          updatedSchedule.frequency,
          updatedSchedule.pushToken,
          userId
        );
      } catch (error) {
        console.error('Failed to save notifications:', error);
        if (error.message && error.message.includes('Network request failed')) {
          Alert.alert('Error', 'Unable to connect to server. Please check your internet connection and try again.');
        } else {
          Alert.alert('Error', 'Failed to save your notification preferences. Please try again.');
        }
        return;
      }

      // Track completion
      trackAnalytics('onboarding_complete', {
        totalInterests: selectedInterests.length + selectedCustomInterests.length,
        frequency: updatedSchedule.frequency,
      });

      // Complete onboarding
      onComplete();
    } catch (error) {
      console.error('Failed to save onboarding data:', error);
      Alert.alert('Error', 'Failed to save your preferences. Please try again.');
    } finally {
      setSaving(false);
    }
  };

  const trackAnalytics = (event: string, properties: any) => {
    // TODO: Implement actual analytics tracking
    console.log('📊 Analytics:', event, properties);
  };

  if (loading) {
    return (
      <View style={styles.loadingContainer}>
        <ActivityIndicator size="large" color="#007AFF" />
        <Text style={styles.loadingText}>Loading interests...</Text>
      </View>
    );
  }

  return (
    <ScrollView style={styles.container} showsVerticalScrollIndicator={false}>
      {/* Header */}
      <Animated.View 
        style={[
          styles.header,
          {
            opacity: fadeAnim,
            transform: [{ translateY: slideAnim }],
          },
        ]}
      >
        <Text style={styles.title}>Welcome to Larry!</Text>
        <Text style={styles.subtitle}>
          Let's personalize your learning experience by selecting your interests and setting up notifications.
        </Text>
      </Animated.View>

      {/* Interest Selection */}
      <View style={styles.section}>
        <Text style={styles.sectionTitle}>What interests you?</Text>
        <Text style={styles.sectionDescription}>
          Select from our curated interests or add your own custom ones.
        </Text>

        {/* Available Interests */}
        <View style={styles.interestsContainer}>
          {availableInterests.map((interest, index) => (
            <AnimatedInterestChip
              key={interest.id}
              interest={interest}
              isSelected={selectedInterests.includes(interest.id)}
              onToggle={() => handleInterestToggle(interest.id)}
              delay={index * 50} // Add a small delay for staggered animation
            />
          ))}
          
          {/* Custom Interests - displayed with same styling as curated interests */}
          {customInterests.map((interest, index) => (
            <AnimatedCustomInterestChip
              key={`custom-${index}`}
              interest={interest}
              isSelected={selectedCustomInterests.includes(interest)}
              onToggle={() => handleCustomInterestToggle(interest)}
              onRemove={() => handleRemoveCustomInterest(interest)}
              delay={index * 50} // Add a small delay for staggered animation
            />
          ))}
        </View>

        {/* Custom Interest Input */}
        <View style={styles.customInputContainer}>
          <TextInput
            style={styles.customInput}
            placeholder="Add custom interest..."
            value={customInterest}
            onChangeText={setCustomInterest}
            onSubmitEditing={handleAddCustomInterest}
            returnKeyType="done"
          />
          <TouchableOpacity
            style={styles.addButton}
            onPress={handleAddCustomInterest}
            disabled={!customInterest.trim()}
          >
            <Ionicons name="add" size={20} color="#fff" />
          </TouchableOpacity>
        </View>
      </View>

      {/* Notification Schedule */}
      <View style={styles.section}>
        <Text style={styles.sectionTitle}>When would you like notifications?</Text>
        <Text style={styles.sectionDescription}>
          Choose when and how often you'd like to receive daily words from Larry.
        </Text>

        {/* Time Picker */}
        <View style={styles.timeContainer}>
          <Text style={styles.timeLabel}>Time</Text>
          <TouchableOpacity
            style={[
              styles.timeButton,
              hasSelectedTime && styles.timeButtonSelected,
            ]}
            onPress={openTimePicker}
          >
            <Text style={[
              styles.timeButtonText,
              hasSelectedTime && styles.timeButtonTextSelected,
            ]}>
              {hasSelectedTime ? formatTimeForDisplay(notificationSchedule.localHHmm) : 'Select a time'}
            </Text>
            <Ionicons 
              name="time-outline" 
              size={20} 
              color={hasSelectedTime ? "#007AFF" : "#666"} 
            />
          </TouchableOpacity>
        </View>

        {/* Frequency Selection */}
        <View style={styles.frequencyContainer}>
          <Text style={styles.frequencyLabel}>Frequency</Text>
          <View style={styles.inlineFrequencyPicker}>
            <View style={styles.inlineSelectionIndicator} />
            <ScrollView 
              ref={frequencyScrollRef}
              style={styles.inlineFrequencyScroll}
              showsVerticalScrollIndicator={false}
              snapToInterval={40}
              decelerationRate="fast"
              onScroll={(event) => {
                const y = event.nativeEvent.contentOffset.y;
                const index = Math.round(y / 40);
                const frequencyOptions = ['thrice_daily', 'twice_daily', 'daily', 'every_other', 'weekly'];
                if (index >= 0 && index < frequencyOptions.length) {
                  const newFrequency = frequencyOptions[index] as any;
                  if (newFrequency !== notificationSchedule.frequency) {
                    setNotificationSchedule(prev => ({ ...prev, frequency: newFrequency }));
                    setHasSelectedFrequency(true);
                  }
                }
              }}
              scrollEventThrottle={16}
            >
              <View style={styles.inlineWheelPadding} />
              {[
                { value: 'thrice_daily', label: '3x a day' },
                { value: 'twice_daily', label: '2x a day' },
                { value: 'daily', label: 'Daily' },
                { value: 'every_other', label: 'Every other day' },
                { value: 'weekly', label: 'Weekly' },
              ].map((option) => (
                <View key={option.value} style={styles.inlineFrequencyOption}>
                  <Text style={[
                    styles.inlineFrequencyText,
                    notificationSchedule.frequency === option.value && styles.inlineFrequencyTextSelected,
                  ]}>
                    {option.label}
                  </Text>
                </View>
              ))}
              <View style={styles.inlineWheelPadding} />
            </ScrollView>
          </View>
        </View>
      </View>

      {/* Continue Button */}
      <View style={styles.buttonContainer}>
        <TouchableOpacity
          style={[styles.continueButton, !canContinue() && styles.disabledButton]}
          onPress={handleContinue}
          disabled={!canContinue()}
        >
          {saving ? (
            <ActivityIndicator size="small" color="#fff" />
          ) : (
            <Text style={styles.continueButtonText}>Continue</Text>
          )}
        </TouchableOpacity>
      </View>

      {/* Custom Time Picker Modal */}
      <Modal
        visible={showTimePicker}
        transparent={true}
        animationType="fade"
        onRequestClose={closeTimePicker}
      >
        <View style={styles.modalOverlay}>
          <View style={styles.timePickerModal}>
            <View style={styles.timePickerHeader}>
              <Text style={styles.timePickerTitle}>Select Time</Text>
              <TouchableOpacity onPress={closeTimePicker} style={styles.closeButton}>
                <Ionicons name="close" size={24} color="#666" />
              </TouchableOpacity>
            </View>
            
            <View style={styles.timePickerContent}>
              <TimePickerWheel
                currentTime={tempTime}
                onTimeChange={updateTempTime}
              />
            </View>
            
            <View style={styles.timePickerFooter}>
              <TouchableOpacity style={styles.cancelButton} onPress={closeTimePicker}>
                <Text style={styles.cancelButtonText}>Cancel</Text>
              </TouchableOpacity>
              <TouchableOpacity style={styles.confirmButton} onPress={confirmTimePicker}>
                <Text style={styles.confirmButtonText}>Confirm</Text>
              </TouchableOpacity>
            </View>
          </View>
        </View>
      </Modal>


    </ScrollView>
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
  header: {
    paddingHorizontal: 20,
    paddingTop: 40,
    paddingBottom: 30,
  },
  title: {
    fontSize: 32,
    fontWeight: 'bold',
    color: '#000',
    marginBottom: 12,
    textAlign: 'center',
  },
  subtitle: {
    fontSize: 16,
    color: '#666',
    lineHeight: 24,
    textAlign: 'center',
    paddingHorizontal: 10,
  },
  section: {
    paddingHorizontal: 20,
    marginBottom: 40,
  },
  sectionTitle: {
    fontSize: 22,
    fontWeight: 'bold',
    color: '#000',
    marginBottom: 10,
  },
  sectionDescription: {
    fontSize: 15,
    color: '#666',
    lineHeight: 22,
    marginBottom: 20,
  },
  interestsContainer: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    gap: 10,
    marginBottom: 20,
  },
  interestChip: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: '#F5F5F5',
    borderRadius: 24,
    paddingHorizontal: 18,
    paddingVertical: 12,
    borderWidth: 1,
    borderColor: '#E0E0E0',
    minHeight: 44, // Better touch target
    shadowColor: '#000',
    shadowOffset: {
      width: 0,
      height: 1,
    },
    shadowOpacity: 0.1,
    shadowRadius: 2,
    elevation: 2,
  },
  selectedChip: {
    backgroundColor: '#007AFF',
    borderColor: '#007AFF',
    shadowColor: '#007AFF',
    shadowOffset: {
      width: 0,
      height: 2,
    },
    shadowOpacity: 0.3,
    shadowRadius: 4,
    elevation: 4,
  },
  interestText: {
    fontSize: 15,
    color: '#000',
    marginRight: 4,
    fontWeight: '500',
  },
  selectedInterestText: {
    color: '#fff',
    fontWeight: '600',
  },
  checkIcon: {
    marginLeft: 6,
  },
  customInputContainer: {
    flexDirection: 'row',
    alignItems: 'center',
    marginBottom: 20,
  },
  customInput: {
    flex: 1,
    backgroundColor: '#F5F5F5',
    borderRadius: 16,
    paddingHorizontal: 18,
    paddingVertical: 16,
    fontSize: 16,
    marginRight: 12,
    borderWidth: 1,
    borderColor: '#E0E0E0',
    minHeight: 48, // Better touch target
  },
  addButton: {
    backgroundColor: '#007AFF',
    borderRadius: 24,
    width: 48,
    height: 48,
    justifyContent: 'center',
    alignItems: 'center',
    shadowColor: '#007AFF',
    shadowOffset: {
      width: 0,
      height: 2,
    },
    shadowOpacity: 0.3,
    shadowRadius: 4,
    elevation: 4,
  },
  timeContainer: {
    marginBottom: 24,
  },
  timeLabel: {
    fontSize: 17,
    fontWeight: '600',
    color: '#000',
    marginBottom: 10,
  },
  timeButton: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    backgroundColor: '#F5F5F5',
    borderRadius: 16,
    paddingHorizontal: 18,
    paddingVertical: 16,
    borderWidth: 1,
    borderColor: '#E0E0E0',
    minHeight: 52, // Better touch target
  },
  timeButtonSelected: {
    backgroundColor: '#E3F2FD',
    borderColor: '#2196F3',
    shadowColor: '#2196F3',
    shadowOffset: {
      width: 0,
      height: 2,
    },
    shadowOpacity: 0.2,
    shadowRadius: 4,
    elevation: 3,
  },
  timeButtonText: {
    fontSize: 17,
    color: '#000',
    fontWeight: '500',
  },
  timeButtonTextSelected: {
    color: '#007AFF',
    fontWeight: '600',
  },
  frequencyContainer: {
    marginBottom: 24,
  },
  frequencyButton: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    backgroundColor: '#F5F5F5',
    borderRadius: 12,
    paddingHorizontal: 16,
    paddingVertical: 14,
    borderWidth: 1,
    borderColor: '#E0E0E0',
  },
  frequencyButtonSelected: {
    backgroundColor: '#E3F2FD',
    borderColor: '#2196F3',
  },
  frequencyButtonText: {
    fontSize: 16,
    color: '#000',
    fontWeight: '500',
  },
  frequencyButtonTextSelected: {
    color: '#007AFF',
    fontWeight: '600',
  },
  frequencyPickerWheel: {
    justifyContent: 'center',
    alignItems: 'center',
    paddingHorizontal: 20,
    height: 200,
  },
  wheelContainer: {
    position: 'relative',
    width: 200,
    height: 150,
  },
  selectionIndicator: {
    position: 'absolute',
    top: 50, // Center of the visible area
    left: 0,
    right: 0,
    height: 50,
    backgroundColor: 'rgba(0, 122, 255, 0.1)',
    borderRadius: 8,
    zIndex: 1,
  },
  frequencyWheelScroll: {
    height: 150,
  },
  frequencyWheelOption: {
    height: 50,
    justifyContent: 'center',
    alignItems: 'center',
  },
  frequencyWheelOptionText: {
    fontSize: 18,
    color: '#999',
    fontWeight: '400',
  },
  frequencyWheelOptionTextSelected: {
    color: '#000',
    fontWeight: '600',
  },
  wheelPadding: {
    height: 50,
  },
  inlineFrequencyPicker: {
    position: 'relative',
    height: 120,
    backgroundColor: '#F5F5F5',
    borderRadius: 12,
    borderWidth: 1,
    borderColor: '#E0E0E0',
    overflow: 'hidden',
  },
  inlineSelectionIndicator: {
    position: 'absolute',
    top: 40, // Center of the visible area
    left: 0,
    right: 0,
    height: 40,
    backgroundColor: 'rgba(0, 122, 255, 0.1)',
    borderRadius: 8,
    zIndex: 1,
  },
  inlineFrequencyScroll: {
    height: 120,
  },
  inlineFrequencyOption: {
    height: 40,
    justifyContent: 'center',
    alignItems: 'center',
  },
  inlineFrequencyText: {
    fontSize: 16,
    color: '#999',
    fontWeight: '400',
  },
  inlineFrequencyTextSelected: {
    color: '#000',
    fontWeight: '600',
  },
  inlineWheelPadding: {
    height: 40,
  },
  frequencyLabel: {
    fontSize: 17,
    fontWeight: '600',
    color: '#000',
    marginBottom: 10,
  },
  frequencyOption: {
    backgroundColor: '#F5F5F5',
    borderRadius: 12,
    paddingHorizontal: 16,
    paddingVertical: 14,
    borderWidth: 1,
    borderColor: '#E0E0E0',
  },
  selectedFrequencyOption: {
    backgroundColor: '#E3F2FD',
    borderColor: '#2196F3',
  },
  radioContainer: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  radio: {
    width: 20,
    height: 20,
    borderRadius: 10,
    borderWidth: 2,
    borderColor: '#666',
    marginRight: 12,
    justifyContent: 'center',
    alignItems: 'center',
  },
  radioSelected: {
    borderColor: '#007AFF',
  },
  radioInner: {
    width: 8,
    height: 8,
    borderRadius: 4,
    backgroundColor: '#007AFF',
  },
  frequencyText: {
    fontSize: 16,
    color: '#000',
  },
  selectedFrequencyText: {
    color: '#007AFF',
    fontWeight: '500',
  },
  buttonContainer: {
    paddingHorizontal: 20,
    paddingVertical: 30,
    paddingBottom: 50,
  },
  continueButton: {
    backgroundColor: '#007AFF',
    borderRadius: 16,
    paddingVertical: 18,
    alignItems: 'center',
    shadowColor: '#007AFF',
    shadowOffset: {
      width: 0,
      height: 4,
    },
    shadowOpacity: 0.3,
    shadowRadius: 8,
    elevation: 6,
  },
  disabledButton: {
    backgroundColor: '#E0E0E0',
    shadowOpacity: 0,
    elevation: 0,
  },
  continueButtonText: {
    fontSize: 19,
    color: '#fff',
    fontWeight: '700',
  },
  // Time Picker Modal Styles
  modalOverlay: {
    flex: 1,
    backgroundColor: 'rgba(0, 0, 0, 0.5)',
    justifyContent: 'center',
    alignItems: 'center',
  },
  timePickerModal: {
    backgroundColor: '#fff',
    borderRadius: 16,
    width: '90%',
    maxWidth: 350,
    padding: 0,
    shadowColor: '#000',
    shadowOffset: {
      width: 0,
      height: 2,
    },
    shadowOpacity: 0.25,
    shadowRadius: 3.84,
    elevation: 5,
  },
  timePickerHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    paddingHorizontal: 20,
    paddingVertical: 16,
    borderBottomWidth: 1,
    borderBottomColor: '#E0E0E0',
  },
  timePickerTitle: {
    fontSize: 18,
    fontWeight: '600',
    color: '#000',
  },
  closeButton: {
    padding: 4,
  },
  timePickerContent: {
    paddingVertical: 20,
  },
  timePickerFooter: {
    flexDirection: 'row',
    borderTopWidth: 1,
    borderTopColor: '#E0E0E0',
  },
  cancelButton: {
    flex: 1,
    paddingVertical: 16,
    alignItems: 'center',
    borderRightWidth: 0.5,
    borderRightColor: '#E0E0E0',
  },
  cancelButtonText: {
    fontSize: 16,
    color: '#666',
    fontWeight: '500',
  },
  confirmButton: {
    flex: 1,
    paddingVertical: 16,
    alignItems: 'center',
    borderLeftWidth: 0.5,
    borderLeftColor: '#E0E0E0',
  },
  confirmButtonText: {
    fontSize: 16,
    color: '#007AFF',
    fontWeight: '600',
  },
  // Time Picker Wheel Styles
  timePickerWheel: {
    flexDirection: 'row',
    justifyContent: 'center',
    alignItems: 'center',
    paddingHorizontal: 20,
  },
  wheelColumn: {
    alignItems: 'center',
    flex: 1,
  },
  wheelLabel: {
    fontSize: 14,
    color: '#666',
    marginBottom: 8,
    fontWeight: '500',
  },
  wheelScroll: {
    height: 120,
  },
  wheelOption: {
    height: 40,
    justifyContent: 'center',
    alignItems: 'center',
    paddingHorizontal: 16,
    borderRadius: 8,
  },
  wheelOptionSelected: {
    backgroundColor: '#007AFF',
  },
  wheelOptionText: {
    fontSize: 18,
    color: '#000',
    fontWeight: '500',
  },
  wheelOptionTextSelected: {
    color: '#fff',
    fontWeight: '600',
  },
  timeSeparator: {
    fontSize: 24,
    color: '#000',
    fontWeight: '600',
    marginHorizontal: 16,
    marginTop: 20,
  },
  // New styles for AnimatedInterestChip and AnimatedCustomInterestChip
  interestChipContainer: {
    transform: [{ scale: 0 }], // Initial scale
    opacity: 0, // Initial opacity
  },
  checkIconContainer: {
    marginLeft: 6,
  },

});
