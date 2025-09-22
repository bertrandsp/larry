import React, { useState, useEffect } from 'react';
import { View, Text, StyleSheet, TouchableOpacity, ActivityIndicator } from 'react-native';
import { testApiConnection, getDailyWord } from '../services/api';
import { mapDailyWordResponse } from '../utils/wordMapper';

export default function ApiTest() {
  const [healthStatus, setHealthStatus] = useState(null);
  const [dailyWord, setDailyWord] = useState(null);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState(null);

  const testConnection = async () => {
    setLoading(true);
    setError(null);
    
    try {
      const result = await testApiConnection();
      setHealthStatus(result);
      
      if (result.success) {
        // If health check passes, try to get daily word
        try {
          const response = await getDailyWord();
          
          const wordData = mapDailyWordResponse(response);
          if (wordData) {
            setDailyWord(wordData);
          }
        } catch (wordError) {
          console.error('Failed to get daily word:', wordError);
          setError(`Health check passed but daily word failed: ${wordError.message}`);
        }
      }
    } catch (err) {
      setError(err.message);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    // Test connection on component mount
    testConnection();
  }, []);

  return (
    <View style={styles.container}>
      <Text style={styles.title}>🔌 API Connection Test</Text>
      
      <TouchableOpacity 
        style={styles.testButton} 
        onPress={testConnection}
        disabled={loading}
      >
        {loading ? (
          <ActivityIndicator color="#ffffff" />
        ) : (
          <Text style={styles.buttonText}>Test Connection</Text>
        )}
      </TouchableOpacity>

      {healthStatus && (
        <View style={styles.resultContainer}>
          <Text style={styles.resultTitle}>Health Check:</Text>
          <Text style={[
            styles.resultText, 
            healthStatus.success ? styles.success : styles.error
          ]}>
            {healthStatus.success ? '✅ Connected' : '❌ Failed'}
          </Text>
          {healthStatus.data && (
            <Text style={styles.details}>Response: {JSON.stringify(healthStatus.data)}</Text>
          )}
          {healthStatus.error && (
            <Text style={styles.errorDetails}>Error: {healthStatus.error}</Text>
          )}
        </View>
      )}

      {dailyWord && (
        <View style={styles.resultContainer}>
          <Text style={styles.resultTitle}>Daily Word Test:</Text>
          <Text style={styles.success}>✅ Success</Text>
          <Text style={styles.details}>Word: {JSON.stringify(dailyWord, null, 2)}</Text>
        </View>
      )}

      {error && (
        <View style={styles.resultContainer}>
          <Text style={styles.resultTitle}>Error:</Text>
          <Text style={styles.errorDetails}>{error}</Text>
        </View>
      )}

      <Text style={styles.instructions}>
        Make sure your backend is running with: docker-compose up
      </Text>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    padding: 20,
    backgroundColor: '#f9fafb',
    justifyContent: 'center',
  },
  title: {
    fontSize: 24,
    fontWeight: 'bold',
    textAlign: 'center',
    marginBottom: 30,
    color: '#111827',
  },
  testButton: {
    backgroundColor: '#3b82f6',
    padding: 15,
    borderRadius: 8,
    alignItems: 'center',
    marginBottom: 20,
  },
  buttonText: {
    color: '#ffffff',
    fontSize: 16,
    fontWeight: '600',
  },
  resultContainer: {
    backgroundColor: '#ffffff',
    padding: 15,
    borderRadius: 8,
    marginBottom: 15,
    borderWidth: 1,
    borderColor: '#e5e7eb',
  },
  resultTitle: {
    fontSize: 16,
    fontWeight: '600',
    marginBottom: 5,
    color: '#374151',
  },
  resultText: {
    fontSize: 14,
    marginBottom: 5,
  },
  success: {
    color: '#059669',
  },
  error: {
    color: '#dc2626',
  },
  details: {
    fontSize: 12,
    color: '#6b7280',
    fontFamily: 'monospace',
  },
  errorDetails: {
    fontSize: 12,
    color: '#dc2626',
  },
  instructions: {
    fontSize: 12,
    color: '#6b7280',
    textAlign: 'center',
    marginTop: 20,
    fontStyle: 'italic',
  },
});

