/*
 * NOTE: Please don't import anything into this file unless it truly needs
 * to run on every single page.
 */

/* eslint-disable import/no-commonjs */

window.$ = window.jQuery = require('jquery');

require('./common/components/WikipediaExtract.js');
require('./common/MB/Control/Autocomplete.js');
require('./common/MB/Control/SelectAll.js');
require('./common/components/TagEditor.js');

import('./common/artworkViewer.js');
import('./common/dialogs.js');
import('./common/components/Filter.js');
import('./common/MB/Control/Menu.js');
import('./common/MB/edit_search.js');
import('./common/ratings.js');
import('./common/coverart.js');
import('./common/banner.js');
