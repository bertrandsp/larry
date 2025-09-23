import { useState, useEffect } from 'react';
import Head from 'next/head';
import Link from 'next/link';
import { 
  BarChart3, 
  Settings, 
  Users, 
  FileText, 
  Zap, 
  Shield,
  TrendingUp,
  AlertTriangle
} from 'lucide-react';

interface SystemHealth {
  status: string;
  timestamp: string;
  metrics: {
    totalUsers: number;
    quotaExceededUsers: number;
    totalRequests: number;
    averageRequestsPerUser: number;
    tierDistribution: Record<string, number>;
  };
  alerts: Array<{ level: string; message: string }>;
}

interface Analytics {
  totalUsers: number;
  quotaExceededUsers: number;
  tierDistribution: Record<string, number>;
  systemHealth: {
    totalRequests: number;
    averageRequestsPerUser: number;
  };
}

export default function AdminDashboard() {
  const [systemHealth, setSystemHealth] = useState<SystemHealth | null>(null);
  const [analytics, setAnalytics] = useState<Analytics | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    const fetchData = async () => {
      try {
        setLoading(true);
        
        // Fetch system health
        const healthResponse = await fetch(`${process.env.NEXT_PUBLIC_API_URL}/admin/health`, {
          headers: {
            'x-admin-key': 'admin-key-here' // You'll need to set this properly
          }
        });
        
        if (healthResponse.ok) {
          const healthData = await healthResponse.json();
          setSystemHealth(healthData);
        }

        // Fetch analytics
        const analyticsResponse = await fetch(`${process.env.NEXT_PUBLIC_API_URL}/admin/analytics`, {
          headers: {
            'x-admin-key': 'admin-key-here' // You'll need to set this properly
          }
        });
        
        if (analyticsResponse.ok) {
          const analyticsData = await analyticsResponse.json();
          setAnalytics(analyticsData);
        }
        
      } catch (err) {
        setError(err instanceof Error ? err.message : 'Failed to fetch data');
      } finally {
        setLoading(false);
      }
    };

    fetchData();
  }, []);

  const navigationItems = [
    {
      name: 'Content Generation',
      href: '/generate',
      icon: Zap,
      description: 'Generate vocabulary terms and facts',
      color: 'bg-blue-500'
    },
    {
      name: 'Moderation',
      href: '/moderation',
      icon: Shield,
      description: 'Review and moderate flagged content',
      color: 'bg-yellow-500'
    },
    {
      name: 'Analytics',
      href: '/analytics',
      icon: BarChart3,
      description: 'View system metrics and usage',
      color: 'bg-green-500'
    },
    {
      name: 'User Management',
      href: '/users',
      icon: Users,
      description: 'Manage users and quotas',
      color: 'bg-purple-500'
    },
    {
      name: 'Terms Management',
      href: '/terms',
      icon: FileText,
      description: 'Browse and manage all terms',
      color: 'bg-indigo-500'
    },
    {
      name: 'Settings',
      href: '/settings',
      icon: Settings,
      description: 'System configuration',
      color: 'bg-gray-500'
    }
  ];

  if (loading) {
    return (
      <div className="min-h-screen bg-gray-50 flex items-center justify-center">
        <div className="text-center">
          <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600 mx-auto"></div>
          <p className="mt-4 text-gray-600">Loading dashboard...</p>
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-gray-50">
      <Head>
        <title>Larry Admin Dashboard</title>
        <meta name="description" content="Admin dashboard for Larry vocabulary app" />
        <link rel="icon" href="/favicon.ico" />
      </Head>

      <div className="max-w-7xl mx-auto py-8 px-4 sm:px-6 lg:px-8">
        {/* Header */}
        <div className="mb-8">
          <h1 className="text-4xl font-bold text-gray-900 mb-2">
            Larry Admin Dashboard
          </h1>
          <p className="text-lg text-gray-600">
            Manage your vocabulary generation system
          </p>
        </div>

        {/* System Status */}
        {systemHealth && (
          <div className="mb-8">
            <div className={`card ${systemHealth.status === 'healthy' ? 'border-green-200' : 'border-red-200'}`}>
              <div className="flex items-center justify-between">
                <div className="flex items-center">
                  <div className={`w-3 h-3 rounded-full mr-3 ${systemHealth.status === 'healthy' ? 'bg-green-500' : 'bg-red-500'}`}></div>
                  <h2 className="text-xl font-semibold text-gray-900">
                    System Status: {systemHealth.status}
                  </h2>
                </div>
                <span className="text-sm text-gray-500">
                  Last updated: {new Date(systemHealth.timestamp).toLocaleString()}
                </span>
              </div>
              
              {systemHealth.alerts.length > 0 && (
                <div className="mt-4">
                  {systemHealth.alerts.map((alert, index) => (
                    <div key={index} className={`p-3 rounded-md mb-2 ${
                      alert.level === 'warning' ? 'bg-yellow-50 border border-yellow-200' : 'bg-blue-50 border border-blue-200'
                    }`}>
                      <div className="flex items-center">
                        <AlertTriangle className="w-4 h-4 text-yellow-600 mr-2" />
                        <span className="text-sm text-gray-700">{alert.message}</span>
                      </div>
                    </div>
                  ))}
                </div>
              )}
            </div>
          </div>
        )}

        {/* Quick Stats */}
        {analytics && (
          <div className="grid grid-cols-1 md:grid-cols-4 gap-6 mb-8">
            <div className="card">
              <div className="flex items-center">
                <Users className="w-8 h-8 text-blue-600 mr-3" />
                <div>
                  <p className="text-sm text-gray-600">Total Users</p>
                  <p className="text-2xl font-bold text-gray-900">{analytics.totalUsers}</p>
                </div>
              </div>
            </div>
            
            <div className="card">
              <div className="flex items-center">
                <AlertTriangle className="w-8 h-8 text-yellow-600 mr-3" />
                <div>
                  <p className="text-sm text-gray-600">Quota Exceeded</p>
                  <p className="text-2xl font-bold text-gray-900">{analytics.quotaExceededUsers}</p>
                </div>
              </div>
            </div>
            
            <div className="card">
              <div className="flex items-center">
                <TrendingUp className="w-8 h-8 text-green-600 mr-3" />
                <div>
                  <p className="text-sm text-gray-600">Total Requests</p>
                  <p className="text-2xl font-bold text-gray-900">{analytics.systemHealth.totalRequests}</p>
                </div>
              </div>
            </div>
            
            <div className="card">
              <div className="flex items-center">
                <BarChart3 className="w-8 h-8 text-purple-600 mr-3" />
                <div>
                  <p className="text-sm text-gray-600">Avg Requests/User</p>
                  <p className="text-2xl font-bold text-gray-900">{analytics.systemHealth.averageRequestsPerUser.toFixed(1)}</p>
                </div>
              </div>
            </div>
          </div>
        )}

        {/* Navigation Grid */}
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
          {navigationItems.map((item) => {
            const Icon = item.icon;
            return (
              <Link key={item.name} href={item.href}>
                <div className="card hover:shadow-lg transition-shadow cursor-pointer">
                  <div className="flex items-center mb-4">
                    <div className={`p-3 rounded-lg ${item.color} mr-4`}>
                      <Icon className="w-6 h-6 text-white" />
                    </div>
                    <h3 className="text-lg font-semibold text-gray-900">{item.name}</h3>
                  </div>
                  <p className="text-gray-600">{item.description}</p>
                </div>
              </Link>
            );
          })}
        </div>

        {/* Error Display */}
        {error && (
          <div className="mt-8 bg-red-50 border border-red-200 rounded-md p-4">
            <div className="flex">
              <AlertTriangle className="w-5 h-5 text-red-400 mr-3" />
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