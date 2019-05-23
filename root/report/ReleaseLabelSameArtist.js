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
  <Layout
    fullWidth
    title={l('Releases where artist name and label name are the same')}
  >
    <h1>{l('Releases where artist name and label name are the same')}</h1>

    <ul>
      <li>
        {exp.l(
          `This report lists releases where the label name is the same as the
           artist name. Often this means the release is self-released, and the
           label {SpecialPurposeLabel|should be "[no label]" instead}.`,
          {
            SpecialPurposeLabel:
            '/doc/Style/Unknown_and_untitled/Special_purpose_label',
          },
        )}
      </li>
      <li>
        {texp.l('Total releases found: {count}',
                {count: pager.total_entries})}
      </li>
      <li>
        {texp.l('Generated on {date}',
                {date: formatUserDate($c.user, generated)})}
      </li>

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
            <tr className={loopParity(index)} key={item.release_id}>
              {item.release ? (
                <>
                  <td>
                    <EntityLink entity={item.release} />
                  </td>
                  <td>
                    <ArtistCreditLink
                      artistCredit={item.release.artistCredit}
                    />
                  </td>
                  <td>
                    <a href={'/label/' + encodeURIComponent(item.label_gid)}>
                      {item.label_name}
                    </a>
                  </td>
                </>
              ) : (
                <td colSpan="3">
                  {l('This release no longer exists.')}
                </td>
              )}
            </tr>
          ))}
        </tbody>
      </table>
    </PaginatedResults>

  </Layout>
);

export default withCatalystContext(ReleaseLabelSameArtist);
