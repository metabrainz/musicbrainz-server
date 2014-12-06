require('./common.js')
require('./edit.js');
require('./guess-case.js');
require('./release-editor.js');

MB.edit.preview = function (data, context) {
  return $.Deferred().resolveWith(context, [{ previews: [] }, data]);
};

MB.edit.create = function (data, context) {
  return $.Deferred().resolveWith(context, [{ edits: [] }, data]);
};

require('../tests/text.js');
require('./tests/typeInfo.js');

require('./tests/autocomplete.js');
require('./tests/Control/ArtistCredit.js');
require('./tests/Control/URLCleanup.js');
require('./tests/CoverArt.js');
require('./tests/edit.js');
require('./tests/entity.js');
require('./tests/externalLinks.js');
require('./tests/GuessCase.js');
require('./tests/i18n.js');
require('./tests/relationship-editor.js');
require('./tests/release-editor/actions.js');
require('./tests/release-editor/bubbles.js');
require('./tests/release-editor/common.js');
require('./tests/release-editor/dialogs.js');
require('./tests/release-editor/edits.js');
require('./tests/release-editor/fields.js');
require('./tests/release-editor/trackParser.js');
require('./tests/release-editor/validation.js');
require('./tests/utility.js');
