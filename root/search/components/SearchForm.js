/*
 * @flow
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import noop from 'lodash/noop';
import React from 'react';

import {l, N_l, N_lp, TEXT} from '../../static/scripts/common/i18n';
import * as DBDefs from '../../static/scripts/common/DBDefs';
import FormRowRadio from '../../components/FormRowRadio';
import FormRowSelect from '../../components/FormRowSelect';
import FormRowTextLong from '../../components/FormRowTextLong';
import FormSubmit from '../../components/FormSubmit';

type Props = {|
  +form: SearchFormT,
|};

const limitOptions = {
  grouped: false,
  options: [
    {label: () => l('Up to {n}', {n: 25}, TEXT), value: 25},
    {label: () => l('Up to {n}', {n: 50}, TEXT), value: 50},
    {label: () => l('Up to {n}', {n: 100}, TEXT), value: 100},
  ],
};

const typeOptions = {
  grouped: false,
  options: [
    {label: N_l('Artist'), value: 'artist'},
    {label: N_l('Release Group'), value: 'release_group'},
    {label: N_l('Release'), value: 'release'},
    {label: N_l('Recording'), value: 'recording'},
    {label: N_l('Work'), value: 'work'},
    {label: N_l('Label'), value: 'label'},
    {label: N_l('Area'), value: 'area'},
    {label: N_l('Place'), value: 'place'},
    {label: N_l('Annotation'), value: 'annotation'},
    {label: N_l('CD Stub'), value: 'cdstub'},
    {label: N_l('Editor'), value: 'editor'},
    {label: N_lp('Tag', 'noun'), value: 'tag'},
    {label: N_l('Instrument'), value: 'instrument'},
    {label: N_lp('Series', 'singular'), value: 'series'},
    {label: N_l('Event'), value: 'event'},
  ],
};

if (DBDefs.GOOGLE_CUSTOM_SEARCH) {
  typeOptions.options.push({label: N_l('Documentation'), value: 'doc'});
}

const methodOptions = [
  {label: N_l('Indexed search'), value: 'indexed'},
  {
    label: () => l('Indexed search with {doc|advanced query syntax}', {
      doc: '/doc/Indexed_Search_Syntax',
    }),
    value: 'advanced',
  },
  {label: N_l('Direct database search'), value: 'direct'},
];

const SearchForm = ({form}: Props) => (
  <>
    <div className="searchform">
      <form action="/search" method="get">
        <FormRowTextLong
          field={form.field.query}
          label={l('Query:')}
          required
        />
        <FormRowSelect
          field={form.field.type}
          label={l('Type:')}
          onChange={noop}
          options={typeOptions}
        />
        <FormRowSelect
          field={form.field.limit}
          label={l('Results per page:')}
          onChange={noop}
          options={limitOptions}
        />
        <FormRowRadio
          field={form.field.method}
          label={l('Search method:')}
          options={methodOptions}
        />
        <div className="row no-label">
          <FormSubmit label={l('Search')} />
        </div>
      </form>
    </div>
    <div className="searchinfo">
      <p>
        {l('For more information, check the {doc_doc|documentation}.', {
          doc_doc: '/doc/Search',
        })}
      </p>
    </div>
  </>
);

export default SearchForm;
