// IE 11 support.
import 'core-js/modules/es6.object.assign';
import 'core-js/modules/es6.array.from';
import 'core-js/modules/es6.array.iterator';
import 'core-js/modules/es6.string.iterator';
import 'core-js/es6/set';
import 'core-js/es6/map';
import 'core-js/es6/promise';
import 'core-js/es6/symbol';

import * as DBDefs from './common/DBDefs';
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

window.ko = require("knockout");
window._ = require("lodash");
window.$ = window.jQuery = require("jquery");

require("../lib/jquery.ui/ui/jquery-ui.custom");

require("./common/components/Annotation");
require("./common/components/CommonsImage");
require("./common/components/WikipediaExtract");
require("./common/i18n");
require("./common/artworkViewer");
require("./common/dialogs");
require("./common/entity");
require("./common/MB/Control/Autocomplete");
require("./common/MB/Control/Filter");
require("./common/MB/Control/Menu");
require("./common/MB/Control/SelectAll");
require("./common/MB/edit_search");
require("./common/MB/release");
require("./common/ratings");
require("./common/tagger");
require("./common/coverart");
require("./common/banner");
require("./common/components/TagEditor");
