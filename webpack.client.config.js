/*
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

const canonicalJson = require('canonical-json');
const CopyWebpackPlugin = require('copy-webpack-plugin');
const fs = require('fs');
const ManifestPlugin = require('webpack-manifest-plugin');
const path = require('path');
const shell = require('shelljs');
const shellQuote = require('shell-quote');
const TerserPlugin = require('terser-webpack-plugin');
const webpack = require('webpack');

const poFile = require('./root/server/gettext/poFile');
const browserConfig = require('./webpack/browserConfig');
const {
  dirs,
  GETTEXT_DOMAINS,
  PRODUCTION_MODE,
  WEBPACK_MODE,
} = require('./webpack/constants');
const moduleConfig = require('./webpack/moduleConfig');
const providePluginConfig = require('./webpack/providePluginConfig');
const {cloneObjectDeep} =
  require('./root/static/scripts/common/utility/cloneDeep');
const jedDataTemplate = require('./root/static/scripts/jed-data');

const entries = [
  'account/applications/register',
  'account/edit',
  'account/preferences',
  'area',
  'alias',
  'area/index',
  'area/places-map',
  'artist',
  'artist/index',
  'collection/edit',
  'common',
  'confirm-seed',
  'edit',
  'edit/notes-received',
  'event',
  'event/index',
  'instrument/index',
  'jed-data',
  'label/index',
  'place',
  'place/index',
  'place/map',
  'recording/form',
  'recording/merge',
  'release-editor',
  'release-group/index',
  'series',
  'series/index',
  'statistics',
  'timeline',
  'url',
  'user/login',
  'voting',
  'work',
  'work/index',
].reduce((accum, name) => {
  accum[name] = path.resolve(dirs.SCRIPTS, `${name}.js`);
  return accum;
}, {});

function langToPosix(lang) {
  return lang.replace(/^([a-zA-Z]+)-([a-zA-Z]+)$/, function (match, l, c) {
    l = l.toLowerCase();
    c = c.toUpperCase();
    return l + '_' + c.toUpperCase();
  });
}

function mtime(fpath) {
  try {
    return fs.statSync(fpath).mtime;
  } catch (err) {
    if (err.code === 'ENOENT') {
      return null;
    } else {
      throw err;
    }
  }
}

function findNewerPo(domain, lang, bundleMtime) {
  let srcPo = poFile.find(domain, lang);
  const poMtime = mtime(srcPo);
  if (poMtime === null) {
    console.warn(`Warning: ${srcPo} does not exist, skipping`);
    return null;
  } else if (bundleMtime && bundleMtime >= poMtime) {
    return null;
  }
  return srcPo;
}

function createJsPo(srcPo, lang) {
  /*
   * We handle the mb_server domain specially by filtering out strings that
   * don't appear in any JavaScript file.
   */

  /*
   * msggrep's -N option supports wildcards which use fnmatch internally.
   * The '*' cannot match path separators, so we must generate a list of
   * possible terminal paths.
   */
  const scriptsDir = shellQuote.quote([dirs.SCRIPTS]);
  const nestedDirs = shell.exec(
    `find ${scriptsDir} -type d`,
    {silent: true},
  ).stdout.split('\n');
  const msgLocations = nestedDirs
    .filter(Boolean)
    .map(dir => (
      '-N ' +
      shellQuote.quote(['..' + dir.replace(dirs.CHECKOUT, '') + '/*.js'])))
    .join(' ');

  srcPo = shellQuote.quote([srcPo]);
  const tmpPo = shellQuote.quote(
    [path.resolve(dirs.PO, `javascript.${lang}.po`)],
  );

  /*
   * Create a temporary .po file containing only the strings used by
   * root/static/scripts.
   */
  shell.exec(`msggrep ${msgLocations} ${srcPo} -o ${tmpPo}`);

  const jedData = poFile.load('javascript', lang, 'mb_server');
  fs.unlinkSync(tmpPo);
  return jedData;
}

function loadNewerPo(domain, lang, bundleMtime) {
  const srcPo = findNewerPo(domain, lang, bundleMtime);
  if (!srcPo) {
    return null;
  }
  let jedData;
  if (domain === 'mb_server') {
    jedData = createJsPo(srcPo, lang)
  } else {
    jedData = poFile.loadFromPath(srcPo, domain);
    jedData.domain = 'mb_server';
  }
  return jedData;
}

const MB_LANGUAGES = shell.exec(
  `find ${shellQuote.quote([dirs.PO])} -type f -name 'mb_server*.po'`,
  {silent: true},
).stdout.split('\n').reduce((accum, filePath) => {
  const lang = filePath.replace(/^.*\/mb_server\.([A-z_]+)\.po$/, '$1');
  if (lang && lang !== 'en') {
    accum.push(langToPosix(lang));
  }
  return accum;
}, []);

MB_LANGUAGES.forEach(function (lang) {
  const langJedData = cloneObjectDeep(jedDataTemplate.en);
  const fileName = `jed-${lang}`;
  const filePath = path.resolve(dirs.BUILD, `${fileName}.source.js`);
  const fileMtime = mtime(filePath);
  let loadedNewPoData = false;

  GETTEXT_DOMAINS.forEach(function (domain) {
    const domainJedData = loadNewerPo(domain, lang, fileMtime);

    if (domainJedData) {
      loadedNewPoData = true;
      langJedData.locale_data[domain] = domainJedData.locale_data[domain];
    }
  });

  if (loadedNewPoData) {
    const source = (
      'var jedData = require(' +
      JSON.stringify(path.resolve(dirs.SCRIPTS, 'jed-data')) + ');\n' +
      'var locale = ' + JSON.stringify(lang) + ';\n' +
      // https://v8.dev/blog/cost-of-javascript-2019#json
      'jedData[locale] = JSON.parse(\'' +
      canonicalJson(langJedData)
        .replace(/\\/g, '\\\\')
        .replace(/'/g, "\\'") +
      '\');\n' +
      'jedData.locale = locale;\n'
    );
    fs.writeFileSync(filePath, source);
  }

  if (fs.existsSync(filePath)) {
    entries[fileName] = filePath;
  }
});

const plugins = browserConfig.plugins.concat();

plugins.push(new webpack.ProvidePlugin(providePluginConfig));

if (PRODUCTION_MODE) {
  plugins.push(
    new webpack.HashedModuleIdsPlugin({
      hashDigestLength: 7,
    }),
  );
}

plugins.push.apply(plugins, [
  new CopyWebpackPlugin([
    {from: 'favicon.ico', to: '.'},
    {from: 'robots.txt.*', to: '.'},
  ], {context: './root/'}),

  new ManifestPlugin({
    fileName: 'rev-manifest.json',
  }),
]);

module.exports = {
  context: dirs.CHECKOUT,

  devtool: 'source-map',

  entry: entries,

  mode: WEBPACK_MODE,

  module: moduleConfig,

  node: browserConfig.node,

  optimization: {
    runtimeChunk: 'single',
    splitChunks: {
      cacheGroups: {
        'common-chunks': {
          chunks: 'initial',
          minChunks: 2,
          name: 'common-chunks',
          priority: -30,
          reuseExistingChunk: true,
        },
      },
    },
  },

  output: {
    filename: (
      PRODUCTION_MODE
        ? '[name]-[chunkhash:7].js'
        : '[name].js'
    ),
    path: dirs.BUILD,
  },

  plugins,

  resolve: browserConfig.resolve,
};

if (String(process.env.WATCH_MODE) === '1') {
  Object.assign(module.exports, require('./webpack/watchConfig'));
}

if (PRODUCTION_MODE) {
  module.exports.optimization.minimizer = [
    new TerserPlugin({
      sourceMap: true,
      terserOptions: {
        safari10: true,
      },
    }),
  ];
}
