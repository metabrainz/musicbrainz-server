/*
 * @flow strict-local
 * Copyright (C) 2021 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import PaginatedResults from '../../components/PaginatedResults.js';
import {SanitizedCatalystContext} from '../../context.mjs';
import * as manifest from '../../static/manifest.mjs';
import {isAutoEditor}
  from '../../static/scripts/common/utility/privileges.js';
import FormSubmit from '../../static/scripts/edit/components/FormSubmit.js';
import ListEdit from '../components/ListEdit.js';
import ListHeader from '../components/ListHeader.js';

type Props = {
  +edits: $ReadOnlyArray<$ReadOnly<{...EditT, +id: number}>>,
  +entity?: EditableEntityT | CollectionT,
  +isSearch?: boolean,
  +page: string,
  +pager: PagerT,
  +refineUrlArgs?: {+[argument: string]: string},
  +username?: string,
  +voter?: UnsanitizedEditorT,
};

const EditList = ({
  edits,
  entity,
  isSearch = false,
  page,
  pager,
  refineUrlArgs,
  username,
  voter,
}: Props): React$Element<typeof React.Fragment> => {
  const $c = React.useContext(SanitizedCatalystContext);

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
            {exp.ln(
              'Found {n} edit',
              'Found {n} edits',
              pager.total_entries,
              {n: Number(pager.total_entries).toLocaleString()},
            )}
          </strong>
        </p>
      </div>

      {edits.length ? (
        <div id="edits">
          <PaginatedResults pager={pager}>
            <form action="/edit/enter_votes" method="post">
              {edits.map((edit, index) => (
                <ListEdit
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
