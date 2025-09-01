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

import jedDataTemplate from '../root/jedDataTemplate.mjs';
import * as poFile from '../root/server/gettext/poFile.mjs';
import {cloneObjectDeep}
  from '../root/static/scripts/common/utility/cloneDeep.mjs';
import MB_SERVER_ROOT from '../root/utility/serverRootDir.mjs';

import browserConfig from './browserConfig.mjs';
import cacheConfig from './cacheConfig.mjs';
import {
  BUILD_DIR,
  ECMA_VERSION,
  GETTEXT_DOMAINS,
  GLOBAL_JS_NAMESPACE,
  LEGACY_BROWSER,
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
  'account/components/RegisterForm',
  'account/edit',
  'account/preferences',
  'admin/components/PossibleSpammersList',
  'admin/components/SpammerButton',
  'annotation/AnnotationHistoryTable',
  'alias',
  'area/edit',
  'area/index',
  'area/places-map',
  'artist/edit',
  'artist/index',
  'artist/split',
  'collection/edit',
  'common/artworkViewer',
  'common/banner',
  'common/components/AcoustIdCell',
  'common/components/Annotation',
  'common/components/ArtistRoles',
  'common/components/AttributeList',
  'common/components/CDTocReleaseListTable',
  'common/components/CommonsImage',
  'common/components/Filter',
  'common/components/FingerprintTable',
  'common/components/IsrcList',
  'common/components/IswcList',
  'common/components/ListMergeButtonsRow',
  'common/components/ReleaseEvents',
  'common/components/TagEditor',
  'common/components/TaggerIcon',
  'common/components/WorkArtists',
  'common/jquery-global',
  'common/loadArtwork',
  'common/MB/Control/Menu',
  'common/MB/Control/SelectAll',
  'common/MB/edit_search',
  'common/ratings',
  'common/sentry',
  'confirm-seed',
  'edit/components/FormRowTextList',
  'edit/components/HydratedDateRangeFieldset',
  'edit/components/NewNotesAlertCheckbox',
  'edit/components/ReleaseMergeStrategy',
  'edit/ExampleRelationships',
  'edit/MB/reltypeslist',
  'event/components/EventEditForm',
  'event/eventart',
  'event/index',
  'genre/components/GenreEditForm',
  'genre/index',
  'homepage/banner-carousel',
  'homepage/navbar',
  'homepage/search',
  'homepage/stats',
  'instrument/edit',
  'instrument/index',
  'label/edit',
  'label/index',
  'place/edit',
  'place/index',
  'place/map',
  'public-path',
  'recording/edit',
  'recording/index',
  'relationship-editor',
  'release/coverart',
  'release/edit-relationships',
  'release/index',
  'release-editor',
  'release-group/edit',
  'release-group/index',
  'selenium',
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

entries['whatwg-fetch'] = path.resolve(
  MB_SERVER_ROOT,
  'node_modules/whatwg-fetch/fetch.js',
);

function langToPosix(lang) {
  return lang.replace(/^([a-zA-Z]+)-([a-zA-Z0-9]+)$/, function (match, l, c) {
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
  const lang = filePath.replace(/^.*\/mb_server\.([A-z0-9_]+)\.po$/, '$1');
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
      'window[' + JSON.stringify(GLOBAL_JS_NAMESPACE) + ']' +
      '.jedData[' + JSON.stringify(lang) + '] = ' +
      // https://v8.dev/blog/cost-of-javascript-2019#json
      'JSON.parse(\'' +
      canonicalJson(langJedData)
        .replace(/\\/g, '\\\\')
        .replace(/'/g, "\\'") +
      '\');\n'
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
  cache: String(process.env.NO_CACHE) === '1' ? false : cacheConfig,

  context: MB_SERVER_ROOT,

  devtool: process.env.WEBPACK_DEVTOOL ?? 'source-map',

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
          minChunks: 5,
          name: 'common-chunks',
          priority: -30,
          reuseExistingChunk: true,
        },
        'vendors': {
          chunks: 'initial',
          minChunks: 5,
          name: 'vendors',
          priority: -20,
          test: /\/node_modules\//,
        },
      },
    },

    ...(PRODUCTION_MODE ? {
      minimizer: [
        new TerserPlugin({
          terserOptions: {
            ecma: ECMA_VERSION,
            safari10: LEGACY_BROWSER,
          },
        }),
      ],
    } : null),
  },

  output: {
    ...(
      LEGACY_BROWSER
        ? {
          environment: {
            arrowFunction: false,
            asyncFunction: false,
            const: false,
            destructuring: false,
            forOf: false,
            globalThis: false,
            optionalChaining: false,
            templateLiteral: false,
          },
        }
        : {}
    ),
    filename: (
      '[name]' +
        /*
         * We don't distinguish between production and modern browser targets
         * here because generally only one of those is used locally; whereas
         * legacy bundles are built alongside production ones in production.
         */
        (LEGACY_BROWSER ? '-legacy' : '') +
        (PRODUCTION_MODE ? '-[chunkhash:7]' : '') + '.js'
    ),
    path: BUILD_DIR,
  },

  plugins,

  resolve: browserConfig.resolve,
};
