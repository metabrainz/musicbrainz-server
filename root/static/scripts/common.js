import global from './global';

global.aclass = require("aclass");
global.ko = require("knockout");
global.L = require("../lib/leaflet/leaflet-src");
global._ = require("lodash");
global.$ = global.jQuery = require("jquery");

require("jquery.browser");
require("../lib/jquery.ui/ui/jquery-ui.custom.js");

require("./common/MB.js");
require("./common/i18n.js");
require("./common/text-collapse.js");
require("./common/artworkViewer.js");
require("./common/dialogs.js");
require("./common/entity.js");
require("./common/MB/Control/Autocomplete.js");
require("./common/MB/Control/Filter.js");
require("./common/MB/Control/Menu.js");
require("./common/MB/Control/SelectAll.js");
require("./common/MB/edit_search.js");
require("./common/MB/release.js");
require("./common/ratings.js");
require("./common/tagger.js");
require("./common/coverart.js");
require("./common/banner.js");
require("./common/components/TagEditor.js");

if (typeof phantom === 'undefined') {
    require("./common/errors.js");
}
