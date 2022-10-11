/*
 * @flow strict
 * Copyright (C) 2019 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import Layout from '../layout/index.js';

type Props = {
  +errorDescription: string,
  +errorMessage: string,
};

const OAuth2Error = ({
  errorDescription,
  errorMessage,
}: Props): React.Element<typeof Layout> => (
  <Layout fullWidth title={l('OAuth Authorization Error')}>
    <h1>{texp.l('Error: {error}', {error: errorMessage})}</h1>
    <p>{errorDescription}</p>
    <p>{exp.l('{doc|Learn more}', {doc: '/doc/Development/OAuth2'})}</p>
  </Layout>
);

export default OAuth2Error;
