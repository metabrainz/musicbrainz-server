/*
 * @flow strict-local
 * Copyright (C) 2020 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import Layout from '../layout';
import EditLink from '../static/scripts/common/components/EditLink';

type Props = {
  +edit: GenericEditWithIdT,
};

const NoteIsRequired = ({edit}: Props): React.Element<typeof Layout> => {
  const editDisplay = 'edit #' + edit.id;
  const editLink = <EditLink content={editDisplay} edit={edit} />;
  return (
    <Layout fullWidth title={l('Error Approving Edit')}>
      <h1>{l('Error Approving Edit')}</h1>
      <p>
        {exp.l(
          `{edit} has received one or more "no" votes,
           you must leave an edit note before you can approve it.`,
          {edit: editLink},
        )}
      </p>
    </Layout>
  );
};

export default NoteIsRequired;
