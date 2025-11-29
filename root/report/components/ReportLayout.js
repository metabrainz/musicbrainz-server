/*
 * @flow strict
 * Copyright (C) 2020 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import {CatalystContext} from '../../context.mjs';
import Layout from '../../layout/index.js';
import expand2text from '../../static/scripts/common/i18n/expand2text.js';
import formatUserDate from '../../utility/formatUserDate.js';
import FilterLink from '../FilterLink.js';

const countTextPicker: {
  +[entityType: string]: () => string,
} = {
  artist: N_l_reports('Total artists found: {count}'),
  artist_credit: N_l_reports('Total artist credits found: {count}'),
  discId: N_l_reports('Total discIDs found: {count}'),
  editor: N_l_reports('Total editors found: {count}'),
  event: N_l_reports('Total events found: {count}'),
  instrument: N_l_reports('Total instruments found: {count}'),
  isrc: N_l_reports('Total ISRCs found: {count}'),
  iswc: N_l_reports('Total ISWCs found: {count}'),
  label: N_l_reports('Total labels found: {count}'),
  place: N_l_reports('Total places found: {count}'),
  recording: N_l_reports('Total recordings found: {count}'),
  relationship: N_l_reports('Total relationships found: {count}'),
  release: N_l_reports('Total releases found: {count}'),
  release_group: N_l_reports('Total release groups found: {count}'),
  series: N_l_reports('Total series found: {count}'),
  url: N_l_reports('Total URLs found: {count}'),
  work: N_l_reports('Total works found: {count}'),
};

component ReportLayout(
  canBeFiltered: boolean,
  children: React.Node,
  countText?: string,
  description: Expand2ReactOutput,
  entityType: string,
  extraInfo?: Expand2ReactOutput,
  filtered: boolean,
  generated: string,
  title: string,
  totalEntries: number,
) {
  const $c = React.useContext(CatalystContext);

  return (
    <Layout fullWidth title={title}>
      <h1>{title}</h1>

      <ul>
        <li>
          {description}
        </li>
        {nonEmpty(extraInfo) ? (
          <li>
            {extraInfo}
          </li>
        ) : null}
        <li>
          {expand2text(
            nonEmpty(countText) ? countText : countTextPicker[entityType](),
            {count: totalEntries},
          )}
        </li>
        <li>
          {texp.l_reports('Generated on {date}',
                          {date: formatUserDate($c, generated)})}
        </li>

        {canBeFiltered ? <FilterLink filtered={filtered} /> : null}
      </ul>

      {children}
    </Layout>
  );
}

export default ReportLayout;
