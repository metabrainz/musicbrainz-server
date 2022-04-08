/*
 * @flow strict
 * Copyright (C) 2019 Anirudh Jain
 * Copyright (C) 2014 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import Layout from '../layout/index.js';

component Attributes(models as passedModels: Array<string>) {
  const models = [...passedModels];
  return (
    <Layout fullWidth title="Attributes">
      <h1>{l('Attributes')}</h1>
      <ul>
        {models.sort().map((item) => (
          <li key={item}>
            <a href={'/attributes/' + item}>{item}</a>
          </li>
        ))}
      </ul>
    </Layout>
  );
}

export default Attributes;
