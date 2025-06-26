/* eslint-disable import/no-commonjs */

// Note: This file is CommonJS because ESLint doesn't support async parsers.

const ignore = require('./webpack/babel-ignored.cjs');

const BROWSER_TARGETS = {
  production: {
    chrome: '125',
    edge: '125',
    firefox: '128',
    safari: '15',
  },
  modern: {
    chrome: '137',
    firefox: '139',
    safari: '18',
  },
  legacy: {
    chrome: '49',
    edge: '14',
    firefox: '52',
    safari: '9.0',
  },
};

const NODE_TARGETS = {
  node: process.versions.node,
};

module.exports = function (api) {
  const browserTarget = process.env.BROWSER_TARGET ?? 'production';
  if (!Object.hasOwn(BROWSER_TARGETS, browserTarget)) {
    throw new Error(
      `Unknown BROWSER_TARGET: ${browserTarget}. ` +
      `Expected one of ${Object.keys(BROWSER_TARGETS).join(', ')}.`,
    );
  }

  api.cache.using(() => process.env.NODE_ENV);
  api.cache.using(() => browserTarget);

  const presets = [
    ['@babel/preset-env', {
      corejs: 3.38,
      targets: api.caller(caller => caller && caller.target === 'node')
        ? NODE_TARGETS
        : BROWSER_TARGETS[browserTarget],
      useBuiltIns: 'usage',
    }],
  ];

  const plugins = [
    'babel-plugin-syntax-hermes-parser',
    '@babel/plugin-transform-flow-strip-types',
    ['@babel/plugin-transform-react-jsx', {
      runtime: 'automatic',
    }],
    ['@babel/plugin-transform-runtime', {
      corejs: false,
      helpers: true,
      regenerator: true,
      useESModules: false,
    }],
    '@babel/plugin-proposal-class-properties',
    '@babel/plugin-syntax-dynamic-import',
    '@babel/plugin-proposal-optional-chaining',
    '@babel/plugin-proposal-nullish-coalescing-operator',
  ];

  if (process.env.NODE_ENV === 'test') {
    plugins.push('babel-plugin-istanbul');
  }

  return {
    ignore,
    plugins,
    presets,
    sourceType: 'unambiguous',
  };
};
