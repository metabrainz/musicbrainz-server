/*
 * @flow
 * Copyright (C) 2020 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import sortByEntityName
  from '../static/scripts/common/utility/sortByEntityName';
import EnterEdit from '../components/EnterEdit';
import EnterEditNote from '../components/EnterEditNote';
import FieldErrors from '../components/FieldErrors';
import PlaceList from '../components/list/PlaceList';
import {withCatalystContext} from '../context';
import Layout from '../layout';

type Props = {
  +$c: CatalystContextT,
  +form: MergeFormT,
  +toMerge: $ReadOnlyArray<PlaceT>,
};

const PlaceMerge = ({$c, form, toMerge}: Props) => (
  <Layout fullWidth title={l('Merge places')}>
    <div id="content">
      <h1>{l('Merge places')}</h1>
      <p>
        {l(`You are about to merge the following places into a single
            place. Please select the place which you would like other
            places to be merged into:`)}
      </p>
      <form action={$c.req.uri} method="post">
        <PlaceList
          mergeForm={form}
          places={sortByEntityName(toMerge)}
        />
        <FieldErrors field={form.field.target} />

        <EnterEditNote field={form.field.edit_note} />

        <EnterEdit form={form}>
          <button
            className="negative"
            name="submit"
            type="submit"
            value="cancel"
          >
            {l('Cancel')}
          </button>
        </EnterEdit>
      </form>
    </div>
  </Layout>
);

export default withCatalystContext(PlaceMerge);
