/*
 * @flow strict-local
 * Copyright (C) 2020 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import Layout from '../layout';

import OtherLookupForm from './OtherLookupForm';
import type {OtherLookupFormT} from './types';

type Props = {
  +form: OtherLookupFormT,
};

const OtherLookupIndex = ({
  form,
}: Props): React.Element<typeof Layout> => (
  <Layout fullWidth title={l('Other Lookups')}>
    <div className="content">
      <h1>{l('Other Lookups')}</h1>
      <OtherLookupForm form={form} />
    </div>
  </Layout>
);

export default OtherLookupIndex;
