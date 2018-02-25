// IE 11 doesn't support Object.assign.
require('core-js/modules/es6.object.assign');

const DBDefs = require('./common/DBDefs');
const MB = require('./common/MB');

if (DBDefs.DEVELOPMENT_SERVER) {
  // Used by the Selenium tests under /t/selenium/ to make sure that no errors
  // occurred on the page.
  MB.js_errors = [];
  window.onerror = function (err) {
    MB.js_errors.push(err);
  };
}

require('./common/raven');

window.ko = require("knockout");
window._ = require("lodash");
window.$ = window.jQuery = require("jquery");

require("../lib/jquery.ui/ui/jquery-ui.custom");

require("./common/i18n");
require("./common/text-collapse");
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
