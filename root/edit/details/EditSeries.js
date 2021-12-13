/*
 * @flow strict-local
 * Copyright (C) 2020 Anirudh Jain
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import EntityLink from '../../static/scripts/common/components/EntityLink';
import FullChangeDiff from
  '../../static/scripts/edit/components/edit/FullChangeDiff';
import WordDiff from '../../static/scripts/edit/components/edit/WordDiff';

type Props = {
  +edit: EditSeriesEditT,
};

const EditSeries = ({edit}: Props): React.Element<'table'> => {
  const display = edit.display_data;
  const name = display.name;
  const series = display.series;
  const comment = display.comment;
  const type = display.type;
  const oldTypeName = type?.old.name ?? '';
  const newTypeName = type?.new.name ?? '';
  const orderingType = display.ordering_type;
  const oldOrderingTypeName = orderingType?.old.name ?? '';
  const newOrderingTypeName = orderingType?.new.name ?? '';
  return (
    <table className="details edit-series">
      <tbody>
        <tr>
          <th>{addColonText(l('Series'))}</th>
          <td colSpan="2">
            <EntityLink entity={series} />
          </td>
        </tr>
        {name ? (
          <WordDiff
            label={addColonText(l('Name'))}
            newText={name.new}
            oldText={name.old}
          />
        ) : null}
        {comment ? (
          <WordDiff
            label={addColonText(l('Disambiguation'))}
            newText={comment.new}
            oldText={comment.old}
          />
        ) : null}
        {type ? (
          <FullChangeDiff
            label={addColonText(l('Type'))}
            newContent={
              newTypeName ? lp_attributes(newTypeName, 'series_type') : ''
            }
            oldContent={
              oldTypeName ? lp_attributes(oldTypeName, 'series_type') : ''
            }
          />
        ) : null}
        {orderingType ? (
          <FullChangeDiff
            label={addColonText(l('Ordering Type'))}
            newContent={
              newOrderingTypeName
                ? lp_attributes(newOrderingTypeName, 'series_ordering_type')
                : ''
            }
            oldContent={
              oldOrderingTypeName
                ? lp_attributes(oldOrderingTypeName, 'series_ordering_type')
                : ''
            }
          />
        ) : null}
      </tbody>
    </table>
  );
};

export default EditSeries;
