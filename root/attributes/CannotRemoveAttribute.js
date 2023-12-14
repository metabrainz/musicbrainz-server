/*
 * @flow strict
 * Copyright (C) 2021 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import Layout from '../layout/index.js';

type Props = {
  +message: string,
};

const CannotRemoveAttribute = ({
  message,
}: Props): React$Element<typeof Layout> => (
  <Layout fullWidth title="Cannot remove attribute">
    <h1>{'Cannot remove attribute'}</h1>
    <p>
      {message}
    </p>
  </Layout>
);

export default CannotRemoveAttribute;
