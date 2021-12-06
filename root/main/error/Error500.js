/*
 * @flow strict-local
 * Copyright (C) 2020 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import EditLink from '../../static/scripts/common/components/EditLink';
import bracketed from '../../static/scripts/common/utility/bracketed';
import bugTrackerURL from '../../static/scripts/common/utility/bugTrackerURL';

import ErrorLayout from './ErrorLayout';
import ErrorEnvironment from './components/ErrorEnvironment';
import ErrorInfo from './components/ErrorInfo';

type Props = {
  +$c: CatalystContextT,
  +edits?: $ReadOnlyArray<GenericEditWithIdT>,
  +formattedErrors?: $ReadOnlyArray<string>,
  +hostname?: string,
  +useLanguages: boolean,
};

const Error500 = ({
  $c,
  edits,
  formattedErrors,
  hostname,
  useLanguages,
}: Props): React.Element<typeof ErrorLayout> => (
  <ErrorLayout title={l('Internal Server Error')}>
    <p>
      <strong>
        {l('Oops, something went wrong!')}
      </strong>
    </p>

    <ErrorInfo formattedErrors={formattedErrors} />

    {edits?.length ? (
      <>
        <p>
          <strong>
            {l('Edits loaded for the page:')}
          </strong>
        </p>
        <ul>
          {edits.map(edit => (
            <li key={edit.id}>
              <EditLink content={edit.id.toString()} edit={edit} />
              {' '}
              {bracketed(
                <EditLink
                  content={l('raw edit data')}
                  edit={edit}
                  subPath="data"
                />,
              )}
              {edit.is_loaded ? ('; ' + l('fully loaded')) : null}
            </li>
          ))}
        </ul>
      </>
    ) : null}

    <ErrorEnvironment
      $c={$c}
      hostname={hostname}
      useLanguages={useLanguages}
    />

    <p>
      {l(`We’re terribly sorry for this problem.
          Please wait a few minutes and repeat
          your request — the problem may go away.`)}
    </p>

    <p>
      {exp.l(
        `If the problem persists, please {report|report a bug}
         and include any error message that is shown above.`,
        {
          report: bugTrackerURL(
            'Internal server error on  ' + $c.req.uri + '\n' +
            'Referrer: ' + ($c.req.headers.referer || ''),
          ),
        },
      )}
    </p>
  </ErrorLayout>
);

export default Error500;
