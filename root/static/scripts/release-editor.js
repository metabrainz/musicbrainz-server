/* eslint-disable import/no-commonjs */

require('./common/MB/Control/Autocomplete.js');

require('./edit/forms.js');

// eslint-disable-next-line @stylistic/max-len
require('./external-links-editor/components/StandaloneExternalLinksEditor.js');

// The order here is important!
require('./release-editor/viewModel.js');
require('./release-editor/utils.js');
require('./release-editor/actions.js');
require('./release-editor/bubbles.js');
require('./release-editor/dialogs.js');
require('./release-editor/duplicates.js');
require('./release-editor/edits.js');
require('./release-editor/fields.js');
require('./release-editor/bindingHandlers.js');
require('./release-editor/init.js');
require('./release-editor/recordingAssociation.js');
require('./release-editor/seeding.js');
require('./release-editor/trackParser.js');
require('./release-editor/validation.js');
