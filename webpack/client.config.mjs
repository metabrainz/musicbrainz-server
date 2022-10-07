/*
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import fs from 'fs';
import path from 'path';

import canonicalJson from 'canonical-json';
import shellQuote from 'shell-quote';
import shell from 'shelljs';
import TerserPlugin from 'terser-webpack-plugin';
import webpack from 'webpack';

import * as poFile from '../root/server/gettext/poFile.mjs';
import {cloneObjectDeep}
  from '../root/static/scripts/common/utility/cloneDeep.mjs';
import jedDataTemplate from '../root/static/scripts/jed-data.mjs';
import MB_SERVER_ROOT from '../root/utility/serverRootDir.mjs';

import browserConfig from './browserConfig.mjs';
import cacheConfig from './cacheConfig.mjs';
import {
  BUILD_DIR,
  GETTEXT_DOMAINS,
  PO_DIR,
  PRODUCTION_MODE,
  SCRIPTS_DIR,
  WEBPACK_MODE,
} from './constants.mjs';
import moduleConfig from './moduleConfig.mjs';
import providePluginConfig from './providePluginConfig.mjs';

const jsExt = /\.[cm]?js$/;

const entries = [
  'account/applications/register',
  'account/edit',
  'account/preferences',
  'annotation/AnnotationHistoryTable',
  'alias',
  'area/edit',
  'area/index',
  'area/places-map',
  'artist/edit',
  'artist/index',
  'collection/edit',
  'common',
  'common/components/AcoustIdCell',
  'common/components/ArtistRoles',
  'common/components/AttributeList',
  'common/components/IsrcList',
  'common/components/ReleaseEvents',
  'common/components/TaggerIcon',
  'common/components/WorkArtists',
  'confirm-seed',
  'edit',
  'edit/components/NewNotesAlertCheckbox',
  'event/edit',
  'event/index',
  'genre/components/GenreEditForm',
  'genre/index',
  'instrument/index',
  'jed-data.mjs',
  'label/index',
  'place/edit',
  'place/index',
  'place/map',
  'recording/edit',
  'register',
  'relationship-editor',
  'release/coverart',
  'release/edit-relationships',
  'release/index',
  'release-editor',
  'release-group/index',
  'series/edit',
  'series/index',
  'statistics',
  'timeline',
  'url/edit',
  'user/login',
  'voting',
  'work/edit',
  'work/index',
].reduce((accum, name) => {
  let nameWithExt;
  let nameWithoutExt;
  if (jsExt.test(name)) {
    nameWithExt = name;
    nameWithoutExt = name.replace(jsExt, '');
  } else {
    nameWithExt = `${name}.js`;
    nameWithoutExt = name;
  }
  accum[nameWithoutExt] = path.resolve(SCRIPTS_DIR, nameWithExt);
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
    }
    throw err;
  }
}

function findNewerPo(domain, lang, bundleMtime) {
  const srcPo = poFile.find(domain, lang);
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
  const scriptsDir = shellQuote.quote([SCRIPTS_DIR]);
  const nestedDirs = shell.exec(
    `find ${scriptsDir} -type d`,
    {silent: true},
  ).stdout.split('\n');
  const msgLocations = nestedDirs
    .filter(Boolean)
    .map(dir => (
      '-N ' +
      shellQuote.quote(['..' + dir.replace(MB_SERVER_ROOT, '') + '/*.js'])))
    .join(' ');

  srcPo = shellQuote.quote([srcPo]);
  const tmpPo = shellQuote.quote(
    [path.resolve(PO_DIR, `javascript.${lang}.po`)],
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
    jedData = createJsPo(srcPo, lang);
  } else {
    jedData = poFile.loadFromPath(srcPo, domain);
    jedData.domain = 'mb_server';
  }
  return jedData;
}

const MB_LANGUAGES = shell.exec(
  `find ${shellQuote.quote([PO_DIR])} -type f -name 'mb_server*.po'`,
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
  const filePath = path.resolve(BUILD_DIR, `${fileName}.source.js`);
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
      'import jedData from ' +
      JSON.stringify(path.resolve(SCRIPTS_DIR, 'jed-data.mjs')) + ';\n' +
      'const locale = ' + JSON.stringify(lang) + ';\n' +
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
    new webpack.ids.HashedModuleIdsPlugin({
      hashDigestLength: 7,
    }),
  );
}

if (String(process.env.NO_PROGRESS) !== '1') {
  plugins.push(
    new webpack.ProgressPlugin({
      activeModules: true,
    }),
  );
}

export default {
  cache: cacheConfig,

  context: MB_SERVER_ROOT,

  devtool: 'source-map',

  entry: entries,

  mode: WEBPACK_MODE,

  module: moduleConfig,

  name: 'client-bundles',

  node: false,

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

    ...(PRODUCTION_MODE ? {
      minimizer: [
        new TerserPlugin({
          terserOptions: {
            safari10: true,
          },
        }),
      ],
    } : null),
  },

  output: {
    filename: (
      PRODUCTION_MODE
        ? '[name]-[chunkhash:7].js'
        : '[name].js'
    ),
    path: BUILD_DIR,
  },

  plugins,

  resolve: browserConfig.resolve,
};
