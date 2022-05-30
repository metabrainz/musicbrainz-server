/* eslint-disable import/no-commonjs */

const ignore = require('./webpack/babel-ignored');

const BROWSER_TARGETS = {
  chrome: '49',
  edge: '14',
  firefox: '52',
  safari: '9.0',
};

const NODE_TARGETS = {
  node: process.versions.node,
};

module.exports = function (api) {
  api.cache.using(() => process.env.NODE_ENV);

  const presets = [
    ['@babel/preset-env', {
      corejs: 3,
      targets: api.caller(caller => caller && caller.target === 'node')
        ? NODE_TARGETS
        : BROWSER_TARGETS,
      useBuiltIns: 'usage',
    }],
  ];

  const plugins = [
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
