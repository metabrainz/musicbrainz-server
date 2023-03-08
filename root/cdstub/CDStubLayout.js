/*
 * @flow strict
 * Copyright (C) 2022 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import CDStubSidebar from '../layout/components/sidebar/CDStubSidebar.js';
import Layout from '../layout/index.js';

import CDStubHeader from './CDStubHeader.js';

type Props = {
  +children: React$Node,
  +entity: CDStubT,
  +fullWidth?: boolean,
  +page: string,
};

const CDStubLayout = ({
  children,
  entity: cdstub,
  fullWidth = false,
  page,
}: Props): React$Element<typeof Layout> => {
  const title = texp.l(
    'CD stub “{title}” by {artist}',
    {
      artist: cdstub.artist || l('Various Artists'),
      title: cdstub.title,
    },
  );

  return (
    <Layout title={title}>
      <div id="content">
        <CDStubHeader cdstub={cdstub} page={page} />
        {children}
      </div>
      {fullWidth ? null : <CDStubSidebar cdstub={cdstub} />}
    </Layout>
  );
};

export default CDStubLayout;
