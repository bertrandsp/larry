module.exports = {
  root: true,
  parser: '@typescript-eslint/parser',
  plugins: ['@typescript-eslint', 'import'],
  extends: [
    'eslint:recommended',
    'plugin:@typescript-eslint/recommended',
    'prettier',
  ],
  rules: {
    'import/order': ['warn', { 'newlines-between': 'always' }],
    '@typescript-eslint/no-unused-vars': 'warn',
  },
  ignorePatterns: ['dist/**', 'node_modules/**'],
  env: {
    node: true,
    es2020: true,
  },
};
