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
import WorkSidebar from '../layout/components/sidebar/WorkSidebar';

import WorkHeader from './WorkHeader';

type Props = {|
  +children: ReactNode,
  +entity: WorkT,
  +fullWidth?: boolean,
  +page: string,
  +title?: string,
|};

const WorkLayout = ({
  children,
  entity: work,
  fullWidth,
  page,
  title,
}: Props) => {
  const mainTitle = texp.l('{type} “{work}”', {
    type: work.typeName ? lp_attributes(work.typeName, 'work_type') : l('Work'),
    work: work.name,
  });
  return (
    <Layout
      title={title ? hyphenateTitle(mainTitle, title) : mainTitle}
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
