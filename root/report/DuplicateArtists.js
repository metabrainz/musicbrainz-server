/*
 * @flow strict-local
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import PaginatedResults from '../components/PaginatedResults.js';
import {SanitizedCatalystContext} from '../context.mjs';
import loopParity from '../utility/loopParity.js';
import EntityLink from '../static/scripts/common/components/EntityLink.js';
import FormRow from '../components/FormRow.js';
import FormSubmit from '../components/FormSubmit.js';
import {returnToCurrentPage} from '../utility/returnUri.js';

import ReportLayout from './components/ReportLayout.js';
import type {ReportArtistT, ReportDataT} from './types.js';

const DuplicateArtists = ({
  canBeFiltered,
  filtered,
  generated,
  items,
  pager,
}: ReportDataT<ReportArtistT>): React.Element<typeof ReportLayout> => {
  const $c = React.useContext(SanitizedCatalystContext);

  let currentKey: ?string = '';
  let lastKey: ?string = '';

  return (
    <ReportLayout
      canBeFiltered={canBeFiltered}
      countText={l('Total duplicate groups: {count}')}
      description={exp.l(
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
      entityType="artist"
      filtered={filtered}
      generated={generated}
      title={l('Possibly duplicate artists')}
      totalEntries={pager.total_entries}
    >
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
    </ReportLayout>
  );
};

export default DuplicateArtists;
