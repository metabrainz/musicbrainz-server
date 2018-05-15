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
import {l, lp} from '../../static/scripts/common/i18n';
import DBDefs from '../../static/scripts/common/DBDefs';
import FieldErrors from '../../components/FieldErrors';
import FormRow from '../../components/FormRow';
import FormRowRadio from '../../components/FormRowRadio';
import FormRowSelect from '../../components/FormRowSelect';
import FormRowTextLong from '../../components/FormRowTextLong';
import FormSubmit from '../../components/FormSubmit';
import Frag from '../../components/Frag';

type Props = {|
  +form: SearchFormT,
|};

const limitOptions = {
  grouped: false,
  options: [
    {label: l('Up to {n}', {n: 25}), value: 25},
    {label: l('Up to {n}', {n: 50}), value: 50},
    {label: l('Up to {n}', {n: 100}), value: 100},
  ],
};

const typeOptions = {
  grouped: false,
  options: [
    {label: l('Artist'), value: 'artist'},
    {label: l('Release Group'), value: 'release_group'},
    {label: l('Release'), value: 'release'},
    {label: l('Recording'), value: 'recording'},
    {label: l('Work'), value: 'work'},
    {label: l('Label'), value: 'label'},
    {label: l('Area'), value: 'area'},
    {label: l('Place'), value: 'place'},
    {label: l('Annotation'), value: 'annotation'},
    {label: l('CD Stub'), value: 'cdstub'},
    {label: l('Editor'), value: 'editor'},
    {label: lp('Tag', 'noun'), value: 'tag'},
    {label: l('Instrument'), value: 'instrument'},
    {label: lp('Series', 'singular'), value: 'series'},
    {label: l('Event'), value: 'event'},
  ],
};

if (DBDefs.GOOGLE_CUSTOM_SEARCH) {
  typeOptions.options.push({label: l('Documentation'), value: 'doc'});
}

const methodOptions = [
  {label: l('Indexed search'), value: 'indexed'},
  {
    label: l('Indexed search with {doc|advanced query syntax}', {
      __react: true,
      doc: '/doc/Indexed_Search_Syntax',
    }),
    value: 'advanced',
  },
  {label: l('Direct database search'), value: 'direct'},
];

const SearchForm = ({form}: Props) => {
  const limitField = form.field.limit;
  const methodField = form.field.method;
  return (
    <Frag>
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
            required
          />
          <FormRowSelect
            allowEmpty={false}
            field={form.field.limit}
            label={l('Results per page:')}
            onChange={noop}
            options={limitOptions}
          />
          <FormRowRadio
            field={form.field.method}
            label={l('Search method:')}
            options={methodOptions}
            required
          />
          <div className="row no-label">
            <FormSubmit label={l('Search')} />
          </div>
        </form>
      </div>
      <div className="searchinfo">
        <strong>{l('Please note:')}</strong>
        <p>{l('Search indexes are updated every 3 hours, use the direct database search if you require up to the minute correct results.')}</p>
      </div>
    </Frag>
  );
};

export default SearchForm;
