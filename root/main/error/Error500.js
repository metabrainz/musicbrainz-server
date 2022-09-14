/*
 * @flow strict-local
 * Copyright (C) 2020 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import {CatalystContext} from '../../context.mjs';
import EditLink from '../../static/scripts/common/components/EditLink.js';
import bracketed from '../../static/scripts/common/utility/bracketed.js';
import bugTrackerURL
  from '../../static/scripts/common/utility/bugTrackerURL.js';

import ErrorEnvironment from './components/ErrorEnvironment.js';
import ErrorInfo from './components/ErrorInfo.js';
import ErrorLayout from './ErrorLayout.js';

type Props = {
  +edits?: $ReadOnlyArray<GenericEditWithIdT>,
  +formattedErrors?: $ReadOnlyArray<string>,
  +hostname?: string,
  +useLanguages: boolean,
};

const Error500 = ({
  edits,
  formattedErrors,
  hostname,
  useLanguages,
}: Props): React.Element<typeof ErrorLayout> => {
  const $c = React.useContext(CatalystContext);
  return (
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
};

export default Error500;
