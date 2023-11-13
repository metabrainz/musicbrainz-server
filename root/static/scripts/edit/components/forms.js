/*
 * Copyright (C) 2016 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import ko from 'knockout';
import {createRef} from 'react';
import {flushSync} from 'react-dom';
import * as ReactDOMClient from 'react-dom/client';

import '../../common/entity.js';

import MB from '../../common/MB.js';

import ArtistCreditEditor from './ArtistCreditEditor.js';
import FieldErrors from './FieldErrors.js';
import FormRow from './FormRow.js';

export const FormRowArtistCredit = ({
  artistCreditEditorRef,
  form,
  entity,
}) => (
  <FormRow>
    <label className="required" htmlFor="entity-artist">
      {addColonText(l('Artist'))}
    </label>
    <ArtistCreditEditor
      entity={entity}
      forLabel="entity-artist"
      form={form}
      hiddenInputs
      // eslint-disable-next-line react/jsx-handler-names
      onChange={entity.artistCredit}
      ref={artistCreditEditorRef}
    />
    {form ? <FieldErrors field={form.field.artist_credit} /> : null}
  </FormRow>
);

MB.initializeArtistCredit = function (form, initialArtistCredit) {
  const source = MB.getSourceEntityInstance() ?? {name: ''};
  source.uniqueID = 'source';
  source.artistCredit = ko.observable(initialArtistCredit);
  source.artistCreditEditorInst = createRef();

  const container = document.getElementById('artist-credit-editor');
  const root = ReactDOMClient.createRoot(container);
  flushSync(() => {
    root.render(
      <FormRowArtistCredit
        artistCreditEditorRef={source.artistCreditEditorInst}
        entity={source}
        form={form}
      />,
    );
  });
};

/*
 * Registers a beforeunload event listener on the window that prompts
 * the user if any of the page's form inputs have been changed.
 */
MB.installFormUnloadWarning = function () {
  let inputsChanged = false;
  let submittingForm = false;

  const form = document.querySelector('#page form');

  /*
   * This is somewhat heavy-handed, in that it will still warn even if the
   * user changes an input back to its original value.
   */
  form.addEventListener('change', () => {
    inputsChanged = true;
  });

  // Disarm the warning when the form is being submitted.
  form.addEventListener('submit', () => {
    submittingForm = true;
  });

  window.addEventListener('beforeunload', event => {
    if (submittingForm) {
      return false;
    }

    // Check if there are pending relationship or URL changes.
    if (!inputsChanged && !form.querySelector([
      '#relationship-editor .rel-add',
      '#relationship-editor .rel-edit',
      '#relationship-editor .rel-remove',
      '#external-links-editor .rel-add',
      '#external-links-editor .rel-edit',
      '#external-links-editor .rel-remove',
    ].join(', '))) {
      return false;
    }

    event.returnValue = l(
      'All of your changes will be lost if you leave this page.',
    );
    return event.returnValue;
  });
};
