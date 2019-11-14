// Needed by root/release/cover_art_uploader.tt, which uses the
// css_manifest TT macro that requires common.less to exist in
// rev-manifest.json.
require('../styles/common.less');

// IE 11 support.
require('core-js/modules/es6.object.assign');
require('core-js/modules/es6.array.from');
require('core-js/modules/es6.array.iterator');
require('core-js/modules/es6.string.iterator');
require('core-js/es6/set');
require('core-js/es6/map');
require('core-js/es6/promise');
require('core-js/es6/symbol');

const DBDefs = require('./common/DBDefs-client');
import MB from './common/MB';

if (DBDefs.DEVELOPMENT_SERVER) {
  // Used by the Selenium tests under /t/selenium/ to make sure that no errors
  // occurred on the page.
  MB.js_errors = [];
  window.onerror = function (message, source, lineno, colno, error) {
    MB.js_errors.push(error && error.stack ? error.stack : message);
  };
}

require('./common/raven');

window.ko = require('knockout');
window._ = require('lodash');
window.$ = window.jQuery = require('jquery');

require('../lib/jquery.ui/ui/jquery-ui.custom');

require('./common/components/Annotation');
require('./common/components/CommonsImage');
require('./common/components/FingerprintTable');
require('./common/components/WikipediaExtract');
require('./common/i18n');
require('./common/entity');
require('./common/MB/Control/Autocomplete');
require('./common/components/TagEditor');

import(/* webpackChunkName: "common-artwork-viewer" */ './common/artworkViewer');
import(/* webpackChunkName: "common-dialogs" */ './common/dialogs');
import(/* webpackChunkName: "common-filter" */ './common/components/Filter');
import(/* webpackChunkName: "common-menu" */ './common/MB/Control/Menu');
import(/* webpackChunkName: "common-select-all" */ './common/MB/Control/SelectAll');
import(/* webpackChunkName: "common-edit-search" */ './common/MB/edit_search');
import(/* webpackChunkName: "common-release" */ './common/MB/release');
import(/* webpackChunkName: "common-ratings" */ './common/ratings');
import(/* webpackChunkName: "common-tagger" */ './common/tagger');
import(/* webpackChunkName: "common-cover-art" */ './common/coverart');
import(/* webpackChunkName: "common-banner" */ './common/banner');
