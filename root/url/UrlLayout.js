/*
 * @flow strict-local
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
  +$c: CatalystContextT,
  +children: React.Node,
  +entity: UrlT,
  +fullWidth?: boolean,
  +page: string,
  +title?: string,
};

const UrlLayout = ({
  $c,
  children,
  entity: url,
  fullWidth = false,
  page,
  title,
}: Props): React.Element<typeof Layout> => (
  <Layout $c={$c} title={title}>
    <div id="content">
      <UrlHeader page={page} url={url} />
      {children}
    </div>
    {fullWidth ? null : <UrlSidebar url={url} />}
  </Layout>
);


export default UrlLayout;
