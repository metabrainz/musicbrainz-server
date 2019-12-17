/*
 * @flow
 * Copyright (C) 2019 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import React from 'react';

import {withCatalystContext} from '../context';
import CleanupBanner from '../components/CleanupBanner';
import FormRow from '../components/FormRow';
import FormSubmit from '../components/FormSubmit';
import PaginatedResults from '../components/PaginatedResults';
import WikipediaExtract
  from '../static/scripts/common/components/WikipediaExtract';
import ReleaseList from '../components/list/ReleaseList';
import * as manifest from '../static/manifest';
import Annotation from '../static/scripts/common/components/Annotation';

import LabelLayout from './LabelLayout';

type Props = {
  +$c: CatalystContextT,
  +eligibleForCleanup: boolean,
  +label: LabelT,
  +numberOfRevisions: number,
  +pager: PagerT,
  +releases: ?$ReadOnlyArray<ReleaseT>,
  +wikipediaExtract: WikipediaExtractT | null,
};

const LabelIndex = ({
  $c,
  eligibleForCleanup,
  label,
  numberOfRevisions,
  pager,
  releases,
  wikipediaExtract,
}: Props) => (
  <LabelLayout entity={label} page="index">
    {eligibleForCleanup ? (
      <CleanupBanner entityType="label" />
    ) : null}
    <Annotation
      annotation={label.latest_annotation}
      collapse
      entity={label}
      numberOfRevisions={numberOfRevisions}
    />
    <WikipediaExtract
      cachedWikipediaExtract={wikipediaExtract}
      entity={label}
    />
    <h2 className="releases">{l('Releases')}</h2>
    {releases?.length ? (
      <form action="/release/merge_queue" method="post">
        <PaginatedResults pager={pager}>
          <ReleaseList
            checkboxes="add-to-merge"
            filterLabel={label}
            releases={releases}
          />
        </PaginatedResults>
        {$c.user_exists ? (
          <FormRow>
            <FormSubmit label={l('Add selected releases for merging')} />
          </FormRow>
        ) : null}
      </form>
    ) : (
      <p>{l('This label does not have any releases.')}</p>
    )}
    {manifest.js('label/index.js', {async: 'async'})}
  </LabelLayout>
);

export default withCatalystContext(LabelIndex);
