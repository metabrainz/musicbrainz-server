/*
 * @flow strict
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import DBDefs from '../../static/scripts/common/DBDefs.mjs';
import FormRowRadio
  from '../../static/scripts/edit/components/FormRowRadio.js';
import FormRowSelect
  from '../../static/scripts/edit/components/FormRowSelect.js';
import FormRowTextLong
  from '../../static/scripts/edit/components/FormRowTextLong.js';
import FormSubmit from '../../static/scripts/edit/components/FormSubmit.js';

type Props = {
  +form: SearchFormT,
};

const limitOptions = {
  grouped: false,
  options: [
    {label: () => texp.l('Up to {n}', {n: 25}), value: 25},
    {label: () => texp.l('Up to {n}', {n: 50}), value: 50},
    {label: () => texp.l('Up to {n}', {n: 100}), value: 100},
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
    label: () => exp.l('Indexed search with {doc|advanced query syntax}', {
      doc: '/doc/Indexed_Search_Syntax',
    }),
    value: 'advanced',
  },
  {label: N_l('Direct database search'), value: 'direct'},
];

const SearchForm = ({
  form,
}: Props): React$Element<typeof React.Fragment> => (
  <>
    <div className="searchform">
      <form action="/search" method="get">
        <FormRowTextLong
          field={form.field.query}
          label={l('Query:')}
          required
          uncontrolled
        />
        <FormRowSelect
          field={form.field.type}
          label={l('Type:')}
          options={typeOptions}
          uncontrolled
        />
        <FormRowSelect
          field={form.field.limit}
          label={l('Results per page:')}
          options={limitOptions}
          uncontrolled
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
        {exp.l('For more information, check the {doc_doc|documentation}.', {
          doc_doc: '/doc/Search',
        })}
      </p>
    </div>
  </>
);

export default SearchForm;
