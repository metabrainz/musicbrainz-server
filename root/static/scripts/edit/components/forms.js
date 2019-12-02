/*
 * Copyright (C) 2016 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import ko from 'knockout';
import React from 'react';
import ReactDOM from 'react-dom';

import MB from '../../common/MB';
import FieldErrors from '../../../../components/FieldErrors';
import FormRow from '../../../../components/FormRow';

import ArtistCreditEditor from './ArtistCreditEditor';

export const FormRowArtistCredit = ({form, entity}) => (
  <FormRow>
    <label htmlFor="entity-artist" className="required">
      {l('Artist:')}
    </label>
    <ArtistCreditEditor
      entity={entity}
      forLabel="entity-artist"
      form={form}
      hiddenInputs={true} />
    {form ? <FieldErrors field={form.field.artist_credit} /> : null}
  </FormRow>
);

MB.initializeArtistCredit = function (form, initialArtistCredit) {
  const source = MB.sourceEntity || {name: ''};
  source.artistCredit = ko.observable(initialArtistCredit);

  const container = document.getElementById('artist-credit-editor');
  ReactDOM.render(
    <FormRowArtistCredit entity={source} form={form} />,
    container,
  );

  source.artistCredit.subscribe((artistCredit) => {
    $('table.artist-credit-editor', container)
      .data('componentInst')
      .setState({artistCredit});
  });
};
