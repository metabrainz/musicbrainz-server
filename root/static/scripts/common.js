const global = require('./global');

global.aclass = require("aclass");
global.ko = require("knockout");
global.L = require("../lib/leaflet/leaflet-src");
global._ = require("lodash");
global.$ = global.jQuery = require("jquery");

require("jquery.browser");
require("../lib/jquery.ui/ui/jquery-ui.custom");

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

if (typeof phantom === 'undefined') {
    require("./common/errors");
}
