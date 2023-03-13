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

let UrlRelationshipEditor:
  React$AbstractComponent<PropsT, void> =
(props: PropsT) => {
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

    const handleUrlChange = function (this: HTMLInputElement) {
      /* eslint-disable react/no-this-in-sfc */
      this.value = getUnicodeUrl(this.value);
      /* eslint-enable react/no-this-in-sfc */
    };

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
};

UrlRelationshipEditor =
  withLoadedTypeInfoForRelationshipEditor<PropsT, void>(
    UrlRelationshipEditor,
  );

UrlRelationshipEditor = hydrate<PropsT>(
  'div.relationship-editor',
  UrlRelationshipEditor,
);

export default UrlRelationshipEditor;
