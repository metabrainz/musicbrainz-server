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
import LabelSidebar from '../layout/components/sidebar/LabelSidebar.js';

import LabelHeader from './LabelHeader.js';

type Props = {
  +children: React.Node,
  +entity: LabelT,
  +fullWidth?: boolean,
  +page: string,
  +title?: string,
};

const LabelLayout = ({
  children,
  entity: label,
  fullWidth = false,
  page,
  title,
}: Props): React.Element<typeof Layout> => (
  <Layout
    title={nonEmpty(title) ? hyphenateTitle(label.name, title) : label.name}
  >
    <div id="content">
      <LabelHeader label={label} page={page} />
      {children}
    </div>
    {fullWidth ? null : <LabelSidebar label={label} />}
  </Layout>
);


export default LabelLayout;
