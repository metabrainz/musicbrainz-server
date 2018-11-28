/*
 * @flow
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import {withCatalystContext} from '../context';
import Layout from '../layout';
import formatUserDate from '../utility/formatUserDate';
import {l} from '../static/scripts/common/i18n';
import PaginatedResults from '../components/PaginatedResults';
import loopParity from '../utility/loopParity';
import EntityLink from '../static/scripts/common/components/EntityLink';
import ArtistCreditLink
  from '../static/scripts/common/components/ArtistCreditLink';

import FilterLink from './FilterLink';
import type {ReportDataT, ReportReleaseLabelT} from './types';

const ReleaseLabelSameArtist = ({
  $c,
  canBeFiltered,
  filtered,
  generated,
  items,
  pager,
}: ReportDataT<ReportReleaseLabelT>) => (
  <Layout fullWidth title={l('Releases where artist name and label name are the same')}>
    <h1>{l('Releases where artist name and label name are the same')}</h1>

    <ul>
      <li>{l('This report lists releases where the label name is the same as the artist name. \
        Often this means the release is self-released, and the label {SpecialPurposeLabel|should be "[no label]" instead}.',
      {__react: true, SpecialPurposeLabel: '/doc/Style/Unknown_and_untitled/Special_purpose_label'})}
      </li>
      <li>{l('Total releases found: {count}', {__react: true, count: pager.total_entries})}</li>
      <li>{l('Generated on {date}', {__react: true, date: formatUserDate($c.user, generated)})}</li>

      {canBeFiltered ? <FilterLink filtered={filtered} /> : null}
    </ul>

    <PaginatedResults pager={pager}>
      <table className="tbl">
        <thead>
          <tr>
            <th>{l('Release')}</th>
            <th>{l('Artist')}</th>
            <th>{l('Label')}</th>
          </tr>
        </thead>
        <tbody>
          {items.map((item, index) => (
            <tr className={loopParity(index)} key={item.release.gid}>
              <td>
                <EntityLink entity={item.release} />
              </td>
              <td>
                <ArtistCreditLink artistCredit={item.release.artistCredit} />
              </td>
              <td>
                <a href={'/label/' + item.label_gid}>{item.label_name}</a>
              </td>
            </tr>
          ))}
        </tbody>
      </table>
    </PaginatedResults>

  </Layout>
);

export default withCatalystContext(ReleaseLabelSameArtist);
