/*
 * @flow strict
 * Copyright (C) 2019 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import Layout from '../layout/index.js';

component OAuth2Error(errorDescription: string, errorMessage: string) {
  return (
    <Layout fullWidth title={l('OAuth authorization error')}>
      <h1>{texp.l('Error: {error}', {error: errorMessage})}</h1>
      <p>{errorDescription}</p>
      <p>{exp.l('{doc|Learn more}', {doc: '/doc/Development/OAuth2'})}</p>
    </Layout>
  );
}

export default OAuth2Error;
