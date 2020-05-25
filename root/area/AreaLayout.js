/*
 * @flow
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import Layout from '../layout';
import AreaSidebar from '../layout/components/sidebar/AreaSidebar';
import localizeAreaName from '../static/scripts/common/i18n/localizeAreaName';

import AreaHeader from './AreaHeader';

type Props = {
  +$c: CatalystContextT,
  +children: React.Node,
  +entity: AreaT,
  +fullWidth?: boolean,
  +page: string,
  +title?: string,
};

const AreaLayout = ({
  $c,
  children,
  entity: area,
  fullWidth,
  page,
  title,
}: Props): React.Element<typeof Layout> => (
  <Layout
    $c={$c}
    title={title
      ? hyphenateTitle(localizeAreaName(area), title)
      : localizeAreaName(area)}
  >
    <div id="content">
      <AreaHeader area={area} page={page} />
      {children}
    </div>
    {fullWidth ? null : <AreaSidebar $c={$c} area={area} />}
  </Layout>
);

export default AreaLayout;
