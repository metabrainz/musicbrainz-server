const global = require('./global');

const sha1 = require("../lib/sha1/sha1");
global.hex_sha1 = sha1.hex_sha1;
global.rstr_sha1 = sha1.rstr_sha1;

require("knockout-arraytransforms");
require("../lib/knockout/knockout-delegatedEvents");

require("./relationship-editor/common/multiselect");
require("./relationship-editor/common/fields");
require("./relationship-editor/common/viewModel");
require("./relationship-editor/common/entity");
require("./relationship-editor/common/dialog");
require("./relationship-editor/generic");
require("./relationship-editor/release");

require("./edit/common");
require("./edit/confirmNavigationFallback");
require("./edit/ExampleRelationships");
require("./edit/forms");
require("./edit/validation");
require("./edit/externalLinks");
require("./edit/utility/guessFeat");
require("./edit/MB/Control/Area");
require("./edit/MB/Control/ArtistCredit");
require("./edit/MB/Control/ArtistEdit");
require("./edit/MB/Control/Bubble");
require("./edit/URLCleanup");
require("./edit/MB/CoverArt");
require("./edit/MB/edit");
require("./edit/MB/reltypeslist");
require("./edit/MB/TextList");
require("./edit/check-duplicates");
