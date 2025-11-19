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

import RelationshipEditor, {
  type InitialStateArgsT,
  loadOrCreateInitialState,
  reducer,
} from './RelationshipEditor.js';

/*
 * Wraps the relationship editor component to provide it with state and
 * hydration.
 *
 * TODO: Pass state/dispatch in from the edit form once that's written, and
 * perform hydration there. This component can then be removed.
 *
 * N.B. For series, use
 * root/static/scripts/series/components/SeriesRelationshipEditor.js instead.
 */

type PropsT = InitialStateArgsT;

component _RelationshipEditorWrapper(
  /*
   * Hack required due to withLoadedTypeInfo's use of `forwardRef`.
   * Remove once we upgrade to React v19.
   */
  // eslint-disable-next-line no-unused-vars
  ref: React.RefSetter<mixed>,
  ...props: PropsT
) {
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

  return (
    <RelationshipEditor
      dispatch={dispatch}
      formName={props.formName}
      state={state}
    />
  );
}

export const NonHydratedRelationshipEditorWrapper:
  component(ref: React.RefSetter<mixed>, ...PropsT) =
    withLoadedTypeInfoForRelationshipEditor<PropsT>(
      _RelationshipEditorWrapper,
    );

const RelationshipEditorWrapper = (hydrate<PropsT>(
  'div.relationship-editor',
  NonHydratedRelationshipEditorWrapper,
): component(...PropsT));

export default RelationshipEditorWrapper;
