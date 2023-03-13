/*
 * @flow strict
 * Copyright (C) 2020 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import Layout from '../../layout/index.js';

type Props = {
  +children: React$Node,
  +title: string,
};

const ErrorLayout = ({
  children,
  title,
}: Props): React$Element<typeof Layout> => (
  <Layout fullWidth title={title}>
    <div id="content">
      <h1>{title}</h1>
      {children}
    </div>
  </Layout>
);

export default ErrorLayout;
