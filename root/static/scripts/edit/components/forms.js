// This file is part of MusicBrainz, the open internet music database.
// Copyright (C) 2016 MetaBrainz Foundation
// Licensed under the GPL version 2, or (at your option) any later version:
// http://www.gnu.org/licenses/gpl-2.0.txt

const React = require('react');
const ReactDOM = require('react-dom');

const {l} = require('../../common/i18n');
const {artistCreditFromArray} = require('../../common/immutable-entities');
const MB = require('../../common/MB');
const ArtistCreditEditor = require('./ArtistCreditEditor');
import FieldErrors from '../../../../components/FieldErrors';
import FormRow from '../../../../components/FormRow';

const FormRowArtistCredit = ({form, entity}) => (
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

exports.FormRowArtistCredit = FormRowArtistCredit;
