/*
 * @flow strict-local
 * Copyright (C) 2025 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import type {
  LinksEditorActionT,
  LinksEditorStateT,
} from '../types.js';

import ExternalLinksEditor from './ExternalLinksEditor.js';

component ExternalLinksEditorFieldset(
  dispatch: (
    action: {+
      action: LinksEditorActionT,
      +type: 'update-external-links-editor',
    },
  ) => void,
  state: LinksEditorStateT,
) {
  const externalLinksEditorDispatch = React.useCallback((
    action: LinksEditorActionT,
  ) => {
    dispatch({action, type: 'update-external-links-editor'});
  }, [dispatch]);

  return (
    <fieldset>
      <legend>{l('External links')}</legend>
      <ExternalLinksEditor
        dispatch={externalLinksEditorDispatch}
        state={state}
      />
    </fieldset>
  );
}

export default ExternalLinksEditorFieldset;
