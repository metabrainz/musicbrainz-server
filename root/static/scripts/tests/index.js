require('../common');
require('../edit');
require('../guess-case');
require('../release-editor');

MB.edit.preview = function (data, context) {
  return $.Deferred().resolveWith(context, [{ previews: [] }, data]);
};

MB.edit.create = function (data, context) {
  return $.Deferred().resolveWith(context, [{ edits: [] }, data]);
};

require('./typeInfo');

require('./autocomplete');
require('./Control/ArtistCredit');
require('./Control/URLCleanup');
require('./CoverArt');
require('./edit');
require('./entity');
require('./externalLinks');
require('./GuessCase');
require('./guessFeat');
require('./i18n');
require('./relationship-editor');
require('./release-editor/actions');
require('./release-editor/bubbles');
require('./release-editor/common');
require('./release-editor/dialogs');
require('./release-editor/edits');
require('./release-editor/fields');
require('./release-editor/trackParser');
require('./release-editor/validation');
require('./release-editor/utils');
require('./utility');
