import React, { useState, useEffect } from 'react';
import api from '../lib/api';

interface Term {
  id: string;
  term: string;
  definition: string;
  example: string;
  topicId: string;
  createdAt: string;
}

const TermFeed: React.FC = () => {
  const [terms, setTerms] = useState<Term[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    fetchTerms();
  }, []);

  const fetchTerms = async () => {
    try {
      setLoading(true);
      setError(null);
      
      // For now, we'll use a hardcoded user ID since we don't have auth yet
      const userId = 'ba2ed75f-6d7c-4a6c-97d8-25bac01a90fe';
      const response = await api.get(`/user/${userId}/terms`);
      setTerms(response.data);
    } catch (err: any) {
      console.error('Error fetching terms:', err);
      setError('Failed to fetch terms');
    } finally {
      setLoading(false);
    }
  };

  if (loading) {
    return (
      <div className="bg-white rounded-lg shadow-md p-6">
        <h2 className="text-2xl font-bold text-gray-900 mb-4">Daily Terms</h2>
        <div className="animate-pulse">
          <div className="h-4 bg-gray-200 rounded mb-2"></div>
          <div className="h-4 bg-gray-200 rounded mb-2"></div>
          <div className="h-4 bg-gray-200 rounded mb-2"></div>
        </div>
      </div>
    );
  }

  if (error) {
    return (
      <div className="bg-white rounded-lg shadow-md p-6">
        <h2 className="text-2xl font-bold text-gray-900 mb-4">Daily Terms</h2>
        <div className="text-red-600 mb-4">{error}</div>
        <button 
          onClick={fetchTerms}
          className="px-4 py-2 bg-blue-500 text-white rounded hover:bg-blue-600"
        >
          Retry
        </button>
      </div>
    );
  }

  return (
    <div className="bg-white rounded-lg shadow-md p-6">
      <h2 className="text-2xl font-bold text-gray-900 mb-4">Daily Terms</h2>
      
      {terms.length === 0 ? (
        <div className="text-gray-500 text-center py-8">
          <p>No terms available yet.</p>
          <p className="text-sm mt-2">Create a topic to start generating vocabulary!</p>
        </div>
      ) : (
        <div className="space-y-4">
          {terms.map((term) => (
            <div key={term.id} className="border-b border-gray-200 pb-4 last:border-b-0">
              <h3 className="text-lg font-semibold text-gray-900 mb-2">
                {term.term}
              </h3>
              <p className="text-gray-700 mb-2">
                {term.definition}
              </p>
              {term.example && (
                <p className="text-sm text-gray-600 italic">
                  Example: {term.example}
                </p>
              )}
              <div className="text-xs text-gray-400 mt-2">
                {new Date(term.createdAt).toLocaleDateString()}
              </div>
            </div>
          ))}
        </div>
      )}
    </div>
  );
};

export default TermFeed;
