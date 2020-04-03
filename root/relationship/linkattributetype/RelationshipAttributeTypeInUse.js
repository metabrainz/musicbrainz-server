/*
 * @flow
 * Copyright (C) 2020 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import Layout from '../../layout';

const RelationshipAttributeTypeInUse = ({type}: {type: LinkAttrTypeT}) => (
  <Layout fullWidth page="in-use" title={l('Relationship attribute in use')}>
    <div className="content">
      <h2>{l('Relationship attribute still in use')}</h2>
      <p>
        {exp.l(
          `You cannot remove the relationship attribute "{type}"
           as it is still in use by other relationships.`,
          {type: type.name},
        )}
      </p>
    </div>
  </Layout>
);

export default RelationshipAttributeTypeInUse;
