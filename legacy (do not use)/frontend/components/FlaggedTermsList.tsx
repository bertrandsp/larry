import React, { useState } from 'react';

interface Term {
  id: string;
  term: string;
  definition: string;
  example: string;
  confidenceScore: number;
  moderationStatus: string;
  moderationNote?: string;
  topic: {
    id: string;
    name: string;
  };
  createdAt: string;
  updatedAt: string;
}

interface FlaggedTermsListProps {
  terms: Term[];
  onModerate: (id: string, status: string, definition?: string, note?: string) => Promise<void>;
  loading?: boolean;
}

const FlaggedTermsList: React.FC<FlaggedTermsListProps> = ({ 
  terms, 
  onModerate, 
  loading = false 
}) => {
  const [editingTerm, setEditingTerm] = useState<string | null>(null);
  const [editDefinitions, setEditDefinitions] = useState<Record<string, string>>({});
  const [editNotes, setEditNotes] = useState<Record<string, string>>({});
  const [moderating, setModerating] = useState<Record<string, boolean>>({});

  const handleEditDefinition = (termId: string, currentDefinition: string) => {
    setEditingTerm(termId);
    setEditDefinitions(prev => ({
      ...prev,
      [termId]: currentDefinition
    }));
  };

  const handleSaveEdit = (termId: string) => {
    setEditingTerm(null);
  };

  const handleModerate = async (termId: string, status: string) => {
    setModerating(prev => ({ ...prev, [termId]: true }));
    
    try {
      const definition = editDefinitions[termId];
      const note = editNotes[termId];
      await onModerate(termId, status, definition, note);
      
      // Clear edit state
      setEditDefinitions(prev => {
        const newState = { ...prev };
        delete newState[termId];
        return newState;
      });
      setEditNotes(prev => {
        const newState = { ...prev };
        delete newState[termId];
        return newState;
      });
    } catch (error) {
      console.error('Error moderating term:', error);
    } finally {
      setModerating(prev => ({ ...prev, [termId]: false }));
    }
  };

  const getStatusColor = (status: string) => {
    switch (status) {
      case 'approved': return 'bg-green-100 text-green-800';
      case 'rejected': return 'bg-red-100 text-red-800';
      case 'pending': return 'bg-yellow-100 text-yellow-800';
      default: return 'bg-gray-100 text-gray-800';
    }
  };

  const getConfidenceColor = (score: number) => {
    if (score < 0.3) return 'text-red-600';
    if (score < 0.5) return 'text-yellow-600';
    return 'text-green-600';
  };

  if (loading) {
    return (
      <div className="space-y-4">
        {[...Array(3)].map((_, i) => (
          <div key={i} className="bg-white rounded-lg shadow p-6 animate-pulse">
            <div className="h-4 bg-gray-200 rounded w-1/4 mb-2"></div>
            <div className="h-4 bg-gray-200 rounded w-3/4 mb-2"></div>
            <div className="h-4 bg-gray-200 rounded w-1/2"></div>
          </div>
        ))}
      </div>
    );
  }

  if (terms.length === 0) {
    return (
      <div className="text-center py-12">
        <div className="text-gray-500 text-lg">🎉 No flagged terms to review!</div>
        <p className="text-gray-400 mt-2">All terms have been reviewed or have high confidence scores.</p>
      </div>
    );
  }

  return (
    <div className="space-y-4">
      {terms.map((term) => (
        <div key={term.id} className="bg-white rounded-lg shadow p-6 border-l-4 border-yellow-400">
          {/* Header */}
          <div className="flex justify-between items-start mb-4">
            <div>
              <h3 className="text-lg font-semibold text-gray-900">{term.term}</h3>
              <div className="flex items-center space-x-4 mt-1">
                <span className="text-sm text-gray-500">Topic: {term.topic.name}</span>
                <span className={`text-sm font-medium ${getConfidenceColor(term.confidenceScore)}`}>
                  Confidence: {(term.confidenceScore * 100).toFixed(0)}%
                </span>
                <span className={`px-2 py-1 rounded-full text-xs font-medium ${getStatusColor(term.moderationStatus)}`}>
                  {term.moderationStatus}
                </span>
              </div>
            </div>
          </div>

          {/* Definition */}
          <div className="mb-4">
            <label className="block text-sm font-medium text-gray-700 mb-2">
              Definition:
            </label>
            {editingTerm === term.id ? (
              <div className="space-y-2">
                <textarea
                  value={editDefinitions[term.id] || term.definition}
                  onChange={(e) => setEditDefinitions(prev => ({
                    ...prev,
                    [term.id]: e.target.value
                  }))}
                  className="w-full p-3 border border-gray-300 rounded-md focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                  rows={3}
                />
                <div className="flex space-x-2">
                  <button
                    onClick={() => handleSaveEdit(term.id)}
                    className="px-3 py-1 bg-blue-500 text-white rounded text-sm hover:bg-blue-600"
                  >
                    Save
                  </button>
                  <button
                    onClick={() => setEditingTerm(null)}
                    className="px-3 py-1 bg-gray-500 text-white rounded text-sm hover:bg-gray-600"
                  >
                    Cancel
                  </button>
                </div>
              </div>
            ) : (
              <div className="flex items-start justify-between">
                <p className="text-gray-700 flex-1">{term.definition}</p>
                <button
                  onClick={() => handleEditDefinition(term.id, term.definition)}
                  className="ml-2 px-2 py-1 text-blue-600 hover:text-blue-800 text-sm"
                >
                  ✏️ Edit
                </button>
              </div>
            )}
          </div>

          {/* Example */}
          <div className="mb-4">
            <label className="block text-sm font-medium text-gray-700 mb-1">
              Example:
            </label>
            <p className="text-gray-600 italic">"{term.example}"</p>
          </div>

          {/* Admin Note */}
          <div className="mb-4">
            <label className="block text-sm font-medium text-gray-700 mb-2">
              Admin Note:
            </label>
            <textarea
              value={editNotes[term.id] || term.moderationNote || ''}
              onChange={(e) => setEditNotes(prev => ({
                ...prev,
                [term.id]: e.target.value
              }))}
              placeholder="Add a note about this moderation decision..."
              className="w-full p-2 border border-gray-300 rounded-md focus:ring-2 focus:ring-blue-500 focus:border-transparent"
              rows={2}
            />
          </div>

          {/* Action Buttons */}
          <div className="flex space-x-3">
            <button
              onClick={() => handleModerate(term.id, 'approved')}
              disabled={moderating[term.id]}
              className="px-4 py-2 bg-green-500 text-white rounded-md hover:bg-green-600 disabled:opacity-50 disabled:cursor-not-allowed flex items-center"
            >
              {moderating[term.id] ? '⏳' : '✅'} Approve
            </button>
            <button
              onClick={() => handleModerate(term.id, 'rejected')}
              disabled={moderating[term.id]}
              className="px-4 py-2 bg-red-500 text-white rounded-md hover:bg-red-600 disabled:opacity-50 disabled:cursor-not-allowed flex items-center"
            >
              {moderating[term.id] ? '⏳' : '❌'} Reject
            </button>
            <button
              onClick={() => handleModerate(term.id, 'pending')}
              disabled={moderating[term.id]}
              className="px-4 py-2 bg-yellow-500 text-white rounded-md hover:bg-yellow-600 disabled:opacity-50 disabled:cursor-not-allowed flex items-center"
            >
              {moderating[term.id] ? '⏳' : '⏸️'} Keep Pending
            </button>
          </div>

          {/* Metadata */}
          <div className="mt-4 pt-4 border-t border-gray-200 text-xs text-gray-500">
            <div className="flex justify-between">
              <span>Created: {new Date(term.createdAt).toLocaleDateString()}</span>
              <span>Updated: {new Date(term.updatedAt).toLocaleDateString()}</span>
            </div>
          </div>
        </div>
      ))}
    </div>
  );
};

export default FlaggedTermsList;



