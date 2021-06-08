/*
 * @flow strict-local
 * Copyright (C) 2019 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import PaginatedResults from '../components/PaginatedResults';
import EditorLink from '../static/scripts/common/components/EditorLink';

import AreaLayout from './AreaLayout';

type Props = {
  +area: AreaT,
  +editors: $ReadOnlyArray<EditorT>,
  +pager: PagerT,
};

const AreaUsers = ({
  area,
  editors,
  pager,
}: Props): React.Element<typeof AreaLayout> => (
  <AreaLayout entity={area} page="users" title={l('Users')}>
    <h2>{l('Users')}</h2>

    {pager.total_entries ? (
      <p>
        {exp.ln('There is currently {num} user in this area.',
                'There are currently {num} users in this area.',
                pager.total_entries,
                {num: pager.total_entries})}
      </p>
    ) : (
      <p>{l('There are currently no users in this area.')}</p>
    )}

    {editors?.length ? (
      <PaginatedResults pager={pager}>
        <ul>
          {editors.map(editor => (
            <li key={editor.id}>
              <EditorLink editor={editor} />
            </li>
          ))}
        </ul>
      </PaginatedResults>
    ) : null}
  </AreaLayout>
);

export default AreaUsers;
