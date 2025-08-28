/*
 * @flow strict
 * Copyright (C) 2022 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import {SanitizedCatalystContext} from '../../../context.mjs';
import formatUserDate from '../../../utility/formatUserDate.js';
import EditorLink from '../common/components/EditorLink.js';
import bracketed from '../common/utility/bracketed.js';
import parseInteger from '../common/utility/parseInteger.js';

/* eslint-disable ft-flow/sort-keys */
type ActionT =
  | {+type: 'update-new', +index: number}
  | {+type: 'update-old', +index: number}
;
/* eslint-enable ft-flow/sort-keys */

type StateT = {
  +selectedNew: number,
  +selectedOld: number,
};

type WritableStateT = {...StateT}; // this has writable properties

function createInitialState() {
  return {
    // These default indices are only used if canCompare is true below
    selectedNew: 0,
    selectedOld: 1,
  };
}

function reducer(state: StateT, action: ActionT): StateT {
  const newState: WritableStateT = {...state};
  match (action) {
    {type: 'update-new', const index} => {
      newState.selectedNew = index;
    }
    {type: 'update-old', const index} => {
      newState.selectedOld = index;
    }
  }
  return newState;
}

component AnnotationHistoryTable(
  annotations: $ReadOnlyArray<AnnotationT>,
  baseUrl: string,
) {
  const $c = React.useContext(SanitizedCatalystContext);

  const canCompare = annotations.length > 1;

  const [state, dispatch] = React.useReducer(
    reducer,
    null,
    createInitialState,
  );

  const handleNew = React.useCallback((
    event: SyntheticEvent<HTMLInputElement>,
  ) => {
    dispatch({
      index: parseInteger(event.currentTarget.dataset.index),
      type: 'update-new',
    });
  }, [dispatch]);

  const handleOld = React.useCallback((
    event: SyntheticEvent<HTMLInputElement>,
  ) => {
    dispatch({
      index: parseInteger(event.currentTarget.dataset.index),
      type: 'update-old',
    });
  }, [dispatch]);

  return (
    <table className="tbl" id="annotation-history">
      <thead>
        <tr>
          {canCompare ? (
            <>
              <th className="pos">{lp('Old', 'annotation')}</th>
              <th className="pos">{lp('New', 'annotation')}</th>
            </>
          ) : null}
          <th>{l('Editor')}</th>
          <th>{l('Date')}</th>
          <th>{l('Version history')}</th>
        </tr>
      </thead>
      <tbody>
        {annotations.map((annotation, index) => (
          <tr key={annotation.id}>
            {canCompare ? (
              <>
                <td>
                  <input
                    className="old"
                    data-index={index}
                    defaultChecked={index === 1}
                    disabled={index <= state.selectedNew}
                    name="old"
                    onClick={handleOld}
                    type="radio"
                    value={annotation.id}
                  />
                </td>
                <td>
                  <input
                    className="new"
                    data-index={index}
                    defaultChecked={index === 0}
                    disabled={index >= state.selectedOld}
                    name="new"
                    onClick={handleNew}
                    type="radio"
                    value={annotation.id}
                  />
                </td>
              </>
            ) : null}
            <td>
              <EditorLink editor={annotation.editor} />
            </td>
            <td>
              {formatUserDate($c, annotation.creation_date)}
            </td>
            <td>
              <a href={`${baseUrl}/annotation/${annotation.id}`}>
                {l('View this version')}
              </a>
              {' '}
              {bracketed(
                annotation.changelog ||
                exp.l('<em>no changelog specified</em>'),
              )}
            </td>
          </tr>
        ))}
      </tbody>
    </table>
  );
}

export default (hydrate<React.PropsOf<AnnotationHistoryTable>>(
  'div.annotation-history-table',
  AnnotationHistoryTable,
): component(...React.PropsOf<AnnotationHistoryTable>));
