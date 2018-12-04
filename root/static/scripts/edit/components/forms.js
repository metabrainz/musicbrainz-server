// This file is part of MusicBrainz, the open internet music database.
// Copyright (C) 2016 MetaBrainz Foundation
// Licensed under the GPL version 2, or (at your option) any later version:
// http://www.gnu.org/licenses/gpl-2.0.txt

import React from 'react';
import ReactDOM from 'react-dom';

import {l} from '../../common/i18n';
import {artistCreditFromArray} from '../../common/immutable-entities';
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

MB.initializeArtistCredit = function (form, initialNames) {
  let source = MB.sourceEntity || {name: ''};
  source.artistCredit = artistCreditFromArray(initialNames);

  ReactDOM.render(
    <FormRowArtistCredit entity={source} form={form} />,
    document.getElementById('artist-credit-editor')
  );
};
