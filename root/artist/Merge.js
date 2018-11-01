/*
 * @flow
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import React from 'react';
import sortBy from 'lodash/sortBy';

import EnterEdit from '../components/EnterEdit';
import EnterEditNote from '../components/EnterEditNote';
import FieldErrors from '../components/FieldErrors';
import FormRowCheckbox from '../components/FormRowCheckbox';
import {withCatalystContext} from '../context';
import Layout from '../layout';
import DescriptiveLink from '../static/scripts/common/components/DescriptiveLink';
import {l} from '../static/scripts/common/i18n';

type ArtistMergeForm = FormT<{|
  +edit_note: FieldT<string>,
  +make_votable: FieldT<boolean>,
  +merging: RepeatableFieldT<FieldT<number>>,
  +rename: FieldT<boolean>,
  +target: FieldT<number>,
|}>;

type Props = {|
  +$c: CatalystContextT,
  +form: ArtistMergeForm,
  +toMerge: $ReadOnlyArray<ArtistT>,
|};

const buildMergeTarget = (artist, index) => (
  <li key={artist.id}>
    <input name={'merge.merging.' + index} type="hidden" value={artist.id} />
    <input name="merge.target" type="radio" value={artist.id} />
    <DescriptiveLink entity={artist} />
  </li>
);

const MergeArtists = ({$c, form, toMerge}: Props) => (
  <Layout fullWidth title={l('Merge Artists')}>
    <div id="content">
      <h1>{l('Merge Artists')}</h1>
      <p>{l('You are about to merge the following artists into a single artist. Please select the artist which you would like other artists to be merged into:')}</p>
      <form action={$c.req.uri} method="post">
        <ul>
          {sortBy(toMerge, 'name').map(buildMergeTarget)}
        </ul>
        <FieldErrors field={form.field.target} />

        <FormRowCheckbox
          field={form.field.rename}
          label={l('Update matching artist and relationship credits to use the new artist’s name')}
        />

        <EnterEditNote field={form.field.edit_note} />

        <EnterEdit form={form}>
          <button className="negative" name="submit" type="submit" value="cancel">
            {l('Cancel')}
          </button>
        </EnterEdit>
      </form>
    </div>
  </Layout>
);

export default withCatalystContext(MergeArtists);
