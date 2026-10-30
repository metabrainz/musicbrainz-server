/*
 * @flow strict-local
 * Copyright (C) 2026 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import type {RelationshipEditorStateT} from '../types.js';
import type {RelationshipEditorActionT} from '../types/actions.js';

import RelationshipEditor from './RelationshipEditor.js';

component RelationshipEditorFieldset(
  dispatch: (
    action: {
      readonly action: RelationshipEditorActionT,
      readonly type: 'update-relationship-editor',
    },
  ) => void,
  formName: string,
  state: RelationshipEditorStateT,
) {
  const relationshipEditorDispatch = React.useCallback((
    action: RelationshipEditorActionT,
  ) => {
    dispatch({action, type: 'update-relationship-editor'});
  }, [dispatch]);

  return (
    <fieldset id="relationship-editor">
      <legend>
        {l('Relationships')}
      </legend>

      <div className="relationship-editor-fieldset-content">
        <RelationshipEditor
          dispatch={relationshipEditorDispatch}
          formName={formName}
          state={state}
        />
      </div>
    </fieldset>
  );
}

export default RelationshipEditorFieldset;
