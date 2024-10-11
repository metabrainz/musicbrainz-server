/*
 * @flow strict-local
 * Copyright (C) 2021 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import hydrate from '../../../../utility/hydrate.js';
import {
  withLoadedTypeInfoForRelationshipEditor,
} from '../../edit/components/withLoadedTypeInfo.js';
import {getUnicodeUrl} from '../../edit/externalLinks.js';
import RelationshipEditor, {
  type InitialStateArgsT,
  loadOrCreateInitialState,
  reducer,
} from '../../relationship-editor/components/RelationshipEditor.js';
import useEntityNameFromField
  from '../../relationship-editor/hooks/useEntityNameFromField.js';

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

    urlControl?.addEventListener('change', handleUrlChange);

    return () => {
      urlControl?.removeEventListener('change', handleUrlChange);
    };
  }, []);

  return (
    <RelationshipEditor
      dispatch={dispatch}
      formName={props.formName}
      state={state}
    />
  );
}

const NonHydratedUrlRelationshipEditor: React.AbstractComponent<PropsT> =
  withLoadedTypeInfoForRelationshipEditor<PropsT>(
    _UrlRelationshipEditor,
  );

const UrlRelationshipEditor = (hydrate<PropsT>(
  'div.relationship-editor',
  NonHydratedUrlRelationshipEditor,
): React.AbstractComponent<PropsT>);

export default UrlRelationshipEditor;
