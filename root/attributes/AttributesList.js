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
import {sortByString} from '../static/scripts/common/utility/arrays.js';
import attributeModelName
  from '../static/scripts/common/utility/attributeModelName.js';

component AttributeList(models as passedModels: Array<string>) {
  const models = [...passedModels];
  const sortedModels = sortByString(
    models,
    model => attributeModelName(model),
  );

  return (
    <ul>
      {sortedModels.map((model) => (
        <li key={model}>
          <a href={'/attributes/' + model}>{attributeModelName(model)}</a>
        </li>
      ))}
    </ul>
  );
}

component AttributesList(
  entityTypeModels: Array<string>,
  otherModels: Array<string>,
) {
  return (
    <Layout fullWidth title={l('Attributes')}>
      <h1>{l('Attributes')}</h1>

      <h2>{l('Entity types')}</h2>
      <AttributeList models={entityTypeModels} />

      <h2>{l('Other attributes')}</h2>
      <AttributeList models={otherModels} />
    </Layout>
  );
}

export default AttributesList;
