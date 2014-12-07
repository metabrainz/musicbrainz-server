var filesize = require("../lib/filesize.js/lib/filesize.js");
window.filesize = filesize;

require("../lib/json/json2.js");

var sha1 = require("../lib/sha1/sha1.js");
window.hex_sha1 = sha1.hex_sha1;
window.rstr_sha1 = sha1.rstr_sha1;

require("knockout-arrayTransforms");
require("knockout-delegatedEvents");
require("knockout-postbox");

require("./relationship-editor/common/fields.js");
require("./relationship-editor/common/viewModel.js");
require("./relationship-editor/common/entity.js");
require("./relationship-editor/common/dialog.js");
require("./relationship-editor/generic.js");
require("./relationship-editor/release.js");

require("./edit/common.js");
require("./edit/confirmNavigationFallback.js");
require("./edit/ExampleRelationships.js");
require("./edit/externalLinks.js");
require("./edit/forms.js");
require("./edit/MB/Control/Area.js");
require("./edit/MB/Control/ArtistCredit.js");
require("./edit/MB/Control/ArtistEdit.js");
require("./edit/MB/Control/Bubble.js");
require("./edit/MB/Control/URLCleanup.js");
require("./edit/MB/CoverArt.js");
require("./edit/MB/edit.js");
require("./edit/MB/reltypeslist.js");
require("./edit/MB/TextList.js");
require("./edit/WorkAttributes.js");
