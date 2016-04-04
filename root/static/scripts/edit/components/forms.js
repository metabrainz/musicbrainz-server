// This file is part of MusicBrainz, the open internet music database.
// Copyright (C) 2016 MetaBrainz Foundation
// Licensed under the GPL version 2, or (at your option) any later version:
// http://www.gnu.org/licenses/gpl-2.0.txt

const React = require('react');
const ReactDOM = require('react-dom');

const {l} = require('../../common/i18n');
const {artistCreditFromArray} = require('../../common/immutable-entities');
const ArtistCreditEditor = require('./ArtistCreditEditor');

const FieldErrors = ({form, fieldName}) => {
  let field = form.field[fieldName];
  if (field && (field.has_errors || field.error_fields)) {
    return (
      <ul className="errors">
        <For each="error" of={field.errors}>
          <li>{error}</li>
        </For>
        <For each="field" of={field.error_fields}>
          <For each="error" of={field.errors}>
            <li>{error}</li>
          </For>
        </For>
      </ul>
    );
  }
  return null;
};

const FormRow = ({children, ...props}) => (
  <div className="row" {...props}>
    {children}
  </div>
);

const FormRowArtistCredit = ({form, entity, initialNames}) => (
  <FormRow>
    <label htmlFor="entity-artist" className="required">
      {l('Artist:')}
    </label>
    <ArtistCreditEditor
      entity={entity}
      forLabel="entity-artist"
      form={form}
      hiddenInputs={true}
      initialNames={initialNames} />
    <If condition={form}>
      <FieldErrors form={form} fieldName="artist_credit" />
    </If>
  </FormRow>
);

MB.initializeArtistCredit = function (form, initialNames) {
  let source = MB.sourceEntity || {name: ''};
  source.artistCredit = artistCreditFromArray(initialNames);

  ReactDOM.render(
    <FormRowArtistCredit
      entity={source}
      form={form}
      initialNames={initialNames} />,
    document.getElementById('artist-credit-editor')
  );
};

exports.FieldErrors = FieldErrors;
exports.FormRow = FormRow;
exports.FormRowArtistCredit = FormRowArtistCredit;
