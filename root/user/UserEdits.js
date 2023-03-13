/*
 * @flow strict-local
 * Copyright (C) 2021 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import {SanitizedCatalystContext} from '../context.mjs';
import EditList from '../edit/components/EditList.js';
import Layout from '../layout/index.js';
import EditorLink from '../static/scripts/common/components/EditorLink.js';

type Props = {
  +editCountLimit: number,
  +edits: $ReadOnlyArray<$ReadOnly<{...EditT, +id: number}>>,
  +pager: PagerT,
  +refineUrlArgs?: {+[argument: string]: string},
  +user: UnsanitizedEditorT,
  +voter?: UnsanitizedEditorT,
};

const UserEdits = ({
  editCountLimit,
  edits,
  pager,
  refineUrlArgs,
  user,
  voter,
}: Props): React$Element<typeof Layout> => {
  const $c = React.useContext(SanitizedCatalystContext);
  const titleParam = {name: user.name};
  const headingParam = {name: <EditorLink editor={user} />};
  let pageTitle = '';
  let pageHeading: Expand2ReactOutput = '';

  switch ($c.action.name) {
    case 'votes':
      pageTitle = texp.l('Votes by {name}', titleParam);
      pageHeading = exp.l('Votes by {name}', headingParam);
      break;
    case 'open':
      pageTitle = texp.l('Open edits by {name}', titleParam);
      pageHeading = exp.l('Open edits by {name}', headingParam);
      break;
    case 'cancelled':
      pageTitle = texp.l('Cancelled edits by {name}', titleParam);
      pageHeading = exp.l('Cancelled edits by {name}', headingParam);
      break;
    case 'accepted':
      pageTitle = texp.l('Accepted edits by {name}', titleParam);
      pageHeading = exp.l('Accepted edits by {name}', headingParam);
      break;
    case 'failed':
      pageTitle = texp.l('Failed edits by {name}', titleParam);
      pageHeading = exp.l('Failed edits by {name}', headingParam);
      break;
    case 'rejected':
      pageTitle = texp.l('Rejected edits by {name}', titleParam);
      pageHeading = exp.l('Rejected edits by {name}', headingParam);
      break;
    case 'autoedits':
      pageTitle = texp.l('Auto-edits by {name}', titleParam);
      pageHeading = exp.l('Auto-edits by {name}', headingParam);
      break;
    case 'applied':
      pageTitle = texp.l('Applied edits by {name}', titleParam);
      pageHeading = exp.l('Applied edits by {name}', headingParam);
      break;
    default:
      pageTitle = texp.l('Edits by {name}', titleParam);
      pageHeading = exp.l('Edits by {name}', headingParam);
      break;
  }

  return (
    <Layout fullWidth title={pageTitle}>
      <div id="content">
        <h2>{pageHeading}</h2>
        <EditList
          editCountLimit={editCountLimit}
          edits={edits}
          guessSearch
          page={'user_' + $c.action.name}
          pager={pager}
          refineUrlArgs={refineUrlArgs}
          username={user.name}
          voter={voter}
        />
      </div>
    </Layout>
  );
};

export default UserEdits;
