/*
 * @flow strict-local
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import WorkSidebar from '../layout/components/sidebar/WorkSidebar.js';
import Layout from '../layout/index.js';

import WorkHeader from './WorkHeader.js';

type Props = {
  +children: React.Node,
  +entity: WorkT,
  +fullWidth?: boolean,
  +page: string,
  +title?: string,
};

const WorkLayout = ({
  children,
  entity: work,
  fullWidth = false,
  page,
  title,
}: Props): React$Element<typeof Layout> => {
  const mainTitle = texp.l('{type} “{work}”', {
    type: nonEmpty(work.typeName)
      ? lp_attributes(work.typeName, 'work_type')
      : l('Work'),
    work: work.name,
  });
  return (
    <Layout
      title={nonEmpty(title) ? hyphenateTitle(mainTitle, title) : mainTitle}
    >
      <div id="content">
        <WorkHeader page={page} work={work} />
        {children}
      </div>
      {fullWidth ? null : <WorkSidebar work={work} />}
    </Layout>
  );
};

export default WorkLayout;
