/*
 * @flow strict
 * Copyright (C) 2020 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

type Props = {
  +$c: CatalystContextT,
  +hostname?: string,
  +useLanguages?: boolean,
};

const ErrorEnvironment = ({
  $c,
  hostname,
  useLanguages = false,
}: Props): React.Element<typeof React.Fragment> => (
  <>
    <p>
      <strong>{l('Time:')}</strong>
      {' '}
      {new Date().toISOString()}
    </p>

    {nonEmpty(hostname) ? (
      <p>
        <strong>{l('Host:')}</strong>
        {' '}
        {hostname}
      </p>
    ) : null}

    {useLanguages ? (
      <p>
        <strong>{l('Interface language:')}</strong>
        {' '}
        {$c.stash.current_language}
      </p>
    ) : null}

    <p>
      <strong>{l('URL:')}</strong>
      {' '}
      <code>{$c.req.uri}</code>
    </p>

    <p>
      <strong>{l('Request data:')}</strong>
      <pre>
        {JSON.stringify({
          body_parameters: $c.req.body_params,
          query_parameters: $c.req.query_params,
        }, null, 2)}
      </pre>
    </p>

  </>
);

export default ErrorEnvironment;
