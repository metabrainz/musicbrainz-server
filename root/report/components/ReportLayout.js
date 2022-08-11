/*
 * @flow strict-local
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

const countTextPicker = {
  artist: N_l('Total artists found: {count}'),
  artist_credit: N_l('Total artist credits found: {count}'),
  discId: N_l('Total discIDs found: {count}'),
  editor: N_l('Total editors found: {count}'),
  event: N_l('Total events found: {count}'),
  instrument: N_l('Total instruments found: {count}'),
  isrc: N_l('Total ISRCs found: {count}'),
  iswc: N_l('Total ISWCs found: {count}'),
  label: N_l('Total labels found: {count}'),
  place: N_l('Total places found: {count}'),
  recording: N_l('Total recordings found: {count}'),
  relationship: N_l('Total relationships found: {count}'),
  release: N_l('Total releases found: {count}'),
  release_group: N_l('Total release groups found: {count}'),
  series: N_l('Total series found: {count}'),
  url: N_l('Total URLs found: {count}'),
  work: N_l('Total works found: {count}'),
};

type Props = {
  +canBeFiltered: boolean,
  +children: React.Node,
  +countText?: string,
  +description: Expand2ReactOutput,
  +entityType: string,
  +extraInfo?: Expand2ReactOutput,
  +filtered: boolean,
  +generated: string,
  +title: string,
  +totalEntries: number,
};

const ReportLayout = ({
  canBeFiltered,
  children,
  countText,
  description,
  entityType,
  extraInfo,
  filtered,
  generated,
  title,
  totalEntries,
}: Props): React.Element<typeof Layout> => {
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
          {texp.l('Generated on {date}',
                  {date: formatUserDate($c, generated)})}
        </li>

        {canBeFiltered ? <FilterLink filtered={filtered} /> : null}
      </ul>

      {children}
    </Layout>
  );
};

export default ReportLayout;
