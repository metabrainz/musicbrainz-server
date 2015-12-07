import global from './global';

var sha1 = require("../lib/sha1/sha1.js");
global.hex_sha1 = sha1.hex_sha1;
global.rstr_sha1 = sha1.rstr_sha1;

require("knockout-arraytransforms");
require("../lib/knockout/knockout-delegatedEvents.js");

require("./relationship-editor/common/multiselect.js");
require("./relationship-editor/common/fields.js");
require("./relationship-editor/common/viewModel.js");
require("./relationship-editor/common/entity.js");
require("./relationship-editor/common/dialog.js");
require("./relationship-editor/generic.js");
require("./relationship-editor/release.js");

require("./edit/common.js");
require("./edit/confirmNavigationFallback.js");
require("./edit/ExampleRelationships.js");
require("./edit/forms.js");
require("./edit/validation.js");
require("./edit/externalLinks.js");
require("./edit/utility/guessFeat");
require("./edit/MB/Control/Area.js");
require("./edit/MB/Control/ArtistCredit.js");
require("./edit/MB/Control/ArtistEdit.js");
require("./edit/MB/Control/Bubble.js");
require("./edit/URLCleanup.js");
require("./edit/MB/CoverArt.js");
require("./edit/MB/edit.js");
require("./edit/MB/reltypeslist.js");
require("./edit/MB/TextList.js");
require("./edit/check-duplicates.js");
