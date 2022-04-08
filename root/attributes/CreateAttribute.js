/*
 * @flow strict
 * Copyright (C) 2022 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import Layout from '../layout/index.js';

import AttributeEditForm from './AttributeEditForm.js';
import type {CreateOrEditAttributePropsT} from './types.js';

component CreateAttribute(...props: CreateOrEditAttributePropsT) {
  return (
    <Layout
      fullWidth
      title="New attribute"
    >
      <div id="content">
        <h1>{'New attribute'}</h1>
        <AttributeEditForm {...props} />
      </div>
    </Layout>
  );
}

export default CreateAttribute;
