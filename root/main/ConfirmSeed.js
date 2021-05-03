/*
 * @flow strict-local
 * Copyright (C) 2020 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import PostParameters, {
  type PostParametersT,
} from '../static/scripts/common/components/PostParameters';
import Layout from '../layout';
import * as manifest from '../static/manifest';

import ConfirmSeedButtons from './components/ConfirmSeedButtons';

type Props = {
  +$c: CatalystContextT,
  +origin: string,
  +postParameters: PostParametersT | null,
};

const ConfirmSeed = ({
  $c,
  origin,
  postParameters,
}: Props): React.Element<typeof Layout> => {
  const title = l('Confirm Form Submission');
  return (
    <Layout $c={$c} fullWidth title={title}>
      <h1>{title}</h1>
      <p>
        {exp.l(
          `You are about to submit a request to {action}
           originating from {origin}. Continue?`,
          {
            action: <strong>{$c.req.uri}</strong>,
            origin: <strong>{origin}</strong>,
          },
        )}
      </p>
      <p>
        {l(`This confirmation is important to ensure that no malicious
            actor can use your account to modify data without your knowledge.
            Below this line, you can review the data being sent and make any
            modifications if desired.`)}
      </p>
      <form action={$c.req.uri} method="post">
        {postParameters ? <PostParameters params={postParameters} /> : null}
        <ConfirmSeedButtons />
      </form>
      {manifest.js('confirm-seed', {async: 'async'})}
    </Layout>
  );
};

export default ConfirmSeed;
