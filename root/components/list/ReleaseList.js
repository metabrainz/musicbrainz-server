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
import InstrumentRelTypes from '../InstrumentRelTypes';
import ReleaseCatnoList from '../ReleaseCatnoList';
import ReleaseLabelList from '../ReleaseLabelList';
import filterReleaseLabels
  from '../../static/scripts/common/utility/filterReleaseLabels';
import formatBarcode from '../../static/scripts/common/utility/formatBarcode';
import ArtistCreditLink
  from '../../static/scripts/common/components/ArtistCreditLink';
import EntityLink from '../../static/scripts/common/components/EntityLink';
import ReleaseEvents
  from '../../static/scripts/common/components/ReleaseEvents';
import TaggerIcon from '../../static/scripts/common/components/TaggerIcon';
import RatingStars from '../RatingStars';
import SortableTableHeader from '../SortableTableHeader';

type Props = {
  ...InstrumentCreditsAndRelTypesRoleT,
  ...SeriesItemNumbersRoleT,
  +$c: CatalystContextT,
  +checkboxes?: string,
  +filterLabel?: LabelT,
  +order?: string,
  +releases: $ReadOnlyArray<ReleaseT>,
  +showInstrumentCreditsAndRelTypes?: boolean,
  +showRatings?: boolean,
  +sortable?: boolean,
};

const ReleaseList = ({
  $c,
  checkboxes,
  filterLabel,
  instrumentCreditsAndRelTypes,
  order,
  releases,
  seriesItemNumbers,
  showInstrumentCreditsAndRelTypes,
  showRatings,
  sortable,
}: Props) => (
  <table className="tbl">
    <thead>
      <tr>
        {$c.user_exists && checkboxes ? (
          <th className="checkbox-cell">
            <input type="checkbox" />
          </th>
        ) : null}
        {seriesItemNumbers ? <th style={{width: '1em'}}>{l('#')}</th> : null}
        <th>
          {sortable
            ? (
              <SortableTableHeader
                label={l('Release')}
                name="title"
                order={order}
              />
            )
            : l('Release')}
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
        <th>
          {sortable
            ? (
              <SortableTableHeader
                label={l('Format')}
                name="format"
                order={order}
              />
            )
            : l('Format')}
        </th>
        <th>
          {sortable
            ? (
              <SortableTableHeader
                label={l('Tracks')}
                name="tracks"
                order={order}
              />
            )
            : l('Tracks')}
        </th>
        <th>
          {sortable
            ? (
              <>
                <SortableTableHeader
                  label={l('Country')}
                  name="country"
                  order={order}
                />
                {lp('/', 'and')}
                <SortableTableHeader
                  label={l('Date')}
                  name="date"
                  order={order}
                />
              </>
            )
            : l('Country') + lp('/', 'and') + l('Date')}
        </th>
        {filterLabel ? null : (
          <th>
            {sortable
              ? (
                <SortableTableHeader
                  label={l('Label')}
                  name="label"
                  order={order}
                />
              )
              : l('Label')}
          </th>
        )}
        <th>
          {sortable
            ? (
              <SortableTableHeader
                label={l('Catalog#')}
                name="catno"
                order={order}
              />
            )
            : l('Catalog#')}
        </th>
        <th>
          {sortable
            ? (
              <SortableTableHeader
                label={l('Barcode')}
                name="barcode"
                order={order}
              />
            )
            : l('Barcode')}
        </th>
        {showRatings ? <th>{l('Rating')}</th> : null}
        {showInstrumentCreditsAndRelTypes ? <th>{l('Relationship Types')}</th> : null}
        {$c.session && $c.session.tport ? <th>{l('Tagger')}</th> : null}
      </tr>
    </thead>
    <tbody>
      {releases.map((release, index) => (
        <tr className={loopParity(index)} key={release.id}>
          {$c.user_exists && checkboxes ? (
            <td>
              <input
                name={checkboxes}
                type="checkbox"
                value={release.id}
              />
            </td>
          ) : null}
          {seriesItemNumbers ? (
            <td style={{width: '1em'}}>
              {seriesItemNumbers[release.id]}
            </td>
          ) : null}
          <td>
            <EntityLink entity={release} />
          </td>
          <td>
            <ArtistCreditLink artistCredit={release.artistCredit} />
          </td>
          <td>
            {release.combined_format_name || l('[missing media]')}
          </td>
          <td>
            {release.combined_track_count || lp('-', 'missing data')}
          </td>
          <td>
            <ReleaseEvents events={release.events} />
          </td>
          {filterLabel ? (
            <td>
              {release.labels ? (
                <ReleaseCatnoList
                  labels={filterReleaseLabels(release.labels, filterLabel)}
                />
              ) : null}
            </td>
          ) : (
            <>
              <td>
                <ReleaseLabelList labels={release.labels} />
              </td>
              <td>
                <ReleaseCatnoList labels={release.labels} />
              </td>
            </>
          )}
          <td className="barcode-cell">{formatBarcode(release.barcode)}</td>
          {showRatings ? (
            <td>
              {release.releaseGroup ? (
                <RatingStars entity={release.releaseGroup} />
              ) : null}
            </td>
          ) : null}
          {showInstrumentCreditsAndRelTypes ? (
            <InstrumentRelTypes
              entity={release}
              instrumentCreditsAndRelTypes={instrumentCreditsAndRelTypes}
            />
          ) : null}
          {$c.session && $c.session.tport ? (
            <td>
              <TaggerIcon entity={release} />
            </td>
          ) : null}
        </tr>
      ))}
    </tbody>
  </table>
);

export default withCatalystContext(ReleaseList);
