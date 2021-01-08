/*
 * @flow strict-local
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import Layout from '../layout';
import formatUserDate from '../utility/formatUserDate';
import PaginatedResults from '../components/PaginatedResults';
import loopParity from '../utility/loopParity';
import EntityLink from '../static/scripts/common/components/EntityLink';
import FormRow from '../components/FormRow';
import FormSubmit from '../components/FormSubmit';
import {returnToCurrentPage} from '../utility/returnUri';

import FilterLink from './FilterLink';
import type {ReportArtistT, ReportDataT} from './types';

const DuplicateArtists = ({
  $c,
  canBeFiltered,
  filtered,
  generated,
  items,
  pager,
}: ReportDataT<ReportArtistT>): React.Element<typeof Layout> => {
  let currentKey = '';
  let lastKey = '';

  return (
    <Layout $c={$c} fullWidth title={l('Possibly duplicate artists')}>
      <h1>{l('Possibly duplicate artists')}</h1>

      <ul>
        <li>
          {exp.l(
            `This report aims to identify artists with very similar names.
             If two artists are actually the same, please merge them
             (remember to {how_to_write_edit_notes|write an edit note}
             and give your proof). If they\'re different, add
             {disambiguation_comment|disambiguation comments} to them
             (and once a group of similarly named artists have
             disambiguation comments, they will stop appearing here).`,
            {
              disambiguation_comment: '/doc/Disambiguation_Comment',
              how_to_write_edit_notes: '/doc/How_to_Write_Edit_Notes',
            },
          )}
        </li>
        <li>
          {texp.l('Total duplicate groups: {count}',
                  {count: pager.total_entries})}
        </li>
        <li>
          {texp.l('Generated on {date}',
                  {date: formatUserDate($c, generated)})}
        </li>

        {canBeFiltered ? <FilterLink $c={$c} filtered={filtered} /> : null}
      </ul>

      <form
        action={'/artist/merge_queue?' + returnToCurrentPage($c)}
        method="post"
      >
        <PaginatedResults pager={pager}>
          <table className="tbl">
            <thead>
              <tr>
                <th className="check" />
                <th>{l('Artist')}</th>
                <th>{l('Sort name')}</th>
                <th className="atype">{l('Type')}</th>
              </tr>
            </thead>
            <tbody>
              {items.map((item, index) => {
                const {alias, artist} = item;
                lastKey = currentKey;
                currentKey = item.key;
                return (
                  <React.Fragment
                    key={artist ? artist.gid : `removed-${index}`}
                  >
                    {lastKey === item.key ? null : (
                      <tr className="subh">
                        <td colSpan="4" />
                      </tr>
                    )}
                    {artist ? (
                      <tr className={loopParity(index)}>
                        <td>
                          <input
                            name="add-to-merge"
                            type="checkbox"
                            value={artist.id}
                          />
                        </td>
                        <td>
                          <EntityLink entity={artist} />
                          {nonEmpty(alias) ? (
                            <span>
                              {' (' + l('alias:') + ' ' + alias + ')'}
                            </span>
                          ) : null}
                        </td>
                        <td>{artist.sort_name}</td>
                        <td>
                          {nonEmpty(artist.typeName)
                            ? lp_attributes(
                              artist.typeName, 'artist_type',
                            )
                            : l('Unknown')}
                        </td>
                      </tr>
                    ) : (
                      <tr>
                        <td />
                        <td colSpan="3">
                          {l('This artist no longer exists.')}
                        </td>
                      </tr>
                    )}
                  </React.Fragment>
                );
              })}
            </tbody>
          </table>
          {$c.user ? (
            <FormRow>
              <FormSubmit label={l('Add selected artists for merging')} />
            </FormRow>
          ) : null}
        </PaginatedResults>
      </form>

    </Layout>
  );
};

export default DuplicateArtists;
