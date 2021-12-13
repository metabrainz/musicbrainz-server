/*
 * @flow strict-local
 * Copyright (C) 2020 Anirudh Jain
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import {
  artistBeginAreaLabel,
  artistBeginLabel,
  artistEndAreaLabel,
  artistEndLabel,
} from '../../artist/utils';
import Diff from '../../static/scripts/edit/components/edit/Diff';
import EntityLink from '../../static/scripts/common/components/EntityLink';
import FullChangeDiff
  from '../../static/scripts/edit/components/edit/FullChangeDiff';
import WordDiff from '../../static/scripts/edit/components/edit/WordDiff';
import DescriptiveLink
  from '../../static/scripts/common/components/DescriptiveLink';
import formatDate from '../../static/scripts/common/utility/formatDate';
import yesNo from '../../static/scripts/common/utility/yesNo';
import {commaOnlyListText}
  from '../../static/scripts/common/i18n/commaOnlyList';

type Props = {
  +edit: EditArtistEditT,
};

const EditArtist = ({edit}: Props): React.MixedElement => {
  const display = edit.display_data;
  const area = display.area;
  const beginDate = display.begin_date;
  const beginArea = display.begin_area;
  const comment = display.comment;
  const endDate = display.end_date;
  const endArea = display.end_area;
  const ended = display.ended;
  const gender = display.gender;
  const ipiCodes = display.ipi_codes;
  const isniCodes = display.isni_codes;
  const name = display.name;
  const sortName = display.sort_name;
  const type = display.type;
  const displayTypeId =
    (type?.new?.id) ??
    (type?.old?.id) ??
    display.artist.typeID;
  return (
    <>
      <table className="details">
        <tbody>
          <tr>
            <th>{addColonText(l('Artist'))}</th>
            <td><EntityLink entity={display.artist} /></td>
          </tr>
        </tbody>
      </table>
      <table className="details edit-artist">
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
                type.new ? lp_attributes(type.new.name, 'artist_type') : ''}
              oldContent={
                type.old ? lp_attributes(type.old.name, 'artist_type') : ''}
            />
          ) : null}
          {gender ? (
            <FullChangeDiff
              label={addColonText(l('Gender'))}
              newContent={
                gender.new?.name
                  ? lp_attributes(gender.new.name, 'gender')
                  : ''}
              oldContent={
                gender.old?.name
                  ? lp_attributes(gender.old.name, 'gender')
                  : ''}
            />
          ) : null}
          {area ? (
            <FullChangeDiff
              label={addColonText(l('Area'))}
              newContent={
                area.new ? <DescriptiveLink entity={area.new} /> : null}
              oldContent={
                area.old ? <DescriptiveLink entity={area.old} /> : null}
            />
          ) : null}
          {beginDate ? (
            <Diff
              label={artistBeginLabel(displayTypeId)}
              newText={formatDate(beginDate.new)}
              oldText={formatDate(beginDate.old)}
              split="-"
            />
          ) : null}
          {beginArea ? (
            <FullChangeDiff
              label={artistBeginAreaLabel(displayTypeId)}
              newContent={
                beginArea.new
                  ? <DescriptiveLink entity={beginArea.new} />
                  : null}
              oldContent={
                beginArea.old
                  ? <DescriptiveLink entity={beginArea.old} />
                  : null}
            />
          ) : null}
          {endDate ? (
            <Diff
              label={artistEndLabel(displayTypeId)}
              newText={formatDate(endDate.new)}
              oldText={formatDate(endDate.old)}
              split="-"
            />
          ) : null}
          {endArea ? (
            <FullChangeDiff
              label={artistEndAreaLabel(displayTypeId)}
              newContent={
                endArea.new ? <DescriptiveLink entity={endArea.new} /> : null}
              oldContent={
                endArea.old ? <DescriptiveLink entity={endArea.old} /> : null}
            />
          ) : null}
          {ended ? (
            <FullChangeDiff
              label={addColonText(l('Ended'))}
              newContent={yesNo(ended.new)}
              oldContent={yesNo(ended.old)}
            />
          ) : null}
          {ipiCodes ? (
            <Diff
              label={l('IPI codes:')}
              newText={ipiCodes.new ? commaOnlyListText(ipiCodes.new) : ''}
              oldText={ipiCodes.old ? commaOnlyListText(ipiCodes.old) : ''}
              split=", "
            />
          ) : null}
          {isniCodes ? (
            <Diff
              label={l('ISNI codes:')}
              newText={isniCodes.new ? commaOnlyListText(isniCodes.new) : ''}
              oldText={isniCodes.old ? commaOnlyListText(isniCodes.old) : ''}
              split=", "
            />
          ) : null}
        </tbody>
      </table>
    </>
  );
};

export default EditArtist;
