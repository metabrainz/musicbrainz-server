/*
 * @flow
 * Copyright (C) 2019 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import React from 'react';

import {withCatalystContext} from '../../context';
import loopParity from '../../utility/loopParity';
import ArtistCreditLink
  from '../../static/scripts/common/components/ArtistCreditLink';
import CodeLink from '../../static/scripts/common/components/CodeLink';
import EntityLink from '../../static/scripts/common/components/EntityLink';
import ExpandedArtistCredit
  from '../../static/scripts/common/components/ExpandedArtistCredit';
import formatTrackLength
  from '../../static/scripts/common/utility/formatTrackLength';
import renderMergeCheckboxElement
  from '../../static/scripts/common/utility/renderMergeCheckboxElement';
import InstrumentRelTypes from '../InstrumentRelTypes';
import RatingStars from '../RatingStars';
import RemoveFromMergeTableCell from '../RemoveFromMergeTableCell';
import RemoveFromMergeTableHeader from '../RemoveFromMergeTableHeader';
import SortableTableHeader from '../SortableTableHeader';

type Props = {
  ...InstrumentCreditsAndRelTypesRoleT,
  ...SeriesItemNumbersRoleT,
  +$c: CatalystContextT,
  +checkboxes?: string,
  +lengthClass?: string,
  +mergeForm?: MergeFormT,
  +order?: string,
  +recordings: $ReadOnlyArray<RecordingT>,
  +showExpandedArtistCredits?: boolean,
  +showInstrumentCreditsAndRelTypes?: boolean,
  +showRatings?: boolean,
  +sortable?: boolean,
};

const RecordingList = ({
  $c,
  checkboxes,
  instrumentCreditsAndRelTypes,
  lengthClass,
  mergeForm,
  order,
  recordings,
  seriesItemNumbers,
  showExpandedArtistCredits,
  showInstrumentCreditsAndRelTypes,
  showRatings,
  sortable,
}: Props) => (
  <table className="tbl">
    <thead>
      <tr>
        {$c.user_exists && (checkboxes || mergeForm) ? (
          <th className="checkbox-cell">
            {mergeForm ? null : <input type="checkbox" />}
          </th>
        ) : null}
        {seriesItemNumbers ? <th style={{width: '1em'}}>{l('#')}</th> : null}
        <th>
          {sortable
            ? (
              <SortableTableHeader
                label={l('Name')}
                name="name"
                order={order}
              />
            )
            : l('Name')}
        </th>
        <th>
          {sortable
            ? (
              <SortableTableHeader
                label={l('Artist')}
                name="artist"
                order={order}
              />
            )
            : l('Artist')}
        </th>
        <th>{l('ISRCs')}</th>
        {showRatings ? <th>{l('Rating')}</th> : null}
        <th>
          {sortable
            ? (
              <SortableTableHeader
                label={l('Length')}
                name="length"
                order={order}
              />
            )
            : l('Length')}
        </th>
        {showInstrumentCreditsAndRelTypes
          ? <th>{l('Relationship Types')}</th>
          : null}
        {mergeForm
          ? <RemoveFromMergeTableHeader toMerge={recordings} />
          : null}
      </tr>
    </thead>
    <tbody>
      {recordings.map((recording, index) => (
        <tr className={loopParity(index)} key={recording.id}>
          {$c.user_exists && (checkboxes || mergeForm) ? (
            <td>
              {mergeForm
                ? renderMergeCheckboxElement(recording, mergeForm, index)
                : (
                  <input
                    name={checkboxes}
                    type="checkbox"
                    value={recording.id}
                  />
                )}
            </td>
          ) : null}
          {seriesItemNumbers ? (
            <td style={{width: '1em'}}>
              {seriesItemNumbers[recording.id]}
            </td>
          ) : null}
          <td>
            <EntityLink entity={recording} />
          </td>
          <td>
            {recording.artistCredit ? (
              showExpandedArtistCredits ? (
                <ExpandedArtistCredit artistCredit={recording.artistCredit} />
              ) : (
                <ArtistCreditLink artistCredit={recording.artistCredit} />
              )
            ) : null}
          </td>
          <td>
            <ul>
              {recording.isrcs.map(isrc => (
                <li key={isrc.isrc}>
                  <CodeLink code={isrc} />
                </li>
              ))}
            </ul>
          </td>
          {showRatings ? (
            <td>
              <RatingStars entity={recording} />
            </td>
          ) : null}
          <td className={lengthClass || null}>
            {/* Show nothing rather than ?:?? for recordings merged away */}
            {recording.gid ? formatTrackLength(recording.length) : null}
          </td>
          {showInstrumentCreditsAndRelTypes ? (
            <td>
              <InstrumentRelTypes
                entity={recording}
                instrumentCreditsAndRelTypes={instrumentCreditsAndRelTypes}
              />
            </td>
          ) : null}
          {mergeForm ? (
            <RemoveFromMergeTableCell
              entity={recording}
              toMerge={recordings}
            />
          ) : null}
        </tr>
      ))}
    </tbody>
  </table>
);

export default withCatalystContext(RecordingList);
