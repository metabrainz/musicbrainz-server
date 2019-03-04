/*
 * @flow
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import React from 'react';
import type {Node as ReactNode} from 'react';

import Layout from '../layout';
import AreaSidebar from '../layout/components/sidebar/AreaSidebar';
import localizeAreaName from '../static/scripts/common/i18n/localizeAreaName';

import AreaHeader from './AreaHeader';

type Props = {|
  +children: ReactNode,
  +entity: AreaT,
  +fullWidth?: boolean,
  +page: string,
  +title?: string,
|};

const AreaLayout = ({
  children,
  entity: area,
  fullWidth,
  page,
  title,
}: Props) => (
  <Layout
    title={title
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
