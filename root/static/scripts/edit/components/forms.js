/*
 * Copyright (C) 2016 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import ko from 'knockout';
import {flushSync} from 'react-dom';
import * as ReactDOMClient from 'react-dom/client';

import '../../common/entity.js';
import MB from '../../common/MB.js';

import ArtistCreditEditor from './ArtistCreditEditor.js';
import FieldErrors from './FieldErrors.js';
import FormRow from './FormRow.js';

export const FormRowArtistCredit = ({form, entity}) => (
  <FormRow>
    <label className="required" htmlFor="entity-artist">
      {l('Artist:')}
    </label>
    <ArtistCreditEditor
      entity={entity}
      forLabel="entity-artist"
      form={form}
      hiddenInputs
    />
    {form ? <FieldErrors field={form.field.artist_credit} /> : null}
  </FormRow>
);

MB.initializeArtistCredit = function (form, initialArtistCredit) {
  const source = MB.sourceEntity || {name: ''};
  source.artistCredit = ko.observable(initialArtistCredit);

  const container = document.getElementById('artist-credit-editor');
  const root = ReactDOMClient.createRoot(container);
  flushSync(() => {
    root.render(
      <FormRowArtistCredit entity={source} form={form} />,
    );
  });

  source.artistCredit.subscribe((artistCredit) => {
    $('table.artist-credit-editor', container)
      .data('componentInst')
      .setState({artistCredit});
  });
};
