import React, { useState } from 'react';
import TopicInputForm from '../components/TopicInputForm';
import TopicList from '../components/TopicList';
import TermFeed from '../components/TermFeed';

const HomePage: React.FC = () => {
  const [refreshTrigger, setRefreshTrigger] = useState(0);

  const handleTopicSubmitted = () => {
    setRefreshTrigger(prev => prev + 1);
  };

  return (
    <div className="min-h-screen bg-gray-50">
      <div className="max-w-6xl mx-auto p-6">
        <header className="text-center mb-8">
          <h1 className="text-4xl font-bold text-gray-900 mb-2">
            Larry Vocab Coach
          </h1>
          <p className="text-xl text-gray-600">
            AI-powered vocabulary learning for your interests
          </p>
        </header>

        <div className="grid grid-cols-1 lg:grid-cols-2 gap-8">
          <div className="space-y-6">
            <TopicInputForm onTopicSubmitted={handleTopicSubmitted} />
            <TopicList key={refreshTrigger} />
          </div>
          <div>
            <TermFeed key={refreshTrigger} />
          </div>
        </div>
      </div>
    </div>
  );
};

export default HomePage;
