/*
 * @flow strict
 * Copyright (C) 2020 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import DescriptiveLink
  from '../../static/scripts/common/components/DescriptiveLink.js';
import {commaOnlyListText}
  from '../../static/scripts/common/i18n/commaOnlyList.js';
import formatDate from '../../static/scripts/common/utility/formatDate.js';
import yesNo from '../../static/scripts/common/utility/yesNo.js';
import Diff from '../../static/scripts/edit/components/edit/Diff.js';
import FullChangeDiff
  from '../../static/scripts/edit/components/edit/FullChangeDiff.js';
import WordDiff from '../../static/scripts/edit/components/edit/WordDiff.js';

type Props = {
  +edit: EditAreaEditT,
};

const EditArea = ({edit}: Props): React.MixedElement => {
  const display = edit.display_data;
  const beginDate = display.begin_date;
  const comment = display.comment;
  const endDate = display.end_date;
  const ended = display.ended;
  const iso31661 = display.iso_3166_1;
  const iso31662 = display.iso_3166_2;
  const iso31663 = display.iso_3166_3;
  const name = display.name;
  const sortName = display.sort_name;
  const type = display.type;

  return (
    <>
      <table className="details">
        <tbody>
          <tr>
            <th>{addColonText(l('Area'))}</th>
            <td><DescriptiveLink entity={display.area} /></td>
          </tr>
        </tbody>
      </table>
      <table className="details edit-area">
        <tbody>
          {name ? (
            <WordDiff
              label={addColonText(l('Name'))}
              newText={name.new}
              oldText={name.old}
            />
          ) : null}
          {sortName ? (
            <WordDiff
              label={addColonText(l('Sort name'))}
              newText={sortName.new}
              oldText={sortName.old}
            />
          ) : null}
          {comment ? (
            <WordDiff
              label={addColonText(l('Disambiguation'))}
              newText={comment.new ?? ''}
              oldText={comment.old ?? ''}
            />
          ) : null}
          {type ? (
            <FullChangeDiff
              label={addColonText(l('Type'))}
              newContent={
                type.new ? lp_attributes(type.new.name, 'area_type') : ''}
              oldContent={
                type.old ? lp_attributes(type.old.name, 'area_type') : ''}
            />
          ) : null}
          {iso31661 ? (
            <Diff
              label={addColonText(l('ISO 3166-1'))}
              newText={iso31661.new ? commaOnlyListText(iso31661.new) : ''}
              oldText={iso31661.old ? commaOnlyListText(iso31661.old) : ''}
            />
          ) : null}
          {iso31662 ? (
            <Diff
              label={addColonText(l('ISO 3166-2'))}
              newText={iso31662.new ? commaOnlyListText(iso31662.new) : ''}
              oldText={iso31662.old ? commaOnlyListText(iso31662.old) : ''}
            />
          ) : null}
          {iso31663 ? (
            <Diff
              label={addColonText(l('ISO 3166-3'))}
              newText={iso31663.new ? commaOnlyListText(iso31663.new) : ''}
              oldText={iso31663.old ? commaOnlyListText(iso31663.old) : ''}
            />
          ) : null}
          {beginDate ? (
            <Diff
              label={addColonText(l('Begin date'))}
              newText={formatDate(beginDate.new)}
              oldText={formatDate(beginDate.old)}
              split="-"
            />
          ) : null}
          {endDate ? (
            <Diff
              label={addColonText(l('End date'))}
              newText={formatDate(endDate.new)}
              oldText={formatDate(endDate.old)}
              split="-"
            />
          ) : null}
          {ended ? (
            <FullChangeDiff
              label={addColonText(l('Ended'))}
              newContent={yesNo(ended.new)}
              oldContent={yesNo(ended.old)}
            />
          ) : null}
        </tbody>
      </table>
    </>
  );
};

export default EditArea;
