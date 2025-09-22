import React, { useState } from 'react';
import api from '../lib/api';

const TopicInputForm: React.FC<{ onTopicSubmitted: () => void }> = ({ onTopicSubmitted }) => {
  const [topic, setTopic] = useState('');
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [message, setMessage] = useState('');

  // User ID for super-api (we'll create this user)
  const userId = 'ba2ed75f-6d7c-4a6c-97d8-25bac01a90fe';

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!topic.trim()) return;

    setIsSubmitting(true);
    setMessage('');

    try {
      const response = await api.post('/user/topics', {
        userId,
        topicName: topic.trim()
      });

      setMessage('Topic submitted successfully!');
      setTopic('');
      onTopicSubmitted(); // Trigger refresh of topic list
    } catch (error: any) {
      console.error('Error submitting topic:', error);
      setMessage(error.response?.data?.error || 'Failed to submit topic');
    } finally {
      setIsSubmitting(false);
    }
  };

  return (
    <div className="card">
      <h2 className="text-xl font-semibold mb-4">Submit New Topic</h2>
      <form onSubmit={handleSubmit} className="space-y-4">
        <div>
          <label htmlFor="topic" className="block text-sm font-medium text-gray-700 mb-2">
            Topic Name
          </label>
          <input
            type="text"
            id="topic"
            value={topic}
            onChange={(e) => setTopic(e.target.value)}
            placeholder="e.g., Sommelier, Quantum Physics, etc."
            className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-primary-500 focus:border-transparent"
            required
          />
        </div>
        <button
          type="submit"
          disabled={isSubmitting}
          className="btn-primary disabled:opacity-50 disabled:cursor-not-allowed"
        >
          {isSubmitting ? 'Submitting...' : 'Submit Topic'}
        </button>
      </form>
      {message && (
        <div className={`mt-3 p-3 rounded-md ${
          message.includes('successfully') 
            ? 'bg-green-100 text-green-800 border border-green-200' 
            : 'bg-red-100 text-red-800 border border-red-200'
        }`}>
          {message}
        </div>
      )}
    </div>
  );
};

export default TopicInputForm;
