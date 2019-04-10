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
import LabelSidebar from '../layout/components/sidebar/LabelSidebar';

import LabelHeader from './LabelHeader';

type Props = {|
  +children: ReactNode,
  +entity: LabelT,
  +fullWidth?: boolean,
  +page: string,
  +title?: string,
|};

const LabelLayout = ({
  children,
  entity: label,
  fullWidth,
  page,
  title,
}: Props) => (
  <Layout
    title={title ? hyphenateTitle(label.name, title) : label.name}
  >
    <div id="content">
      <LabelHeader label={label} page={page} />
      {children}
    </div>
    {fullWidth ? null : <LabelSidebar label={label} />}
  </Layout>
);


export default LabelLayout;
