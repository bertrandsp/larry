import React, { useState, useEffect } from 'react';
import axios from 'axios';

interface VocabularyParams {
  topic: string;
  openAiFirst: boolean;
  numTerms: number;
  definitionStyle: 'casual' | 'formal' | 'technical' | 'academic';
  sentenceRange: string;
  numExamples: number;
  numFacts: number;
  termSelectionLevel: 'beginner' | 'intermediate' | 'advanced';
  definitionComplexityLevel: 'beginner' | 'intermediate' | 'advanced';
  domainContext: string;
  language: string;
  useAnalogy: boolean;
  includeSynonyms: boolean;
  includeAntonyms: boolean;
  includeRelatedTerms: boolean;
  includeEtymology: boolean;
  highlightRootWords: boolean;
}

interface GeneratedTerm {
  term: string;
  definition: string;
  examples: string[];
  analogy?: string;
  synonyms?: string[];
  antonyms?: string[];
  relatedTerms?: string[];
  etymology?: string;
  source?: string;
  confidenceScore?: number;
  verified?: boolean;
  gptGenerated?: boolean;
}

interface GenerationResult {
  success: boolean;
  data: {
    topic: string;
    pipeline: 'source-first' | 'openai-first';
    terms: GeneratedTerm[];
    facts: string[];
    stats: {
      termsGenerated: number;
      factsGenerated: number;
      duplicatesRemoved: number;
      lowConfidenceTerms: number;
      processingTime: number;
    };
    sourceStats?: any;
    enrichmentStats?: any;
  };
  jobId?: string;
  timestamp: string;
}

interface PipelineInfo {
  id: string;
  name: string;
  description: string;
  advantages: string[];
  disadvantages: string[];
  bestFor: string[];
}

const VocabPlayground: React.FC = () => {
  const [params, setParams] = useState<VocabularyParams>({
    topic: 'anime',
    openAiFirst: false,
    numTerms: 20,
    definitionStyle: 'casual',
    sentenceRange: '2-4',
    numExamples: 2,
    numFacts: 5,
    termSelectionLevel: 'intermediate',
    definitionComplexityLevel: 'intermediate',
    domainContext: 'general',
    language: 'English',
    useAnalogy: true,
    includeSynonyms: true,
    includeAntonyms: true,
    includeRelatedTerms: true,
    includeEtymology: true,
    highlightRootWords: true,
  });

  const [result, setResult] = useState<GenerationResult | null>(null);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [pipelines, setPipelines] = useState<PipelineInfo[]>([]);
  const [activeTab, setActiveTab] = useState<'params' | 'results' | 'pipelines'>('params');

  // Load pipeline information on component mount
  useEffect(() => {
    loadPipelineInfo();
  }, []);

  const loadPipelineInfo = async () => {
    try {
      const response = await axios.get('http://localhost:4001/generate/pipelines');
      setPipelines(response.data.pipelines || []);
    } catch (error) {
      console.error('Error loading pipeline info:', error);
      setPipelines(['openai-first', 'source-first']); // fallback
    }
  };

  const handleGenerate = async () => {
    setLoading(true);
    setError(null);
    setResult(null);

    try {
      const response = await axios.post('http://localhost:4001/generate', params);
      setResult(response.data);
      setActiveTab('results');
    } catch (error: any) {
      setError(error.response?.data?.error || error.message || 'Generation failed');
    } finally {
      setLoading(false);
    }
  };

  const handleQuickGenerate = async () => {
    setLoading(true);
    setError(null);
    setResult(null);

    try {
      const response = await axios.post('http://localhost:4001/generate/quick', {
        topic: params.topic,
        numTerms: params.numTerms,
        openAiFirst: params.openAiFirst
      });
      setResult(response.data);
      setActiveTab('results');
    } catch (error: any) {
      setError(error.response?.data?.error || error.message || 'Quick generation failed');
    } finally {
      setLoading(false);
    }
  };

  const handleTestGenerate = async () => {
    setLoading(true);
    setError(null);
    setResult(null);

    try {
      const response = await axios.post('http://localhost:4001/generate/test', {
        topic: params.topic,
        pipeline: params.openAiFirst ? 'openai-first' : 'source-first',
        termSelectionLevel: params.termSelectionLevel,
        definitionComplexityLevel: params.definitionComplexityLevel,
        numTerms: 5
      });
      setResult(response.data);
      setActiveTab('results');
    } catch (error: any) {
      setError(error.response?.data?.error || error.message || 'Test generation failed');
    } finally {
      setLoading(false);
    }
  };

  const handleGenerateMore = async () => {
    if (!result) return;
    
    setLoading(true);
    setError(null);

    try {
      const response = await axios.post('http://localhost:4001/generate/test', {
        topic: params.topic,
        pipeline: params.openAiFirst ? 'openai-first' : 'source-first',
        termSelectionLevel: params.termSelectionLevel,
        definitionComplexityLevel: params.definitionComplexityLevel,
        numTerms: 10
      });

      if (response.data.success && response.data.data) {
        // Append new terms and facts to existing results
        setResult(prevResult => {
          if (!prevResult) return response.data;
          
          const newTerms = [...prevResult.data.terms, ...response.data.data.terms];
          const newFacts = [...prevResult.data.facts, ...response.data.data.facts];
          
          return {
            ...prevResult,
            data: {
              ...prevResult.data,
              terms: newTerms,
              facts: newFacts,
              stats: {
                ...prevResult.data.stats,
                termsGenerated: newTerms.length,
                factsGenerated: newFacts.length
              }
            }
          };
        });
      }
    } catch (error: any) {
      setError(error.response?.data?.error || error.message || 'Failed to generate additional vocabulary');
    } finally {
      setLoading(false);
    }
  };

  const updateParam = (key: keyof VocabularyParams, value: any) => {
    setParams(prev => {
      const newParams = { ...prev, [key]: value };
      
      // Auto-adjust limits when switching to OpenAI-first pipeline
      if (key === 'openAiFirst' && value === true) {
        newParams.numTerms = Math.min(newParams.numTerms, 10);
        newParams.numFacts = Math.min(newParams.numFacts, 5);
      }
      
      return newParams;
    });
  };

  return (
    <div className="min-h-screen bg-gray-50 py-8">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="text-center mb-8">
          <h1 className="text-4xl font-bold text-gray-900 mb-4">
            🚀 Dual-Pipeline Vocabulary Generator
          </h1>
          <p className="text-xl text-gray-600">
            Generate vocabulary terms using either Source-First or OpenAI-First pipelines
          </p>
          <div className="mt-4 p-4 bg-blue-50 rounded-lg">
            <p className="text-sm text-blue-800">
              <strong>Pipeline Limits:</strong> OpenAI-First pipeline is optimized for quality and limited to 10 terms and 5 facts maximum. 
              Source-First pipeline can generate up to 100 terms and 20 facts.
            </p>
          </div>
        </div>

        {/* Tab Navigation */}
        <div className="mb-8">
          <nav className="flex space-x-8">
            {[
              { id: 'params', label: 'Parameters', icon: '⚙️' },
              { id: 'results', label: 'Results', icon: '📊' },
              { id: 'pipelines', label: 'Pipeline Info', icon: '🔧' }
            ].map(tab => (
              <button
                key={tab.id}
                onClick={() => setActiveTab(tab.id as any)}
                className={`py-2 px-1 border-b-2 font-medium text-sm ${
                  activeTab === tab.id
                    ? 'border-blue-500 text-blue-600'
                    : 'border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300'
                }`}
              >
                {tab.icon} {tab.label}
              </button>
            ))}
          </nav>
        </div>

        {/* Parameters Tab */}
        {activeTab === 'params' && (
          <div className="grid grid-cols-1 lg:grid-cols-2 gap-8">
            {/* Basic Parameters */}
            <div className="bg-white rounded-lg shadow p-6">
              <h2 className="text-2xl font-bold mb-6">📋 Basic Parameters</h2>
              
              <div className="space-y-4">
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">
                    Topic
                  </label>
                  <input
                    type="text"
                    value={params.topic}
                    onChange={(e) => updateParam('topic', e.target.value)}
                    className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
                    placeholder="e.g., anime, blockchain, machine learning"
                  />
                </div>

                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">
                    Pipeline Strategy
                  </label>
                  <div className="flex space-x-4">
                    <label className="flex items-center">
                      <input
                        type="radio"
                        checked={!params.openAiFirst}
                        onChange={() => updateParam('openAiFirst', false)}
                        className="mr-2"
                      />
                      Source-First
                    </label>
                    <label className="flex items-center">
                      <input
                        type="radio"
                        checked={params.openAiFirst}
                        onChange={() => updateParam('openAiFirst', true)}
                        className="mr-2"
                      />
                      OpenAI-First
                    </label>
                  </div>
                </div>

                <div className="grid grid-cols-2 gap-4">
                  <div>
                    <label className="block text-sm font-medium text-gray-700 mb-2">
                      Number of Terms
                      {params.openAiFirst && (
                        <span className="text-sm text-blue-600 ml-2">(Max 10 for OpenAI-first)</span>
                      )}
                    </label>
                    <input
                      type="number"
                      min="1"
                      max={params.openAiFirst ? "10" : "100"}
                      value={params.numTerms}
                      onChange={(e) => {
                        const value = parseInt(e.target.value);
                        const maxValue = params.openAiFirst ? 10 : 100;
                        updateParam('numTerms', Math.min(value, maxValue));
                      }}
                      className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
                    />
                  </div>
                  <div>
                    <label className="block text-sm font-medium text-gray-700 mb-2">
                      Number of Facts
                      {params.openAiFirst && (
                        <span className="text-sm text-blue-600 ml-2">(Max 5 for OpenAI-first)</span>
                      )}
                    </label>
                    <input
                      type="number"
                      min="1"
                      max={params.openAiFirst ? "5" : "20"}
                      value={params.numFacts}
                      onChange={(e) => {
                        const value = parseInt(e.target.value);
                        const maxValue = params.openAiFirst ? 5 : 20;
                        updateParam('numFacts', Math.min(value, maxValue));
                      }}
                      className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
                    />
                  </div>
                </div>

                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">
                    Definition Style
                  </label>
                  <select
                    value={params.definitionStyle}
                    onChange={(e) => updateParam('definitionStyle', e.target.value)}
                    className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
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
                    value={params.termSelectionLevel}
                    onChange={(e) => updateParam('termSelectionLevel', e.target.value)}
                    className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
                  >
                    <option value="beginner">Beginner (Basic terms)</option>
                    <option value="intermediate">Intermediate (Some specialized terms)</option>
                    <option value="advanced">Advanced (Professional terminology)</option>
                  </select>
                </div>

                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">
                    Definition Complexity Level
                  </label>
                  <select
                    value={params.definitionComplexityLevel}
                    onChange={(e) => updateParam('definitionComplexityLevel', e.target.value)}
                    className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
                  >
                    <option value="beginner">Beginner (Simple explanations)</option>
                    <option value="intermediate">Intermediate (Clear with some technical terms)</option>
                    <option value="advanced">Advanced (Technical and comprehensive)</option>
                  </select>
                </div>
              </div>
            </div>

            {/* Advanced Parameters */}
            <div className="bg-white rounded-lg shadow p-6">
              <h2 className="text-2xl font-bold mb-6">🔧 Advanced Parameters</h2>
              
              <div className="space-y-4">
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">
                    Domain Context
                  </label>
                  <input
                    type="text"
                    value={params.domainContext}
                    onChange={(e) => updateParam('domainContext', e.target.value)}
                    className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
                    placeholder="e.g., technology, arts, science"
                  />
                </div>

                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">
                    Sentence Range
                  </label>
                  <input
                    type="text"
                    value={params.sentenceRange}
                    onChange={(e) => updateParam('sentenceRange', e.target.value)}
                    className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
                    placeholder="e.g., 2-4"
                  />
                </div>

                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">
                    Examples per Term
                  </label>
                  <input
                    type="number"
                    min="1"
                    max="5"
                    value={params.numExamples}
                    onChange={(e) => updateParam('numExamples', parseInt(e.target.value))}
                    className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
                  />
                </div>

                <div className="space-y-3">
                  <h3 className="text-lg font-medium text-gray-700">Include Options</h3>
                  {[
                    { key: 'useAnalogy', label: 'Analogies' },
                    { key: 'includeSynonyms', label: 'Synonyms' },
                    { key: 'includeAntonyms', label: 'Antonyms' },
                    { key: 'includeRelatedTerms', label: 'Related Terms' },
                    { key: 'includeEtymology', label: 'Etymology' },
                    { key: 'highlightRootWords', label: 'Highlight Root Words' }
                  ].map(option => (
                    <label key={option.key} className="flex items-center">
                      <input
                        type="checkbox"
                        checked={params[option.key as keyof VocabularyParams] as boolean}
                        onChange={(e) => updateParam(option.key as keyof VocabularyParams, e.target.checked)}
                        className="mr-2"
                      />
                      {option.label}
                    </label>
                  ))}
                </div>
              </div>
            </div>
          </div>
        )}

        {/* Results Tab */}
        {activeTab === 'results' && (
          <div className="bg-white rounded-lg shadow p-6">
            <h2 className="text-2xl font-bold mb-6">📊 Generation Results</h2>
            
            {loading && (
              <div className="text-center py-8">
                <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-500 mx-auto"></div>
                <p className="mt-4 text-gray-600">Generating vocabulary terms...</p>
              </div>
            )}

            {error && (
              <div className="bg-red-50 border border-red-200 rounded-md p-4 mb-6">
                <div className="flex">
                  <div className="flex-shrink-0">
                    <span className="text-red-400">❌</span>
                  </div>
                  <div className="ml-3">
                    <h3 className="text-sm font-medium text-red-800">Error</h3>
                    <div className="mt-2 text-sm text-red-700">{error}</div>
                  </div>
                </div>
              </div>
            )}

            {result && result.data && result.data.stats && (
              <div className="space-y-6">
                {/* Stats */}
                <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
                  <div className="bg-blue-50 rounded-lg p-4">
                    <div className="text-2xl font-bold text-blue-600">{result.data.stats.termsGenerated || 0}</div>
                    <div className="text-sm text-blue-800">Terms Generated</div>
                  </div>
                  <div className="bg-green-50 rounded-lg p-4">
                    <div className="text-2xl font-bold text-green-600">{result.data.stats.factsGenerated || 0}</div>
                    <div className="text-sm text-green-800">Facts Generated</div>
                  </div>
                  <div className="bg-yellow-50 rounded-lg p-4">
                    <div className="text-2xl font-bold text-yellow-600">{result.data.stats.duplicatesRemoved || 0}</div>
                    <div className="text-sm text-yellow-800">Duplicates Removed</div>
                  </div>
                  <div className="bg-purple-50 rounded-lg p-4">
                    <div className="text-2xl font-bold text-purple-600">{result.data.stats.processingTime || 0}ms</div>
                    <div className="text-sm text-purple-800">Processing Time</div>
                  </div>
                </div>

                {/* Pipeline Info */}
                <div className="bg-gray-50 rounded-lg p-4">
                  <h3 className="text-lg font-medium mb-2">Pipeline: {result.data.pipeline || 'unknown'}</h3>
                  <p className="text-gray-600">
                    {result.data.pipeline === 'source-first' 
                      ? 'External sources first, OpenAI fallback'
                      : 'OpenAI generation first, external enrichment'
                    }
                  </p>
                </div>

                {/* Terms */}
                <div>
                  <h3 className="text-lg font-medium mb-4">Generated Terms</h3>
                  <div className="space-y-4">
                    {result.data.terms && result.data.terms.map((term, index) => (
                      <div key={index} className="border rounded-lg p-4">
                        <div className="flex justify-between items-start mb-2">
                          <h4 className="text-lg font-semibold text-blue-600">{term.term}</h4>
                          <div className="flex space-x-2 text-xs">
                            {term.verified && <span className="bg-green-100 text-green-800 px-2 py-1 rounded">Verified</span>}
                            {term.gptGenerated && <span className="bg-blue-100 text-blue-800 px-2 py-1 rounded">AI Generated</span>}
                            {term.confidenceScore && (
                              <span className="bg-gray-100 text-gray-800 px-2 py-1 rounded">
                                {Math.round(term.confidenceScore * 100)}% confidence
                              </span>
                            )}
                          </div>
                        </div>
                        <p className="text-gray-700 mb-2">{term.definition}</p>
                        
                        {term.examples && term.examples.length > 0 && (
                          <div className="mb-2">
                            <h5 className="text-sm font-medium text-gray-600">Examples:</h5>
                            <ul className="list-disc list-inside text-sm text-gray-600">
                              {term.examples.map((example, i) => (
                                <li key={i}>{example}</li>
                              ))}
                            </ul>
                          </div>
                        )}

                        {term.analogy && (
                          <div className="mb-2">
                            <h5 className="text-sm font-medium text-gray-600">Analogy:</h5>
                            <p className="text-sm text-gray-600 italic">{term.analogy}</p>
                          </div>
                        )}

                        {term.synonyms && term.synonyms.length > 0 && (
                          <div className="mb-2">
                            <h5 className="text-sm font-medium text-gray-600">Synonyms:</h5>
                            <p className="text-sm text-gray-600">{term.synonyms.join(', ')}</p>
                          </div>
                        )}

                        {term.antonyms && term.antonyms.length > 0 && (
                          <div className="mb-2">
                            <h5 className="text-sm font-medium text-gray-600">Antonyms:</h5>
                            <p className="text-sm text-gray-600">{term.antonyms.join(', ')}</p>
                          </div>
                        )}

                        {term.relatedTerms && term.relatedTerms.length > 0 && (
                          <div className="mb-2">
                            <h5 className="text-sm font-medium text-gray-600">Related Terms:</h5>
                            <p className="text-sm text-gray-600">{term.relatedTerms.join(', ')}</p>
                          </div>
                        )}

                        {term.etymology && (
                          <div className="mb-2">
                            <h5 className="text-sm font-medium text-gray-600">Etymology:</h5>
                            <p className="text-sm text-gray-600">{term.etymology}</p>
                          </div>
                        )}
                      </div>
                    ))}
                  </div>
                </div>

                {/* Facts */}
                {result.data.facts && result.data.facts.length > 0 && (
                  <div>
                    <h3 className="text-lg font-medium mb-4">Interesting Facts</h3>
                    <ul className="space-y-2">
                      {result.data.facts.map((fact, index) => (
                        <li key={index} className="flex items-start">
                          <span className="text-blue-500 mr-2">•</span>
                          <span className="text-gray-700">{fact}</span>
                        </li>
                      ))}
                    </ul>
                  </div>
                )}
              </div>
            )}
          </div>
        )}

        {/* Pipeline Info Tab */}
        {activeTab === 'pipelines' && (
          <div className="space-y-6">
            {pipelines.map(pipeline => (
              <div key={pipeline.id} className="bg-white rounded-lg shadow p-6">
                <h2 className="text-2xl font-bold mb-4">{pipeline.name}</h2>
                <p className="text-gray-600 mb-6">{pipeline.description}</p>
                
                <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                  <div>
                    <h3 className="text-lg font-medium text-green-600 mb-3">✅ Advantages</h3>
                    <ul className="space-y-2">
                      {pipeline.advantages.map((advantage, index) => (
                        <li key={index} className="flex items-start">
                          <span className="text-green-500 mr-2">•</span>
                          <span className="text-gray-700">{advantage}</span>
                        </li>
                      ))}
                    </ul>
                  </div>
                  
                  <div>
                    <h3 className="text-lg font-medium text-red-600 mb-3">⚠️ Disadvantages</h3>
                    <ul className="space-y-2">
                      {pipeline.disadvantages.map((disadvantage, index) => (
                        <li key={index} className="flex items-start">
                          <span className="text-red-500 mr-2">•</span>
                          <span className="text-gray-700">{disadvantage}</span>
                        </li>
                      ))}
                    </ul>
                  </div>
                </div>
                
                <div className="mt-6">
                  <h3 className="text-lg font-medium text-blue-600 mb-3">🎯 Best For</h3>
                  <div className="flex flex-wrap gap-2">
                    {pipeline.bestFor.map((use, index) => (
                      <span key={index} className="bg-blue-100 text-blue-800 px-3 py-1 rounded-full text-sm">
                        {use}
                      </span>
                    ))}
                  </div>
                </div>
              </div>
            ))}
          </div>
        )}

        {/* Action Buttons */}
        <div className="mt-8 flex justify-center space-x-4">
          <button
            onClick={handleTestGenerate}
            disabled={loading}
            className="bg-blue-600 text-white px-6 py-3 rounded-lg hover:bg-blue-700 disabled:opacity-50 disabled:cursor-not-allowed"
          >
            🧪 Test Generate (5 terms)
          </button>
          <button
            onClick={handleQuickGenerate}
            disabled={loading}
            className="bg-green-600 text-white px-6 py-3 rounded-lg hover:bg-green-700 disabled:opacity-50 disabled:cursor-not-allowed"
          >
            ⚡ Quick Generate
          </button>
          <button
            onClick={handleGenerate}
            disabled={loading}
            className="bg-purple-600 text-white px-6 py-3 rounded-lg hover:bg-purple-700 disabled:opacity-50 disabled:cursor-not-allowed"
          >
            🚀 Full Generate
          </button>
          {result && (
            <button
              onClick={handleGenerateMore}
              disabled={loading}
              className="bg-orange-600 text-white px-6 py-3 rounded-lg hover:bg-orange-700 disabled:opacity-50 disabled:cursor-not-allowed"
            >
              ➕ Generate More (10 terms)
            </button>
          )}
        </div>
      </div>
    </div>
  );
};

export default VocabPlayground;