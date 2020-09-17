/*
 * @flow strict-local
 * Copyright (C) 2020 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import Layout from '../../layout';

type Props = {
  +$c: CatalystContextT,
  +children: React.Node,
  +title: string,
};

const ErrorLayout = ({
  $c,
  children,
  title,
}: Props): React.Element<typeof Layout> => (
  <Layout $c={$c} fullWidth title={title}>
    <div id="content">
      <h1>{title}</h1>
      {children}
    </div>
  </Layout>
);

export default ErrorLayout;
