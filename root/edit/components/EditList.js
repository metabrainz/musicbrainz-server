/*
 * @flow strict-local
 * Copyright (C) 2021 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import ListEdit from '../components/ListEdit';
import ListHeader from '../components/ListHeader';
import FormSubmit from '../../components/FormSubmit';
import PaginatedResults from '../../components/PaginatedResults';
import * as manifest from '../../static/manifest.mjs';
import {isAutoEditor} from '../../static/scripts/common/utility/privileges';

type Props = {
  +$c: CatalystContextT,
  +editCountLimit: number,
  +edits: $ReadOnlyArray<$ReadOnly<{...EditT, +id: number}>>,
  +entity?: CoreEntityT | CollectionT,
  +guessSearch?: boolean,
  +isSearch?: boolean,
  +page: string,
  +pager: PagerT,
  +refineUrlArgs?: {+[argument: string]: string},
  +username?: string,
  +voter?: UnsanitizedEditorT,
};

const EditList = ({
  $c,
  editCountLimit,
  edits,
  entity,
  guessSearch = false,
  isSearch = false,
  page,
  pager,
  refineUrlArgs,
  username,
  voter,
}: Props): React.Element<typeof React.Fragment> => {
  /*
   * guessSearch is used when we don't necessarily know the total
   * number of entries on the first page (and usually a few after), due
   * to there being more than the SQL LIMIT to start.
   *
   * We only use the 'at least' wording, even when guessSearch is on, in the
   * case where it's truly unclear. That is, where the total number found is
   * the exact number that would have been found in any case with that
   * many edits or more. That is: when there are exactly editCountLimit
   * edits more than the sum of all previous pages.
   *
   * In the case where this is not true, we unset guessSearch so the
   * paginator also knows this is an exact number of pages.
   */
  const totalVisibleEdits =
    pager.entries_per_page * (pager.current_page - 1) + editCountLimit;
  const isDubiousNumberOfEdits = pager.total_entries === totalVisibleEdits;
  const mightBeMoreEdits = guessSearch && isDubiousNumberOfEdits;

  return (
    <>
      <ListHeader
        entity={entity}
        isSearch={isSearch}
        page={page}
        refineUrlArgs={refineUrlArgs}
        username={username}
      />

      <div className="search-toggle c">
        <p>
          <strong>
            {guessSearch && mightBeMoreEdits ? (
              exp.ln(
                'Found at least {n} edit',
                'Found at least {n} edits',
                pager.total_entries,
                {n: Number(pager.total_entries).toLocaleString()},
              )
            ) : (
              exp.ln(
                'Found {n} edit',
                'Found {n} edits',
                pager.total_entries,
                {n: Number(pager.total_entries).toLocaleString()},
              )
            )}
          </strong>
        </p>
      </div>

      {edits.length ? (
        <div id="edits">
          <PaginatedResults guessSearch={mightBeMoreEdits} pager={pager}>
            <form action="/edit/enter_votes" method="post">
              {edits.map((edit, index) => (
                <ListEdit
                  $c={$c}
                  edit={edit}
                  index={index}
                  key={index}
                  voter={voter}
                />
              ))}

              <input name="url" type="hidden" value={$c.req.uri} />

              {$c.user ? (
                <div className="align-right row no-label">
                  <FormSubmit label={l('Submit votes & edit notes')} />
                </div>
              ) : null}
            </form>
          </PaginatedResults>
        </div>
      ) : isSearch ? (
        <p>
          {exp.l(
            `No edits were found matching your query.
             Please {search|try again}.`,
            {search: '/edit/search'},
          )}
        </p>
      ) : null}

      {manifest.js('voting')}

      {isAutoEditor($c.user) ? (
        <script
          dangerouslySetInnerHTML={{__html: 'MB.Control.EditList("#edits");'}}
          type="text/javascript"
        />
      ) : null}
    </>
  );
};

export default EditList;
