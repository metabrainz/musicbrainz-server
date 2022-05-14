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
import MoodSidebar from '../layout/components/sidebar/MoodSidebar';

import MoodHeader from './MoodHeader';

type Props = {
  +children: React.Node,
  +entity: MoodT,
  +fullWidth?: boolean,
  +page: string,
  +title?: string,
};

const MoodLayout = ({
  children,
  entity: mood,
  fullWidth = false,
  page,
  title,
}: Props): React.Element<typeof Layout> => (
  <Layout
    title={nonEmpty(title) ? hyphenateTitle(mood.name, title) : mood.name}
  >
    <div id="content">
      <MoodHeader mood={mood} page={page} />
      {children}
    </div>
    {fullWidth ? null : <MoodSidebar mood={mood} />}
  </Layout>
);


export default MoodLayout;
