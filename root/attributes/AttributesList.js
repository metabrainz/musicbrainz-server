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

const AttributeList = ({modelList}: {modelList: Array<string>}) => {
  const sortedModels = sortByString(
    modelList,
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
};

type Props = {
  +aliasTypeModels: Array<string>,
  +entityTypeModels: Array<string>,
  +otherModels: Array<string>,
};

const AttributesList = ({
  aliasTypeModels,
  entityTypeModels,
  otherModels,
}: Props): React$Element<typeof Layout> => (
  <Layout fullWidth title={l('Attributes')}>
    <h1>{l('Attributes')}</h1>

    <h2>{l('Entity types')}</h2>
    <AttributeList modelList={entityTypeModels} />

    <h2>{l('Alias types')}</h2>
    <AttributeList modelList={aliasTypeModels} />

    <h2>{l('Other attributes')}</h2>
    <AttributeList modelList={otherModels} />
  </Layout>
);

export default AttributesList;
