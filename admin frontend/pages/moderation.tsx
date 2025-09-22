import { useState, useEffect } from 'react';
import Head from 'next/head';
import Link from 'next/link';
import { ArrowLeft, Shield, CheckCircle, XCircle, AlertTriangle, Eye, Filter } from 'lucide-react';

interface Term {
  id: string;
  term: string;
  definition: string;
  example: string;
  topic: string;
  confidence: number;
  source: string;
  moderationStatus: 'pending' | 'approved' | 'rejected' | 'flagged';
  flagReason?: string;
  createdAt: string;
  updatedAt: string;
}

interface ModerationStats {
  totalTerms: number;
  pendingTerms: number;
  approvedTerms: number;
  rejectedTerms: number;
  flaggedTerms: number;
}

export default function Moderation() {
  const [terms, setTerms] = useState<Term[]>([]);
  const [stats, setStats] = useState<ModerationStats | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [filter, setFilter] = useState<'all' | 'pending' | 'flagged' | 'approved' | 'rejected'>('all');
  const [selectedTerms, setSelectedTerms] = useState<string[]>([]);

  useEffect(() => {
    fetchData();
  }, []);

  const fetchData = async () => {
    try {
      setLoading(true);
      
      // Fetch flagged terms
      const flaggedResponse = await fetch(`${process.env.NEXT_PUBLIC_API_URL}/admin/terms/flagged`, {
        headers: {
          'Authorization': 'Bearer admin-token' // You'll need to set this properly
        }
      });
      
      if (flaggedResponse.ok) {
        const flaggedData = await flaggedResponse.json();
        setTerms(flaggedData.terms || []);
      }

      // Fetch moderation stats
      const statsResponse = await fetch(`${process.env.NEXT_PUBLIC_API_URL}/admin/moderation/stats`, {
        headers: {
          'Authorization': 'Bearer admin-token' // You'll need to set this properly
        }
      });
      
      if (statsResponse.ok) {
        const statsData = await statsResponse.json();
        setStats(statsData);
      }
      
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Failed to fetch data');
    } finally {
      setLoading(false);
    }
  };

  const handleModerateTerm = async (termId: string, action: 'approve' | 'reject') => {
    try {
      const response = await fetch(`${process.env.NEXT_PUBLIC_API_URL}/admin/terms/${termId}/moderate`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer admin-token' // You'll need to set this properly
        },
        body: JSON.stringify({
          action,
          reason: action === 'reject' ? 'Inappropriate content' : undefined
        }),
      });

      if (response.ok) {
        // Update local state
        setTerms(terms.map(term => 
          term.id === termId 
            ? { ...term, moderationStatus: action === 'approve' ? 'approved' : 'rejected' }
            : term
        ));
        
        // Refresh stats
        fetchData();
      }
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Failed to moderate term');
    }
  };

  const handleBulkModerate = async (action: 'approve' | 'reject') => {
    try {
      const response = await fetch(`${process.env.NEXT_PUBLIC_API_URL}/admin/terms/bulk-moderate`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer admin-token' // You'll need to set this properly
        },
        body: JSON.stringify({
          termIds: selectedTerms,
          action,
          reason: action === 'reject' ? 'Bulk moderation - inappropriate content' : undefined
        }),
      });

      if (response.ok) {
        // Update local state
        setTerms(terms.map(term => 
          selectedTerms.includes(term.id)
            ? { ...term, moderationStatus: action === 'approve' ? 'approved' : 'rejected' }
            : term
        ));
        
        setSelectedTerms([]);
        fetchData();
      }
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Failed to bulk moderate terms');
    }
  };

  const filteredTerms = terms.filter(term => {
    if (filter === 'all') return true;
    return term.moderationStatus === filter;
  });

  const getStatusColor = (status: string) => {
    switch (status) {
      case 'approved': return 'bg-green-100 text-green-800';
      case 'rejected': return 'bg-red-100 text-red-800';
      case 'flagged': return 'bg-yellow-100 text-yellow-800';
      case 'pending': return 'bg-gray-100 text-gray-800';
      default: return 'bg-gray-100 text-gray-800';
    }
  };

  const getStatusIcon = (status: string) => {
    switch (status) {
      case 'approved': return <CheckCircle className="w-4 h-4" />;
      case 'rejected': return <XCircle className="w-4 h-4" />;
      case 'flagged': return <AlertTriangle className="w-4 h-4" />;
      case 'pending': return <Eye className="w-4 h-4" />;
      default: return <Eye className="w-4 h-4" />;
    }
  };

  if (loading) {
    return (
      <div className="min-h-screen bg-gray-50 flex items-center justify-center">
        <div className="text-center">
          <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600 mx-auto"></div>
          <p className="mt-4 text-gray-600">Loading moderation data...</p>
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-gray-50">
      <Head>
        <title>Content Moderation - Larry Admin</title>
        <meta name="description" content="Moderate vocabulary terms and content" />
        <link rel="icon" href="/favicon.ico" />
      </Head>

      <div className="max-w-7xl mx-auto py-8 px-4 sm:px-6 lg:px-8">
        {/* Header */}
        <div className="mb-8">
          <Link href="/" className="inline-flex items-center text-blue-600 hover:text-blue-800 mb-4">
            <ArrowLeft className="w-4 h-4 mr-2" />
            Back to Dashboard
          </Link>
          <h1 className="text-4xl font-bold text-gray-900 mb-2">
            Content Moderation
          </h1>
          <p className="text-lg text-gray-600">
            Review and moderate flagged vocabulary terms
          </p>
        </div>

        {/* Stats */}
        {stats && (
          <div className="grid grid-cols-1 md:grid-cols-5 gap-6 mb-8">
            <div className="card">
              <div className="flex items-center">
                <Shield className="w-8 h-8 text-blue-600 mr-3" />
                <div>
                  <p className="text-sm text-gray-600">Total Terms</p>
                  <p className="text-2xl font-bold text-gray-900">{stats.totalTerms}</p>
                </div>
              </div>
            </div>
            
            <div className="card">
              <div className="flex items-center">
                <Eye className="w-8 h-8 text-gray-600 mr-3" />
                <div>
                  <p className="text-sm text-gray-600">Pending</p>
                  <p className="text-2xl font-bold text-gray-900">{stats.pendingTerms}</p>
                </div>
              </div>
            </div>
            
            <div className="card">
              <div className="flex items-center">
                <AlertTriangle className="w-8 h-8 text-yellow-600 mr-3" />
                <div>
                  <p className="text-sm text-gray-600">Flagged</p>
                  <p className="text-2xl font-bold text-gray-900">{stats.flaggedTerms}</p>
                </div>
              </div>
            </div>
            
            <div className="card">
              <div className="flex items-center">
                <CheckCircle className="w-8 h-8 text-green-600 mr-3" />
                <div>
                  <p className="text-sm text-gray-600">Approved</p>
                  <p className="text-2xl font-bold text-gray-900">{stats.approvedTerms}</p>
                </div>
              </div>
            </div>
            
            <div className="card">
              <div className="flex items-center">
                <XCircle className="w-8 h-8 text-red-600 mr-3" />
                <div>
                  <p className="text-sm text-gray-600">Rejected</p>
                  <p className="text-2xl font-bold text-gray-900">{stats.rejectedTerms}</p>
                </div>
              </div>
            </div>
          </div>
        )}

        {/* Filters and Actions */}
        <div className="card mb-6">
          <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between">
            <div className="flex items-center space-x-4 mb-4 sm:mb-0">
              <div className="flex items-center">
                <Filter className="w-5 h-5 text-gray-400 mr-2" />
                <select
                  value={filter}
                  onChange={(e) => setFilter(e.target.value as any)}
                  className="input-field w-auto"
                >
                  <option value="all">All Terms</option>
                  <option value="pending">Pending</option>
                  <option value="flagged">Flagged</option>
                  <option value="approved">Approved</option>
                  <option value="rejected">Rejected</option>
                </select>
              </div>
            </div>

            {selectedTerms.length > 0 && (
              <div className="flex items-center space-x-2">
                <span className="text-sm text-gray-600">
                  {selectedTerms.length} selected
                </span>
                <button
                  onClick={() => handleBulkModerate('approve')}
                  className="btn-primary text-sm"
                >
                  Approve Selected
                </button>
                <button
                  onClick={() => handleBulkModerate('reject')}
                  className="btn-secondary text-sm"
                >
                  Reject Selected
                </button>
              </div>
            )}
          </div>
        </div>

        {/* Terms List */}
        <div className="space-y-4">
          {filteredTerms.map((term) => (
            <div key={term.id} className="card">
              <div className="flex items-start justify-between">
                <div className="flex-1">
                  <div className="flex items-center mb-2">
                    <input
                      type="checkbox"
                      checked={selectedTerms.includes(term.id)}
                      onChange={(e) => {
                        if (e.target.checked) {
                          setSelectedTerms([...selectedTerms, term.id]);
                        } else {
                          setSelectedTerms(selectedTerms.filter(id => id !== term.id));
                        }
                      }}
                      className="mr-3"
                    />
                    <h3 className="text-lg font-semibold text-gray-900 mr-3">{term.term}</h3>
                    <span className={`inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium ${getStatusColor(term.moderationStatus)}`}>
                      {getStatusIcon(term.moderationStatus)}
                      <span className="ml-1 capitalize">{term.moderationStatus}</span>
                    </span>
                  </div>
                  
                  <p className="text-gray-700 mb-2">{term.definition}</p>
                  <p className="text-sm text-gray-600 italic mb-3">"{term.example}"</p>
                  
                  <div className="flex items-center space-x-4 text-sm text-gray-500">
                    <span>Topic: {term.topic}</span>
                    <span>Confidence: {term.confidence}%</span>
                    <span>Source: {term.source}</span>
                    <span>Created: {new Date(term.createdAt).toLocaleDateString()}</span>
                  </div>

                  {term.flagReason && (
                    <div className="mt-3 p-3 bg-yellow-50 border border-yellow-200 rounded-md">
                      <p className="text-sm text-yellow-800">
                        <strong>Flag Reason:</strong> {term.flagReason}
                      </p>
                    </div>
                  )}
                </div>

                {term.moderationStatus === 'pending' || term.moderationStatus === 'flagged' ? (
                  <div className="flex items-center space-x-2 ml-4">
                    <button
                      onClick={() => handleModerateTerm(term.id, 'approve')}
                      className="btn-primary text-sm"
                    >
                      <CheckCircle className="w-4 h-4 mr-1" />
                      Approve
                    </button>
                    <button
                      onClick={() => handleModerateTerm(term.id, 'reject')}
                      className="btn-secondary text-sm"
                    >
                      <XCircle className="w-4 h-4 mr-1" />
                      Reject
                    </button>
                  </div>
                ) : null}
              </div>
            </div>
          ))}
        </div>

        {filteredTerms.length === 0 && (
          <div className="card text-center py-12">
            <Shield className="w-12 h-12 text-gray-400 mx-auto mb-4" />
            <h3 className="text-lg font-medium text-gray-900 mb-2">No terms found</h3>
            <p className="text-gray-600">
              {filter === 'all' 
                ? 'No terms available for moderation.' 
                : `No ${filter} terms found.`
              }
            </p>
          </div>
        )}

        {/* Error Display */}
        {error && (
          <div className="mt-8 bg-red-50 border border-red-200 rounded-md p-4">
            <div className="flex">
              <XCircle className="w-5 h-5 text-red-400 mr-3" />
              <div>
                <h3 className="text-sm font-medium text-red-800">Error</h3>
                <div className="mt-2 text-sm text-red-700">{error}</div>
              </div>
            </div>
          </div>
        )}
      </div>
    </div>
  );
}
