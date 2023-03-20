/*
 * @flow strict
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import CollectionSidebar
  from '../layout/components/sidebar/CollectionSidebar.js';
import Layout from '../layout/index.js';

import CollectionHeader from './CollectionHeader.js';

type Props = {
  +children: React$Node,
  +entity: CollectionT,
  +fullWidth?: boolean,
  +page: string,
  +recordingMbids?: $ReadOnlyArray<string> | null,
  +title?: string,
};

const CollectionLayout = ({
  children,
  entity: collection,
  fullWidth = false,
  page,
  recordingMbids,
  title,
}: Props): React$Element<typeof Layout> => {
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
          collection={collection}
          page={page}
        />
        {children}
      </div>
      {fullWidth ? null : (
        <CollectionSidebar
          collection={collection}
          recordingMbids={recordingMbids}
        />
      )}
    </Layout>
  );
};

export default CollectionLayout;
