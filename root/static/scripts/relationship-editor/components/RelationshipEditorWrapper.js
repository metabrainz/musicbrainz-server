/*
 * @flow strict-local
 * Copyright (C) 2022 MetaBrainz Foundation
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
import useEntityNameFromField from '../hooks/useEntityNameFromField.js';
import type {RelationshipEditorActionT} from '../types/actions.js';

import {
  type InitialStateArgsT,
  loadOrCreateInitialState,
  reducer,
} from './RelationshipEditor.js';
import RelationshipEditorFieldset from './RelationshipEditorFieldset.js';

/*
 * Wraps the relationship editor component to provide it with state and
 * hydration.
 *
 * This is only intended to be used from root/forms/relationship-editor.tt!
 * Forms which have been fully converted to React do not need this.
 *
 * N.B. For series, use
 * root/static/scripts/series/components/SeriesRelationshipEditor.js instead.
 */

type PropsT = InitialStateArgsT;

component _RelationshipEditorWrapper(...props: PropsT) {
  const [state, dispatch] = React.useReducer(
    reducer,
    props,
    loadOrCreateInitialState,
  );

  useEntityNameFromField(
    state.entity.entityType,
    `id-${props.formName}.name`,
    dispatch,
  );

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

export const NonHydratedRelationshipEditorWrapper:
  component(...PropsT) =
    withLoadedTypeInfoForRelationshipEditor<PropsT>(
      _RelationshipEditorWrapper,
    );

const RelationshipEditorWrapper = hydrate<PropsT>(
  'div.relationship-editor',
  NonHydratedRelationshipEditorWrapper,
) as component(...PropsT);

export default RelationshipEditorWrapper;
