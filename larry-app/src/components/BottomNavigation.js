import React from 'react';
import { View, Text, TouchableOpacity, StyleSheet } from 'react-native';
import { Ionicons } from '@expo/vector-icons';

export function BottomNavigation({ currentScreen, onNavigate }) {
  const navItems = [
    { id: 'home', icon: 'home', label: 'Home' },
    { id: 'practice', icon: 'bulb-outline', label: 'Practice' },
    { id: 'wordbank', icon: 'book-outline', label: 'Wordbank' },
    { id: 'profile', icon: 'person-outline', label: 'Profile' },
  ];

  return (
    <View style={styles.bottomNavigation}>
      {navItems.map((item) => (
        <TouchableOpacity
          key={item.id}
          style={styles.navItem}
          onPress={() => onNavigate(item.id)}
        >
          <Ionicons
            name={item.icon}
            size={24}
            color={currentScreen === item.id ? '#007AFF' : '#8E8E93'}
          />
          <Text
            style={[
              styles.navText,
              currentScreen === item.id && styles.activeNavText,
            ]}
          >
            {item.label}
          </Text>
        </TouchableOpacity>
      ))}
    </View>
  );
}

const styles = StyleSheet.create({
  bottomNavigation: {
    flexDirection: 'row',
    backgroundColor: '#fff',
    borderTopWidth: 1,
    borderTopColor: '#F0F0F0',
    paddingBottom: 20,
    paddingTop: 8,
  },
  navItem: {
    flex: 1,
    alignItems: 'center',
    paddingVertical: 8,
  },
  navText: {
    fontSize: 12,
    color: '#8E8E93',
    marginTop: 4,
    fontWeight: '500',
  },
  activeNavText: {
    color: '#007AFF',
  },
});
