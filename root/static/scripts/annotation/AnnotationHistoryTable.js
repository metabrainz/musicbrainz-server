/*
 * @flow
 * Copyright (C) 2022 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import EditorLink from '../common/components/EditorLink';
import bracketed from '../common/utility/bracketed';
import formatUserDate from '../../../utility/formatUserDate';

type Props = {
  +$c: CatalystContextT,
  +annotations: $ReadOnlyArray<AnnotationT>,
  +baseUrl: string,
};

/* eslint-disable flowtype/sort-keys */
type ActionT =
  | {+type: 'update-new', +annotationId: number}
  | {+type: 'update-old', +annotationId: number}
;
/* eslint-enable flowtype/sort-keys */

type StateT = {
  +selectedNew: number,
  +selectedOld: number,
};

type WritableStateT = {...StateT}; // this has writable properties

function createInitialState(annotations) {
  return {
    selectedNew: annotations[0]?.id ?? 0,
    selectedOld: annotations[1]?.id ?? 0,
  };
}

function reducer(state: StateT, action: ActionT): StateT {
  const newState: WritableStateT = {...state};
  switch (action.type) {
    case 'update-new': {
      newState.selectedNew = action.annotationId;
      break;
    }
    case 'update-old': {
      newState.selectedOld = action.annotationId;
      break;
    }
    default: {
      /*:: exhaustive(action); */
    }
  }
  return newState;
}

const AnnotationHistoryTable = ({
  $c,
  annotations,
  baseUrl,
}: Props): React.Element<'table'> => {
  const canCompare = annotations.length > 1;

  const [state, dispatch] = React.useReducer(
    reducer,
    createInitialState(annotations),
  );

  const handleNew = React.useCallback((event) => {
    dispatch({annotationId: event.currentTarget.value, type: 'update-new'});
  }, [dispatch]);

  const handleOld = React.useCallback((event) => {
    dispatch({annotationId: event.currentTarget.value, type: 'update-old'});
  }, [dispatch]);

  return (
    <table className="tbl" id="annotation-history">
      <thead>
        <tr>
          {canCompare ? (
            <>
              <th className="pos">{l('Old')}</th>
              <th className="pos">{l('New')}</th>
            </>
          ) : null}
          <th>{l('Editor')}</th>
          <th>{l('Date')}</th>
          <th>{l('Version History')}</th>
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
                    defaultChecked={index === 1}
                    disabled={annotation.id >= state.selectedNew}
                    name="old"
                    onClick={handleOld}
                    type="radio"
                    value={annotation.id}
                  />
                </td>
                <td>
                  <input
                    className="new"
                    defaultChecked={index === 0}
                    disabled={annotation.id <= state.selectedOld}
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
};

export default (hydrate<Props>(
  'div.annotation-history-table',
  AnnotationHistoryTable,
): React.AbstractComponent<Props, void>);
