/*
 * @flow
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import Layout from '../layout';

import TagLookupForm from './Form';
import TagLookupNagSection from './Nag';
import type {TagLookupResultsPropsT, TagLookupResultsReactTablePropsT}
  from './types';

export const TagLookupResultsReactTable = <T>(
  props: TagLookupResultsReactTablePropsT<T>,
): React.Element<typeof Layout> => (
    <Layout $c={props.$c} fullWidth title={l('Tag Lookup Results')}>
      <div className="content">
        <h1>{l('Tag Lookup Results')}</h1>
        {props.nag ? <TagLookupNagSection /> : null}
        {props.children}
        <TagLookupForm form={props.form} />
      </div>
    </Layout>
  );

const TagLookupResults = <T>(
  props: TagLookupResultsPropsT<T>,
): React.Element<typeof Layout> => (
  <Layout $c={props.$c} fullWidth title={l('Tag Lookup Results')}>
    <div className="content">
      <h1>{l('Tag Lookup Results')}</h1>
      {props.nag ? <TagLookupNagSection /> : null}
      {props.children}
      <TagLookupForm form={props.form} />
    </div>
  </Layout>
);

export default TagLookupResults;
