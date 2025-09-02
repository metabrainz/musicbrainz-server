/*
 * @flow strict-local
 * Copyright (C) 2025 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import ExternalLinksEditor
  from '../components/ExternalLinksEditor.js';
import type {
  LinksEditorActionT,
  LinksEditorStateT,
} from '../types.js';
import {
  hasErrorsOnNewOrChangedLinks,
} from '../validation.js';

type ExternalLinksEditorHookResultT = {
  +element: React.MixedElement,
  +hasErrors: boolean,
};

export default function useExternalLinksEditor(
  state: {
    +externalLinksEditor: LinksEditorStateT,
    ...
  },
  dispatch: (
    action: {+
      action: LinksEditorActionT,
      +type: 'update-external-links-editor',
    },
  ) => void,
): ExternalLinksEditorHookResultT {
  const externalLinksEditorDispatch = React.useCallback((
    action: LinksEditorActionT,
  ) => {
    dispatch({action, type: 'update-external-links-editor'});
  }, [dispatch]);

  return {
    element: (
      <fieldset>
        <legend>{'External links'}</legend>
        <ExternalLinksEditor
          dispatch={externalLinksEditorDispatch}
          state={state.externalLinksEditor}
        />
      </fieldset>
    ),
    hasErrors: hasErrorsOnNewOrChangedLinks(
      state.externalLinksEditor.links,
    ),
  };
}
