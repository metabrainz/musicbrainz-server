window.aclass = require("aclass");
window.ko = require("knockout");
window.L = require("leaflet");
window._ = require("lodash");
window._.str = require("underscore.string");
window.$ = window.jQuery = require("jquery");

require("jquery.browser");
require("../lib/jquery.ui/ui/jquery-ui.custom.js");

require("./common/MB.js");
require("./common/i18n.js");
require("./common/text-collapse.js");
require("./common/artworkViewer.js");
require("./common/dialogs.js");
require("./common/entity.js");
require("./common/MB/Control/Autocomplete.js");
require("./common/MB/Control/EditList.js");
require("./common/MB/Control/EditSummary.js");
require("./common/MB/Control/Filter.js");
require("./common/MB/Control/Menu.js");
require("./common/MB/Control/SelectAll.js");
require("./common/MB/Control/TagEditor.js");
require("./common/MB/edit_search.js");
require("./common/MB/release.js");
require("./common/ratings.js");
require("./common/tagger.js");
require("./common/coverart.js");

if (typeof phantom === 'undefined') {
    require("./common/errors.js");
}
