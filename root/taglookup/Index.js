/*
 * @flow strict-local
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import Layout from '../layout';

import TagLookupForm from './Form';
import type {TagLookupPropsT} from './types';
import TagLookupNagSection from './Nag';

const TagLookup = (props: TagLookupPropsT): React.Element<typeof Layout> => (
  <Layout fullWidth title={l('Tag Lookup')}>
    <div className="content">
      <h1>{l('Tag Lookup')}</h1>
      {props.nag ? <TagLookupNagSection /> : null}
      <TagLookupForm form={props.form} />
    </div>
  </Layout>
);

export default TagLookup;
