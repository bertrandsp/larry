module.exports = function(api) {
  api.cache(true);
  return {
    presets: [
      ['babel-preset-expo', {
        runtime: 'automatic'
      }]
    ],
    plugins: [
      ['@babel/plugin-transform-runtime', {
        helpers: true,
        regenerator: true,
        useESModules: false,
        absoluteRuntime: false
      }]
    ]
  };
};
