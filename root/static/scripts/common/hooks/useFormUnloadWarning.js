/*
 * @flow strict
 * Copyright (C) 2025 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import {useEffect} from 'react';

export default function useFormUnloadWarning() {
  useEffect(() => {
    let inputsChanged = false;
    let submittingForm = false;

    const form = document.querySelector('#page form');

    if (!form) {
      return;
    }

    function setInputsChanged() {
      inputsChanged = true;
    }

    function setSubmittingForm() {
      submittingForm = true;
    }

    function addFormUnloadWarning(event: Event) {
      if (submittingForm) {
        return;
      }

      // Check if there are pending relationship or URL changes.
      if (!inputsChanged && !form?.querySelector([
        '#relationship-editor .rel-add',
        '#relationship-editor .rel-edit',
        '#relationship-editor .rel-remove',
        '#external-links-editor .rel-add',
        '#external-links-editor .rel-edit',
        '#external-links-editor .rel-remove',
      ].join(', '))) {
        return;
      }

      if (MUSICBRAINZ_RUNNING_TESTS) {
        sessionStorage.setItem('didShowBeforeUnloadAlert', 'true');
      }

      event.preventDefault();
    }

    /*
     * This is somewhat heavy-handed, in that it will still warn even if the
     * user changes an input back to its original value.
     */
    form.addEventListener('change', setInputsChanged);

    // Disarm the warning when the form is being submitted.
    form.addEventListener('submit', setSubmittingForm);

    window.addEventListener('beforeunload', addFormUnloadWarning);
    // eslint-disable-next-line consistent-return
    return () => {
      form.removeEventListener('change', setInputsChanged);
      form.removeEventListener('submit', setSubmittingForm);
      window.removeEventListener('beforeunload', addFormUnloadWarning);
    };
  }, []);
}
