/*
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

const _ = require('lodash');
const canonicalJson = require('canonical-json');
const CopyWebpackPlugin = require('copy-webpack-plugin');
const fs = require('fs');
const ManifestPlugin = require('webpack-manifest-plugin');
const path = require('path');
const shell = require('shelljs');
const shellQuote = require('shell-quote');
const UglifyJsPlugin = require('uglifyjs-webpack-plugin')
const webpack = require('webpack');

const poFile = require('./root/server/gettext/poFile');
const DBDefs = require('./root/static/scripts/common/DBDefs');
const browserConfig = require('./webpack/browserConfig');
const {dirs, GETTEXT_DOMAINS, PUBLIC_PATH} = require('./webpack/constants');
const moduleConfig = require('./webpack/moduleConfig');
const providePluginConfig = require('./webpack/providePluginConfig');

const entries = [
  'account/applications/register',
  'account/edit',
  'account/preferences',
  'area/index',
  'area/places-map',
  'artist/index',
  'common',
  'edit',
  'edit/notes-received',
  'event/index',
  'instrument/index',
  'jed-data',
  'label/index',
  'place',
  'place/index',
  'place/map',
  'release-editor',
  'release-group/index',
  'series',
  'series/index',
  'statistics',
  'timeline',
  'url',
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

    /*
     * Handle symlinks (see under po/). We want to keep the the result here
     * consistent regardless of whether someone has el or el-gr in their
     * MB_LANGUAGE setting, for example.
     */
    if (/^(?:el_GR|es_ES)$/.test(`${l}_${c}`)) {
      return l;
    }

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
  const nestedDirs = shell.exec(`find ${scriptsDir} -type d`, {silent: true}).output.split('\n');
  const msgLocations = _(nestedDirs)
    .compact()
    .map(dir => '-N ' + shellQuote.quote(['..' + dir.replace(dirs.CHECKOUT, '') + '/*.js']))
    .join(' ');

  srcPo = shellQuote.quote([srcPo]);
  tmpPo = shellQuote.quote([path.resolve(dirs.PO, `javascript.${lang}.po`)]);

  /*
   * Create a temporary .po file containing only the strings used by
   * root/static/scripts.
   */
  shell.exec(`msggrep ${msgLocations} ${srcPo} -o ${tmpPo}`);

  jedData = poFile.load('javascript', lang, 'mb_server');
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

_(DBDefs.MB_LANGUAGES || '')
  .split(/\s+/)
  .compact()
  .without('en')
  .map(langToPosix)
  .each(function (lang) {
    GETTEXT_DOMAINS.forEach(function (domain) {
      const fileName = `jed-${lang}-${domain}`;
      const filePath = path.resolve(dirs.BUILD, `${fileName}.source.js`);
      const fileMtime = mtime(filePath);
      const jedData = loadNewerPo(domain, lang, fileMtime);

      if (jedData) {
        const source = (`
          require(${
            JSON.stringify(path.resolve(dirs.SCRIPTS, 'jed-data'))
          }).mergeData(
            ${JSON.stringify(domain)},
            ${JSON.stringify(lang)},
            ${canonicalJson(jedData)},
          );
        `);
        fs.writeFileSync(filePath, source);
      }

      if (fs.existsSync(filePath)) {
        entries[fileName] = filePath;
      }
    });
  });

const plugins = browserConfig.plugins.concat();

plugins.push(new webpack.ProvidePlugin(providePluginConfig));

if (!DBDefs.DEVELOPMENT_SERVER) {
  plugins.push(
    new webpack.HashedModuleIdsPlugin({
      hashDigestLength: 7,
    })
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

if (!DBDefs.DEVELOPMENT_SERVER) {
  plugins.push(new UglifyJsPlugin({
    uglifyOptions: {
      ecma: 5,
      mangle: true,
      output: {
        comments: /@preserve|@license/,
      },
    },
  }));
}

module.exports = {
  context: dirs.CHECKOUT,

  devtool: DBDefs.DEVELOPMENT_SERVER ? 'cheap-source-map' : undefined,

  entry: entries,

  mode: DBDefs.DEVELOPMENT_SERVER ? 'development' : 'production',

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
      DBDefs.DEVELOPMENT_SERVER
        ? '[name].js'
        : '[name]-[chunkhash:7].js'
    ),
    path: dirs.BUILD,
    publicPath: PUBLIC_PATH,
  },

  plugins,

  resolve: browserConfig.resolve,
};

if (String(process.env.WATCH_MODE) === '1') {
  Object.assign(module.exports, require('./webpack/watchConfig'));
}
