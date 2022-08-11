/*
 * @flow strict-local
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import {CatalystContext} from '../context.mjs';
import Layout from '../layout/index.js';
import CollectionSidebar
  from '../layout/components/sidebar/CollectionSidebar.js';

import CollectionHeader from './CollectionHeader.js';

type Props = {
  +children: React.Node,
  +entity: CollectionT,
  +fullWidth?: boolean,
  +page: string,
  +title?: string,
};

const CollectionLayout = ({
  children,
  entity: collection,
  fullWidth = false,
  page,
  title,
}: Props): React.Element<typeof Layout> => {
  const $c = React.useContext(CatalystContext);
  const mainTitle = texp.l(
    'Collection “{collection}”',
    {collection: collection.name},
  );

  return (
    <Layout
      title={nonEmpty(title) ? hyphenateTitle(mainTitle, title) : mainTitle}
    >
      <div id="content">
        <CollectionHeader
          $c={$c}
          collection={collection}
          page={page}
        />
        {children}
      </div>
      {fullWidth ? null : <CollectionSidebar collection={collection} />}
    </Layout>
  );
};

export default CollectionLayout;
