import React, { useState, useEffect } from 'react';
import FlaggedTermsList from '../components/FlaggedTermsList';

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

interface ModerationStats {
  totalTerms: number;
  pendingTerms: number;
  approvedTerms: number;
  rejectedTerms: number;
  lowConfidenceTerms: number;
  adminUpdatedTerms: number;
  approvalRate: string;
}

const AdminDashboard: React.FC = () => {
  const [terms, setTerms] = useState<Term[]>([]);
  const [stats, setStats] = useState<ModerationStats | null>(null);
  const [metricsSummary, setMetricsSummary] = useState<any>(null);
  const [flaggedTerms, setFlaggedTerms] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [activeTab, setActiveTab] = useState<'flagged' | 'all' | 'stats' | 'metrics'>('flagged');
  const [pagination, setPagination] = useState({
    page: 1,
    limit: 50,
    total: 0,
    pages: 0
  });

  // Admin token - in production, this would come from login
  const adminToken = 'admin-secret-key'; // This should match ADMIN_SECRET in backend

  const fetchFlaggedTerms = async (page = 1) => {
    try {
      setLoading(true);
      const response = await fetch(`/api/admin/terms/flagged?page=${page}&limit=50`, {
        headers: {
          'Authorization': `Bearer ${adminToken}`,
          'Content-Type': 'application/json'
        }
      });

      if (!response.ok) {
        throw new Error(`HTTP error! status: ${response.status}`);
      }

      const data = await response.json();
      setTerms(data.terms || []);
      setPagination(data.pagination || { page: 1, limit: 50, total: 0, pages: 0 });
    } catch (err: any) {
      setError(err.message);
      console.error('Error fetching flagged terms:', err);
    } finally {
      setLoading(false);
    }
  };

  const fetchAllTerms = async (page = 1) => {
    try {
      setLoading(true);
      const response = await fetch(`/api/admin/terms/all?page=${page}&limit=50`, {
        headers: {
          'Authorization': `Bearer ${adminToken}`,
          'Content-Type': 'application/json'
        }
      });

      if (!response.ok) {
        throw new Error(`HTTP error! status: ${response.status}`);
      }

      const data = await response.json();
      setTerms(data.terms || []);
      setPagination(data.pagination || { page: 1, limit: 50, total: 0, pages: 0 });
    } catch (err: any) {
      setError(err.message);
      console.error('Error fetching all terms:', err);
    } finally {
      setLoading(false);
    }
  };

  const fetchStats = async () => {
    try {
      const response = await fetch('/api/admin/moderation/stats', {
        headers: {
          'Authorization': `Bearer ${adminToken}`,
          'Content-Type': 'application/json'
        }
      });

      if (!response.ok) {
        throw new Error(`HTTP error! status: ${response.status}`);
      }

      const data = await response.json();
      setStats(data);
    } catch (err: any) {
      console.error('Error fetching stats:', err);
    }
  };

  const fetchMetricsSummary = async () => {
    try {
      const response = await fetch('/api/admin/metrics/summary?days=7', {
        headers: {
          'Authorization': `Bearer ${adminToken}`,
          'Content-Type': 'application/json'
        }
      });

      if (!response.ok) {
        throw new Error(`HTTP error! status: ${response.status}`);
      }

      const data = await response.json();
      setMetricsSummary(data);
    } catch (err: any) {
      console.error('Error fetching metrics summary:', err);
    }
  };

  const fetchMostFlaggedTerms = async () => {
    try {
      const response = await fetch('/api/admin/metrics/flagged-terms?limit=10', {
        headers: {
          'Authorization': `Bearer ${adminToken}`,
          'Content-Type': 'application/json'
        }
      });

      if (!response.ok) {
        throw new Error(`HTTP error! status: ${response.status}`);
      }

      const data = await response.json();
      setFlaggedTerms(data);
    } catch (err: any) {
      console.error('Error fetching flagged terms:', err);
    }
  };

  const handleModerate = async (id: string, status: string, definition?: string, note?: string) => {
    try {
      const response = await fetch(`/api/admin/terms/${id}/moderate`, {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${adminToken}`,
          'Content-Type': 'application/json'
        },
        body: JSON.stringify({
          status,
          definition,
          note
        })
      });

      if (!response.ok) {
        throw new Error(`HTTP error! status: ${response.status}`);
      }

      const result = await response.json();
      console.log('Moderation result:', result);

      // Remove the moderated term from the list
      setTerms(prev => prev.filter(term => term.id !== id));
      
      // Refresh stats
      await fetchStats();
      
      // Show success message
      alert(`Term ${status} successfully!`);
    } catch (err: any) {
      console.error('Error moderating term:', err);
      alert(`Error moderating term: ${err.message}`);
    }
  };

  useEffect(() => {
    if (activeTab === 'flagged') {
      fetchFlaggedTerms();
    } else if (activeTab === 'all') {
      fetchAllTerms();
    } else if (activeTab === 'stats') {
      fetchStats();
    } else if (activeTab === 'metrics') {
      fetchMetricsSummary();
      fetchMostFlaggedTerms();
    }
  }, [activeTab]);

  useEffect(() => {
    // Fetch stats on initial load
    fetchStats();
  }, []);

  const handlePageChange = (newPage: number) => {
    if (activeTab === 'flagged') {
      fetchFlaggedTerms(newPage);
    } else if (activeTab === 'all') {
      fetchAllTerms(newPage);
    }
  };

  if (error) {
    return (
      <div className="min-h-screen bg-gray-50 flex items-center justify-center">
        <div className="text-center">
          <div className="text-red-500 text-xl mb-4">❌ Error</div>
          <p className="text-gray-600 mb-4">{error}</p>
          <button
            onClick={() => window.location.reload()}
            className="px-4 py-2 bg-blue-500 text-white rounded hover:bg-blue-600"
          >
            Retry
          </button>
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-gray-50">
      {/* Header */}
      <div className="bg-white shadow">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="flex justify-between items-center py-6">
            <div>
              <h1 className="text-3xl font-bold text-gray-900">Admin Dashboard</h1>
              <p className="text-gray-600 mt-1">Review and moderate vocabulary terms</p>
            </div>
            <div className="text-sm text-gray-500">
              Admin Dashboard
            </div>
          </div>
        </div>
      </div>

      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        {/* Stats Cards */}
        {stats && (
          <div className="grid grid-cols-1 md:grid-cols-4 gap-6 mb-8">
            <div className="bg-white rounded-lg shadow p-6">
              <div className="text-2xl font-bold text-gray-900">{stats.totalTerms}</div>
              <div className="text-sm text-gray-600">Total Terms</div>
            </div>
            <div className="bg-white rounded-lg shadow p-6">
              <div className="text-2xl font-bold text-yellow-600">{stats.pendingTerms}</div>
              <div className="text-sm text-gray-600">Pending Review</div>
            </div>
            <div className="bg-white rounded-lg shadow p-6">
              <div className="text-2xl font-bold text-green-600">{stats.approvedTerms}</div>
              <div className="text-sm text-gray-600">Approved</div>
            </div>
            <div className="bg-white rounded-lg shadow p-6">
              <div className="text-2xl font-bold text-blue-600">{stats.approvalRate}%</div>
              <div className="text-sm text-gray-600">Approval Rate</div>
            </div>
          </div>
        )}

        {/* Tabs */}
        <div className="bg-white rounded-lg shadow mb-6">
          <div className="border-b border-gray-200">
            <nav className="-mb-px flex space-x-8 px-6">
              <button
                onClick={() => setActiveTab('flagged')}
                className={`py-4 px-1 border-b-2 font-medium text-sm ${
                  activeTab === 'flagged'
                    ? 'border-blue-500 text-blue-600'
                    : 'border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300'
                }`}
              >
                🚩 Flagged Terms ({stats?.pendingTerms || 0})
              </button>
              <button
                onClick={() => setActiveTab('all')}
                className={`py-4 px-1 border-b-2 font-medium text-sm ${
                  activeTab === 'all'
                    ? 'border-blue-500 text-blue-600'
                    : 'border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300'
                }`}
              >
                📚 All Terms ({stats?.totalTerms || 0})
              </button>
              <button
                onClick={() => setActiveTab('stats')}
                className={`py-4 px-1 border-b-2 font-medium text-sm ${
                  activeTab === 'stats'
                    ? 'border-blue-500 text-blue-600'
                    : 'border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300'
                }`}
              >
                📊 Statistics
              </button>
              <button
                onClick={() => setActiveTab('metrics')}
                className={`py-4 px-1 border-b-2 font-medium text-sm ${
                  activeTab === 'metrics'
                    ? 'border-blue-500 text-blue-600'
                    : 'border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300'
                }`}
              >
                📈 Metrics
              </button>
            </nav>
          </div>

          <div className="p-6">
            {activeTab === 'metrics' ? (
              <div className="space-y-6">
                <h2 className="text-xl font-semibold text-gray-900">System Metrics (Last 7 Days)</h2>
                
                {metricsSummary ? (
                  <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                    <div className="bg-white rounded-lg shadow p-6">
                      <h3 className="text-lg font-medium text-gray-900 mb-4">OpenAI Usage</h3>
                      <div className="space-y-2">
                        {metricsSummary.openAiUsage?.length > 0 ? (
                          metricsSummary.openAiUsage.map((usage: any, index: number) => (
                            <div key={index} className="flex justify-between">
                              <span className="text-gray-600">Requests:</span>
                              <span className="font-semibold">{usage._count.metadata}</span>
                            </div>
                          ))
                        ) : (
                          <p className="text-gray-500">No OpenAI usage data available</p>
                        )}
                      </div>
                    </div>

                    <div className="bg-white rounded-lg shadow p-6">
                      <h3 className="text-lg font-medium text-gray-900 mb-4">Fallback Reasons</h3>
                      <div className="space-y-2">
                        {metricsSummary.fallbackReasons?.length > 0 ? (
                          metricsSummary.fallbackReasons.map((fallback: any, index: number) => (
                            <div key={index} className="flex justify-between">
                              <span className="text-gray-600 text-sm">
                                {fallback.metadata?.reason || 'Unknown'}
                              </span>
                              <span className="font-semibold">{fallback._count.metadata}</span>
                            </div>
                          ))
                        ) : (
                          <p className="text-gray-500">No fallback data available</p>
                        )}
                      </div>
                    </div>

                    <div className="bg-white rounded-lg shadow p-6">
                      <h3 className="text-lg font-medium text-gray-900 mb-4">Moderation Actions</h3>
                      <div className="space-y-2">
                        {metricsSummary.moderationActions?.length > 0 ? (
                          metricsSummary.moderationActions.map((action: any, index: number) => (
                            <div key={index} className="flex justify-between">
                              <span className="text-gray-600">
                                {action.metadata?.action || 'Unknown'}
                              </span>
                              <span className="font-semibold">{action._count.metadata}</span>
                            </div>
                          ))
                        ) : (
                          <p className="text-gray-500">No moderation data available</p>
                        )}
                      </div>
                    </div>

                    <div className="bg-white rounded-lg shadow p-6">
                      <h3 className="text-lg font-medium text-gray-900 mb-4">Pipeline Outcomes</h3>
                      <div className="space-y-2">
                        {metricsSummary.pipelineOutcomes?.length > 0 ? (
                          metricsSummary.pipelineOutcomes.map((outcome: any, index: number) => (
                            <div key={index} className="flex justify-between">
                              <span className="text-gray-600">
                                {outcome.metadata?.status || 'Unknown'}
                              </span>
                              <span className="font-semibold">{outcome._count.metadata}</span>
                            </div>
                          ))
                        ) : (
                          <p className="text-gray-500">No pipeline data available</p>
                        )}
                      </div>
                    </div>
                  </div>
                ) : (
                  <div className="text-center py-8">
                    <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-blue-500 mx-auto"></div>
                    <p className="text-gray-500 mt-2">Loading metrics...</p>
                  </div>
                )}

                <div className="bg-white rounded-lg shadow p-6">
                  <h3 className="text-lg font-medium text-gray-900 mb-4">Most Flagged Terms</h3>
                  {flaggedTerms.length > 0 ? (
                    <div className="space-y-3">
                      {flaggedTerms.map((term, index) => (
                        <div key={index} className="flex justify-between items-center p-3 bg-gray-50 rounded">
                          <div>
                            <div className="font-medium">{term.term}</div>
                            <div className="text-sm text-gray-600">{term.topicName}</div>
                          </div>
                          <div className="text-right">
                            <div className="font-semibold text-red-600">{term.flagCount} flags</div>
                            <div className="text-xs text-gray-500">
                              {term.metadata?.action || 'Unknown reason'}
                            </div>
                          </div>
                        </div>
                      ))}
                    </div>
                  ) : (
                    <p className="text-gray-500">No flagged terms data available</p>
                  )}
                </div>
              </div>
            ) : activeTab === 'stats' ? (
              <div className="space-y-6">
                <h2 className="text-xl font-semibold text-gray-900">Moderation Statistics</h2>
                {stats ? (
                  <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                    <div className="space-y-4">
                      <div className="flex justify-between">
                        <span className="text-gray-600">Total Terms:</span>
                        <span className="font-semibold">{stats.totalTerms}</span>
                      </div>
                      <div className="flex justify-between">
                        <span className="text-gray-600">Pending Review:</span>
                        <span className="font-semibold text-yellow-600">{stats.pendingTerms}</span>
                      </div>
                      <div className="flex justify-between">
                        <span className="text-gray-600">Approved:</span>
                        <span className="font-semibold text-green-600">{stats.approvedTerms}</span>
                      </div>
                      <div className="flex justify-between">
                        <span className="text-gray-600">Rejected:</span>
                        <span className="font-semibold text-red-600">{stats.rejectedTerms}</span>
                      </div>
                    </div>
                    <div className="space-y-4">
                      <div className="flex justify-between">
                        <span className="text-gray-600">Low Confidence:</span>
                        <span className="font-semibold text-orange-600">{stats.lowConfidenceTerms}</span>
                      </div>
                      <div className="flex justify-between">
                        <span className="text-gray-600">Admin Updated:</span>
                        <span className="font-semibold text-blue-600">{stats.adminUpdatedTerms}</span>
                      </div>
                      <div className="flex justify-between">
                        <span className="text-gray-600">Approval Rate:</span>
                        <span className="font-semibold text-green-600">{stats.approvalRate}%</span>
                      </div>
                    </div>
                  </div>
                ) : (
                  <div className="text-center py-8">
                    <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-blue-500 mx-auto"></div>
                    <p className="text-gray-500 mt-2">Loading statistics...</p>
                  </div>
                )}
              </div>
            ) : (
              <>
                <div className="flex justify-between items-center mb-6">
                  <h2 className="text-xl font-semibold text-gray-900">
                    {activeTab === 'flagged' ? 'Flagged Terms for Review' : 'All Terms'}
                  </h2>
                  <button
                    onClick={() => activeTab === 'flagged' ? fetchFlaggedTerms() : fetchAllTerms()}
                    className="px-4 py-2 bg-blue-500 text-white rounded hover:bg-blue-600"
                  >
                    🔄 Refresh
                  </button>
                </div>

                <FlaggedTermsList
                  terms={terms}
                  onModerate={handleModerate}
                  loading={loading}
                />

                {/* Pagination */}
                {pagination.pages > 1 && (
                  <div className="flex justify-center items-center space-x-2 mt-8">
                    <button
                      onClick={() => handlePageChange(pagination.page - 1)}
                      disabled={pagination.page <= 1}
                      className="px-3 py-2 bg-gray-200 text-gray-700 rounded hover:bg-gray-300 disabled:opacity-50 disabled:cursor-not-allowed"
                    >
                      Previous
                    </button>
                    <span className="px-4 py-2 text-gray-700">
                      Page {pagination.page} of {pagination.pages}
                    </span>
                    <button
                      onClick={() => handlePageChange(pagination.page + 1)}
                      disabled={pagination.page >= pagination.pages}
                      className="px-3 py-2 bg-gray-200 text-gray-700 rounded hover:bg-gray-300 disabled:opacity-50 disabled:cursor-not-allowed"
                    >
                      Next
                    </button>
                  </div>
                )}
              </>
            )}
          </div>
        </div>
      </div>
    </div>
  );
};

export default AdminDashboard;
