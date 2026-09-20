/*
 * @flow strict-local
 * Copyright (C) 2021 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import {
  hydrateRelationshipEditorForm,
} from '../../edit/components/withLoadedTypeInfo.js';
import getUnicodeUrl
  from '../../external-links-editor/utility/getUnicodeUrl.js';
import {
  type InitialStateArgsT,
  loadOrCreateInitialState,
  reducer,
} from '../../relationship-editor/components/RelationshipEditor.js';
import RelationshipEditorFieldset
  from '../../relationship-editor/components/RelationshipEditorFieldset.js';
import useEntityNameFromField
  from '../../relationship-editor/hooks/useEntityNameFromField.js';
import type {
  RelationshipEditorActionT,
} from '../../relationship-editor/types/actions.js';

type PropsT = InitialStateArgsT;

component _UrlRelationshipEditor(...props: PropsT) {
  const [state, dispatch] = React.useReducer(
    reducer,
    props,
    loadOrCreateInitialState,
  );

  useEntityNameFromField(
    'url',
    'id-edit-url.url',
    dispatch,
    getUnicodeUrl,
  );

  React.useEffect(() => {
    const urlControl = document.getElementById('id-edit-url.url');

    function handleUrlChange(this: HTMLInputElement) {
      this.value = getUnicodeUrl(this.value);
    }

    // $FlowFixMe[incompatible-type]
    urlControl?.addEventListener('change', handleUrlChange);

    return () => {
      // $FlowFixMe[incompatible-type]
      urlControl?.removeEventListener('change', handleUrlChange);
    };
  }, []);

  const relationshipEditorFieldsetDispatch = React.useCallback((
    action: {
      readonly action: RelationshipEditorActionT,
      readonly type: 'update-relationship-editor',
    },
  ) => {
    dispatch(action.action);
  }, [dispatch]);

  return (
    <RelationshipEditorFieldset
      dispatch={relationshipEditorFieldsetDispatch}
      formName={props.formName}
      state={state}
    />
  );
}

const UrlRelationshipEditor = hydrateRelationshipEditorForm<PropsT>(
  'div.relationship-editor',
  _UrlRelationshipEditor,
) as component(...PropsT);

export default UrlRelationshipEditor;
