require('./edit');

require('./edit/confirmNavigationFallback');

// The order here is important!
require('./release-editor/viewModel');
require('./release-editor/utils');
require('./release-editor/actions');
require('./release-editor/bubbles');
require('./release-editor/dialogs');
require('./release-editor/duplicates');
require('./release-editor/edits');
require('./release-editor/fields');
require('./release-editor/bindingHandlers');
require('./release-editor/init');
require('./release-editor/recordingAssociation');
require('./release-editor/seeding');
require('./release-editor/trackParser');
require('./release-editor/validation');
