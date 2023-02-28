/*
 * @flow strict
 * Copyright (C) 2019 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import UrlSidebar from '../layout/components/sidebar/UrlSidebar.js';
import Layout from '../layout/index.js';

import UrlHeader from './UrlHeader.js';

type Props = {
  +children: React.Node,
  +entity: UrlT,
  +fullWidth?: boolean,
  +page: string,
  +title?: string,
};

const UrlLayout = ({
  children,
  entity: url,
  fullWidth = false,
  page,
  title,
}: Props): React.Element<typeof Layout> => (
  <Layout title={title}>
    <div id="content">
      <UrlHeader page={page} url={url} />
      {children}
    </div>
    {fullWidth ? null : <UrlSidebar url={url} />}
  </Layout>
);


export default UrlLayout;
