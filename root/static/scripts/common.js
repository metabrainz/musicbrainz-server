/* global polyfills not provided by core-js */
require('whatwg-fetch');
require('./common/focusin-focusout-polyfill');
/* end global polyfills */

require('./public-path');

/*
 * Needed by root/release/cover_art_uploader.tt, which uses the
 * css_manifest TT macro that requires common.less to exist in
 * rev-manifest.json.
 */
require('../styles/common.less');

const DBDefs = require('./common/DBDefs-client');
import MB from './common/MB';

if (DBDefs.DEVELOPMENT_SERVER) {
  /*
   * Used by the Selenium tests under /t/selenium/ to make sure that no errors
   * occurred on the page.
   */
  MB.js_errors = [];
  window.onerror = function (message, source, lineno, colno, error) {
    MB.js_errors.push(error && error.stack ? error.stack : message);
  };
}

require('./common/sentry');

window.ko = require('knockout');
window.$ = window.jQuery = require('jquery');

require('../lib/jquery.ui/ui/jquery-ui.custom');

require('./common/components/Annotation');
require('./common/components/CommonsImage');
require('./common/components/FingerprintTable');
require('./common/components/WikipediaExtract');
require('./common/MB/Control/Autocomplete');
require('./common/components/ReleaseEvents');
require('./common/components/WorkArtists');
require('./common/MB/Control/SelectAll');
require('./common/components/TagEditor');
require('./common/components/sidebar/AcousticBrainz');

import(
  /* webpackChunkName: "common-artwork-viewer" */ './common/artworkViewer'
);
import(/* webpackChunkName: "common-dialogs" */ './common/dialogs');
import(/* webpackChunkName: "common-filter" */ './common/components/Filter');
import(/* webpackChunkName: "common-menu" */ './common/MB/Control/Menu');
import(
  /* webpackChunkName: "common-edit-search" */ './common/MB/edit_search'
);
import(/* webpackChunkName: "common-release" */ './common/MB/release');
import(/* webpackChunkName: "common-ratings" */ './common/ratings');
import(/* webpackChunkName: "common-tagger" */ './common/tagger');
import(/* webpackChunkName: "common-cover-art" */ './common/coverart');
import(/* webpackChunkName: "common-banner" */ './common/banner');
