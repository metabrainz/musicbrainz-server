/*
 * @flow strict-local
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import Layout from '../layout/index.js';
import AreaSidebar from '../layout/components/sidebar/AreaSidebar.js';
import localizeAreaName
  from '../static/scripts/common/i18n/localizeAreaName.js';

import AreaHeader from './AreaHeader.js';

type Props = {
  +children: React.Node,
  +entity: AreaT,
  +fullWidth?: boolean,
  +page: string,
  +title?: string,
};

const AreaLayout = ({
  children,
  entity: area,
  fullWidth = false,
  page,
  title,
}: Props): React.Element<typeof Layout> => (
  <Layout
    title={nonEmpty(title)
      ? hyphenateTitle(localizeAreaName(area), title)
      : localizeAreaName(area)}
  >
    <div id="content">
      <AreaHeader area={area} page={page} />
      {children}
    </div>
    {fullWidth ? null : <AreaSidebar area={area} />}
  </Layout>
);

export default AreaLayout;
