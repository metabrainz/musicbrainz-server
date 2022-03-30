/*
 * NOTE: Please don't import anything into this file unless it truly needs
 * to run on every single page.
 */

import {
  onDOMContentLoaded as bootstrapOnDOMContentLoaded,
} from 'bootstrap/js/src/util/index';

/* eslint-disable import/no-commonjs */

/* Global polyfills not provided by core-js */
require('whatwg-fetch');
require('./common/focusin-focusout-polyfill');
/* End of global polyfills */

require('./public-path');
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

import('./common/artworkViewer.js');
import('./common/dialogs.js');
import('./common/components/Filter.js');
import('./common/MB/Control/Menu.js');
import('./common/MB/edit_search.js');
import('./common/ratings.js');
import('./common/coverart.js');
import('./common/banner.js');
