/*
 * @flow
 * Copyright (C) 2020 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import Layout from '../layout';
import EditLink from '../static/scripts/common/components/EditLink';
import {EDIT_STATUS_DELETED} from '../constants';

type Props = {
  +edit: {...EditT, +id: number},
};

const CannotApproveEdit = ({edit}: Props): React.Element<typeof Layout> => {
  const editDisplay = 'edit #' + edit.id;
  const editLink = <EditLink content={editDisplay} edit={edit} />;
  const editIsClosed = !edit.is_open;
  const editIsCancelled = edit.status === EDIT_STATUS_DELETED;
  const reason = editIsCancelled ? (
    l('The edit has been cancelled.')
  ) : editIsClosed ? (
    l('The edit has already been closed.')
  ) : (
    exp.l(
      'Only {doc|auto-editors} can approve an edit.',
      {doc: '/doc/Editor'},
    )
  );
  return (
    <Layout fullWidth title={l('Error Approving Edit')}>
      <h1>{l('Error Approving Edit')}</h1>
      <p>
        {exp.l(
          'There was a problem approving {edit}.',
          {edit: editLink},
        )}
      </p>
      <p>{reason}</p>
    </Layout>
  );
};

export default CannotApproveEdit;
