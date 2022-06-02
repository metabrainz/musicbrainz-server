/*
 * NOTE: Please don't import anything into this file unless it truly needs
 * to run on every single page.
 */

import {
  onDOMContentLoaded as bootstrapOnDOMContentLoaded,
} from 'bootstrap/js/src/util/index';

/* eslint-disable import/no-commonjs */

import MB from './common/MB';

/* Global polyfills not provided by core-js */
require('whatwg-fetch');
require('./common/focusin-focusout-polyfill');
/* End of global polyfills */

require('./public-path');

const DBDefs = require('./common/DBDefs-client');

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

require('bootstrap/js/src/dropdown');

bootstrapOnDOMContentLoaded(() => {
  /*
   * Bootstrap's jQuery plugins may conflict with those added by jQuery UI,
   * and we don't need to access them in plugin form, so just call
   * `noConflict` on all of them.
   *
   * The plugins are registered by Bootstrap in an `onDOMContentLoaded`
   * handler, so we're doing this inside our own handler to ensure the
   * plugins are defined first.
   */
  $.fn.dropdown.noConflict();
});

require('./common/components/Annotation');
require('./common/components/CommonsImage');
require('./common/components/FingerprintTable');
require('./common/components/WikipediaExtract');
require('./common/MB/Control/Autocomplete');
require('./common/MB/Control/SelectAll');
require('./common/components/TagEditor');

import('./common/artworkViewer');
import('./common/dialogs');
import('./common/components/Filter');
import('./common/MB/Control/Menu');
import('./common/MB/edit_search');
import('./common/ratings');
import('./common/coverart');
import('./common/banner');
