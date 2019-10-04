module.exports = function (api) {
  api.cache.forever();

  const presets = [
    ['@babel/preset-env', {
      targets: {
        chrome: '49',
        edge: '14',
        firefox: '52',
        ie: '11',
        node: '6',
        safari: '9.0',
      }
    }],
  ];

  const plugins = [
    '@babel/plugin-transform-flow-strip-types',
    '@babel/plugin-transform-react-jsx',
    '@babel/plugin-transform-react-constant-elements',
    ['@babel/plugin-transform-runtime', {
      corejs: 2,
      helpers: true,
      regenerator: true,
      useESModules: false,
    }],
    '@babel/plugin-proposal-class-properties',
    '@babel/plugin-syntax-dynamic-import',
    '@babel/plugin-proposal-optional-chaining',
  ];

  const ignore = [
    'node_modules',
    'root/static/scripts/tests/typeInfo.js',
  ];

  return {
    presets,
    plugins,
    ignore,
    sourceType: 'unambiguous',
  };
};
