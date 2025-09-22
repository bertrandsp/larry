import React, { useState, useEffect } from 'react';
import api from '../lib/api';

interface Topic {
  id: string;
  name: string;
  weight: number;
  termCount?: number;
  factCount?: number;
}

const TopicList: React.FC = () => {
  const [topics, setTopics] = useState<Topic[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  // User ID for super-api
  const userId = 'ba2ed75f-6d7c-4a6c-97d8-25bac01a90fe';

  const fetchTopics = async () => {
    try {
      setLoading(true);
      const response = await api.get(`/user/${userId}/topics`);
      setTopics(response.data);
      setError(null);
    } catch (err: any) {
      console.error('Error fetching topics:', err);
      setError(err.response?.data?.error || 'Failed to fetch topics');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchTopics();
  }, []);

  if (loading) {
    return (
      <div className="card">
        <h2 className="text-xl font-semibold mb-4">Your Topics</h2>
        <div className="animate-pulse space-y-3">
          <div className="h-4 bg-gray-200 rounded w-3/4"></div>
          <div className="h-4 bg-gray-200 rounded w-1/2"></div>
          <div className="h-4 bg-gray-200 rounded w-2/3"></div>
        </div>
      </div>
    );
  }

  if (error) {
    return (
      <div className="card">
        <h2 className="text-xl font-semibold mb-4">Your Topics</h2>
        <div className="text-red-600 bg-red-50 p-3 rounded-md">
          {error}
        </div>
        <button 
          onClick={fetchTopics}
          className="btn-secondary mt-3"
        >
          Retry
        </button>
      </div>
    );
  }

  return (
    <div className="card">
      <h2 className="text-xl font-semibold mb-4">Your Topics</h2>
      {topics.length === 0 ? (
        <p className="text-gray-500 text-center py-4">No topics submitted yet. Submit your first topic above!</p>
      ) : (
        <div className="space-y-3">
          {topics.map((topic) => (
            <div key={topic.id} className="flex items-center justify-between p-3 bg-gray-50 rounded-lg">
              <div>
                <h3 className="font-medium text-gray-900">{topic.name}</h3>
                <p className="text-sm text-gray-600">
                  Weight: {topic.weight}%
                  {topic.termCount !== undefined && ` • ${topic.termCount} terms`}
                  {topic.factCount !== undefined && ` • ${topic.factCount} facts`}
                </p>
              </div>
            </div>
          ))}
        </div>
      )}
    </div>
  );
};

export default TopicList;
