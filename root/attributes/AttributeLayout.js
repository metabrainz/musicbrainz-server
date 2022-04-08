/*
 * @flow strict
 * Copyright (C) 2022 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import Layout from '../layout/index.js';
import {l_admin} from '../static/scripts/common/i18n/admin.js';
import attributeModelName
  from '../static/scripts/common/utility/attributeModelName.js';

type Props = {
  +children: React$Node,
  +model: string,
  +showEditSections: boolean,
};

const AttributeLayout = ({
  children,
  model,
  showEditSections,
}: Props): React$Element<typeof Layout> => (
  <Layout fullWidth title={attributeModelName(model)}>
    <h1>
      <a href="/attributes">{l('Attributes')}</a>
      {' / ' + attributeModelName(model)}
    </h1>

    {children}

    {showEditSections ? (
      <p>
        <span className="buttons">
          <a href={`/attributes/${model}/create`}>
            {l_admin('Add new attribute')}
          </a>
        </span>
      </p>
    ) : null}
  </Layout>
);

export default AttributeLayout;
