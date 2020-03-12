/*
 * @flow
 * Copyright (C) 2019 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import Layout from '../layout';
import UrlSidebar from '../layout/components/sidebar/UrlSidebar';

import UrlHeader from './UrlHeader';

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
  fullWidth,
  page,
  title,
}: Props) => (
  <Layout
    title={title}
  >
    <div id="content">
      <UrlHeader page={page} url={url} />
      {children}
    </div>
    {fullWidth ? null : <UrlSidebar url={url} />}
  </Layout>
);


export default UrlLayout;
