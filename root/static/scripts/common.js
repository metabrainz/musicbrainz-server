let RUNNING_TESTS = false;

try {
  if (String(process.env.MUSICBRAINZ_RUNNING_TESTS) === '1') {
    RUNNING_TESTS = true
  }
} catch (e) {}

if (!RUNNING_TESTS) {
  require('./common/raven');
}

const global = require('./global');

global.aclass = require("aclass");
global.ko = require("knockout");
global._ = require("lodash");
global.$ = global.jQuery = require("jquery");

require("jquery.browser");
require("../lib/jquery.ui/ui/jquery-ui.custom");

require("./common/DBDefs");
require("./common/MB");
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
