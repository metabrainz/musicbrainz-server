/*
 * NOTE: Please don't import anything into this file unless it truly needs
 * to run on every single page.
 */

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
