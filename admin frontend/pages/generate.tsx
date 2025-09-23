import { useState, useEffect } from 'react';
import Head from 'next/head';
import Link from 'next/link';
import { ArrowLeft, Zap, Settings, Play, Clock, CheckCircle, XCircle } from 'lucide-react';

interface Term {
  id: string;
  term: string;
  definition: string;
  example: string;
  topic: string;
  confidence: number;
  source: string;
  complexity: string;
  category: string;
}

interface Fact {
  id: string;
  fact: string;
  topic: string;
  confidence: number;
  source: string;
}

interface GenerationResult {
  success: boolean;
  data: {
    topic: string;
    pipeline: string;
    terms: Term[];
    facts: Fact[];
    stats: {
      termsGenerated: number;
      factsGenerated: number;
      duplicatesRemoved: number;
      processingTime: number;
    };
  };
  timestamp: string;
}

interface Pipeline {
  id: string;
  name: string;
  description: string;
  advantages: string[];
  disadvantages: string[];
  bestFor: string[];
}

export default function ContentGeneration() {
  const [topic, setTopic] = useState('artificial intelligence');
  const [pipeline, setPipeline] = useState('source-first');
  const [numTerms, setNumTerms] = useState(5);
  const [definitionStyle, setDefinitionStyle] = useState('formal');
  const [termSelectionLevel, setTermSelectionLevel] = useState('intermediate');
  const [definitionComplexityLevel, setDefinitionComplexityLevel] = useState('intermediate');
  const [loading, setLoading] = useState(false);
  const [result, setResult] = useState<GenerationResult | null>(null);
  const [error, setError] = useState<string | null>(null);
  const [pipelines, setPipelines] = useState<Pipeline[]>([]);

  useEffect(() => {
    const fetchPipelines = async () => {
      try {
        const response = await fetch(`${process.env.NEXT_PUBLIC_API_URL}/generate/pipelines`);
        if (response.ok) {
          const data = await response.json();
          setPipelines(data.data.pipelines);
        }
      } catch (err) {
        console.error('Failed to fetch pipelines:', err);
      }
    };

    fetchPipelines();
  }, []);

  const handleGenerate = async () => {
    setLoading(true);
    setError(null);
    setResult(null);

    try {
      const response = await fetch(`${process.env.NEXT_PUBLIC_API_URL}/generate/test`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          topic,
          pipeline,
          numTerms,
          definitionStyle,
          termSelectionLevel,
          definitionComplexityLevel,
        }),
      });

      if (!response.ok) {
        throw new Error(`HTTP error! status: ${response.status}`);
      }

      const data = await response.json();
      setResult(data);
    } catch (err) {
      setError(err instanceof Error ? err.message : 'An error occurred');
    } finally {
      setLoading(false);
    }
  };

  const selectedPipeline = pipelines.find(p => p.id === pipeline);

  return (
    <div className="min-h-screen bg-gray-50">
      <Head>
        <title>Content Generation - Larry Admin</title>
        <meta name="description" content="Generate vocabulary terms and facts" />
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
            Content Generation
          </h1>
          <p className="text-lg text-gray-600">
            Generate vocabulary terms and facts using AI
          </p>
        </div>

        <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
          {/* Parameters Panel */}
          <div className="lg:col-span-1">
            <div className="card sticky top-8">
              <h2 className="text-2xl font-semibold text-gray-900 mb-6 flex items-center">
                <Settings className="w-6 h-6 mr-2" />
                Parameters
              </h2>
              
              <div className="space-y-6">
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">
                    Topic
                  </label>
                  <input
                    type="text"
                    value={topic}
                    onChange={(e) => setTopic(e.target.value)}
                    className="input-field"
                    placeholder="Enter topic..."
                  />
                </div>

                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">
                    Pipeline Strategy
                  </label>
                  <select
                    value={pipeline}
                    onChange={(e) => setPipeline(e.target.value)}
                    className="input-field"
                  >
                    <option value="source-first">Source-First</option>
                    <option value="openai-first">OpenAI-First</option>
                  </select>
                </div>

                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">
                    Number of Terms
                  </label>
                  <input
                    type="number"
                    value={numTerms}
                    onChange={(e) => setNumTerms(parseInt(e.target.value))}
                    min="1"
                    max="50"
                    className="input-field"
                  />
                </div>

                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">
                    Definition Style
                  </label>
                  <select
                    value={definitionStyle}
                    onChange={(e) => setDefinitionStyle(e.target.value)}
                    className="input-field"
                  >
                    <option value="casual">Casual</option>
                    <option value="formal">Formal</option>
                    <option value="technical">Technical</option>
                    <option value="academic">Academic</option>
                  </select>
                </div>

                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">
                    Term Selection Level
                  </label>
                  <select
                    value={termSelectionLevel}
                    onChange={(e) => setTermSelectionLevel(e.target.value)}
                    className="input-field"
                  >
                    <option value="beginner">Beginner</option>
                    <option value="intermediate">Intermediate</option>
                    <option value="advanced">Advanced</option>
                  </select>
                </div>

                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">
                    Definition Complexity
                  </label>
                  <select
                    value={definitionComplexityLevel}
                    onChange={(e) => setDefinitionComplexityLevel(e.target.value)}
                    className="input-field"
                  >
                    <option value="beginner">Beginner</option>
                    <option value="intermediate">Intermediate</option>
                    <option value="advanced">Advanced</option>
                  </select>
                </div>

                <button
                  onClick={handleGenerate}
                  disabled={loading}
                  className="w-full btn-primary flex items-center justify-center"
                >
                  {loading ? (
                    <>
                      <div className="animate-spin rounded-full h-4 w-4 border-b-2 border-white mr-2"></div>
                      Generating...
                    </>
                  ) : (
                    <>
                      <Play className="w-4 h-4 mr-2" />
                      Generate Content
                    </>
                  )}
                </button>
              </div>
            </div>
          </div>

          {/* Results Panel */}
          <div className="lg:col-span-2">
            {/* Pipeline Information */}
            {selectedPipeline && (
              <div className="card mb-6">
                <h3 className="text-lg font-semibold text-gray-900 mb-3 flex items-center">
                  <Zap className="w-5 h-5 mr-2" />
                  {selectedPipeline.name}
                </h3>
                <p className="text-gray-600 mb-4">{selectedPipeline.description}</p>
                
                <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                  <div>
                    <h4 className="font-medium text-green-800 mb-2">Advantages:</h4>
                    <ul className="text-sm text-green-700 space-y-1">
                      {selectedPipeline.advantages.map((advantage, index) => (
                        <li key={index}>• {advantage}</li>
                      ))}
                    </ul>
                  </div>
                  <div>
                    <h4 className="font-medium text-red-800 mb-2">Best For:</h4>
                    <ul className="text-sm text-red-700 space-y-1">
                      {selectedPipeline.bestFor.map((use, index) => (
                        <li key={index}>• {use}</li>
                      ))}
                    </ul>
                  </div>
                </div>
              </div>
            )}

            {/* Error Display */}
            {error && (
              <div className="card mb-6 border-red-200 bg-red-50">
                <div className="flex items-center">
                  <XCircle className="w-5 h-5 text-red-500 mr-3" />
                  <div>
                    <h3 className="text-sm font-medium text-red-800">Error</h3>
                    <div className="mt-2 text-sm text-red-700">{error}</div>
                  </div>
                </div>
              </div>
            )}

            {/* Results */}
            {result && (
              <div className="space-y-6">
                {/* Stats */}
                <div className="card">
                  <h3 className="text-lg font-semibold text-gray-900 mb-4 flex items-center">
                    <CheckCircle className="w-5 h-5 mr-2 text-green-500" />
                    Generation Results
                  </h3>
                  
                  <div className="grid grid-cols-2 md:grid-cols-4 gap-4 mb-4">
                    <div className="bg-blue-50 p-4 rounded-lg">
                      <div className="text-2xl font-bold text-blue-600">{result.data.stats.termsGenerated}</div>
                      <div className="text-sm text-blue-800">Terms Generated</div>
                    </div>
                    <div className="bg-green-50 p-4 rounded-lg">
                      <div className="text-2xl font-bold text-green-600">{result.data.stats.factsGenerated}</div>
                      <div className="text-sm text-green-800">Facts Generated</div>
                    </div>
                    <div className="bg-yellow-50 p-4 rounded-lg">
                      <div className="text-2xl font-bold text-yellow-600">{result.data.stats.duplicatesRemoved}</div>
                      <div className="text-sm text-yellow-800">Duplicates Removed</div>
                    </div>
                    <div className="bg-purple-50 p-4 rounded-lg">
                      <div className="text-2xl font-bold text-purple-600">{result.data.stats.processingTime}ms</div>
                      <div className="text-sm text-purple-800">Processing Time</div>
                    </div>
                  </div>

                  <div className="text-sm text-gray-600">
                    <p><strong>Topic:</strong> {result.data.topic}</p>
                    <p><strong>Pipeline:</strong> {result.data.pipeline}</p>
                    <p><strong>Generated:</strong> {new Date(result.timestamp).toLocaleString()}</p>
                  </div>
                </div>

                {/* Generated Terms */}
                <div className="card">
                  <h3 className="text-lg font-semibold text-gray-900 mb-4">Generated Terms</h3>
                  <div className="space-y-4">
                    {result.data.terms.map((term, index) => (
                      <div key={term.id || index} className="border border-gray-200 rounded-lg p-4">
                        <div className="flex justify-between items-start mb-2">
                          <h4 className="text-lg font-semibold text-gray-900">{term.term}</h4>
                          <div className="flex items-center space-x-2">
                            <span className="text-xs bg-gray-100 text-gray-600 px-2 py-1 rounded">
                              {term.complexity}
                            </span>
                            <span className="text-xs bg-blue-100 text-blue-600 px-2 py-1 rounded">
                              {term.category}
                            </span>
                            <span className="text-sm text-gray-500">
                              {term.confidence}% confidence
                            </span>
                          </div>
                        </div>
                        <p className="text-gray-700 mb-2">{term.definition}</p>
                        <p className="text-sm text-gray-600 italic">"{term.example}"</p>
                        <div className="mt-2 flex justify-between text-xs text-gray-500">
                          <span>Topic: {term.topic}</span>
                          <span>Source: {term.source}</span>
                        </div>
                      </div>
                    ))}
                  </div>
                </div>

                {/* Generated Facts */}
                {result.data.facts.length > 0 && (
                  <div className="card">
                    <h3 className="text-lg font-semibold text-gray-900 mb-4">Generated Facts</h3>
                    <div className="space-y-3">
                      {result.data.facts.map((fact, index) => (
                        <div key={fact.id || index} className="border border-gray-200 rounded-lg p-4">
                          <p className="text-gray-700 mb-2">{fact.fact}</p>
                          <div className="flex justify-between text-xs text-gray-500">
                            <span>Topic: {fact.topic}</span>
                            <span>Confidence: {fact.confidence}%</span>
                            <span>Source: {fact.source}</span>
                          </div>
                        </div>
                      ))}
                    </div>
                  </div>
                )}
              </div>
            )}
          </div>
        </div>
      </div>
    </div>
  );
}
