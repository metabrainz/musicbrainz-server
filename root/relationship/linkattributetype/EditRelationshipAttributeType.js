/*
 * @flow strict
 * Copyright (C) 2022 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import Layout from '../../layout/index.js';

import RelationshipAttributeTypeEditForm
  from './RelationshipAttributeTypeEditForm.js';
import type {RelationshipAttributeTypeEditFormT} from './types.js';

component EditRelationshipAttributeType(
  disableCreditable: boolean,
  disableFreeText: boolean,
  form: RelationshipAttributeTypeEditFormT,
  parentSelectOptions: SelectOptionsT,
) {
  return (
    <Layout
      fullWidth
      title="Edit relationship attribute"
    >
      <div id="content">
        <h1>{'Edit relationship attribute'}</h1>
        <RelationshipAttributeTypeEditForm
          disableCreditable={disableCreditable}
          disableFreeText={disableFreeText}
          form={form}
          parentSelectOptions={parentSelectOptions}
        />
      </div>
    </Layout>
  );
}

export default EditRelationshipAttributeType;
