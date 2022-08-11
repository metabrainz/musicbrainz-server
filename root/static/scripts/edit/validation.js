/*
 * Copyright (C) 2015 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import ko from 'knockout';

import MB from '../common/MB.js';

export const errorFields = ko.observableArray([]);

export function errorField(func) {
  const observable = ko.isObservable(func) ? func : ko.computed(func);
  errorFields.push(observable);
  return observable;
}

export const errorsExist = ko.computed(function () {
  const fields = errorFields();

  for (let i = 0, len = fields.length; i < len; i++) {
    if (fields[i]()) {
      return true;
    }
  }

  return false;
});

// XXX needed by inline scripts
MB.validation = {
  errorField: errorField,
  errorFields: errorFields,
  errorsExist: errorsExist,
};

if (typeof document !== 'undefined') {
  const $ = require('jquery');

  const clean = require('../common/utility/clean').default;

  errorsExist.subscribe(function (value) {
    $('#page form button[type=submit]').prop('disabled', value);
  });

  $(document).on('submit', '#page form', function (event) {
    if (errorsExist()) {
      event.preventDefault();
    }
  });

  $(function () {
    $('#page form :input[required]').each(function () {
      const $input = $(this);

      /*
       * XXX We can't handle artist credit fields here. They have
       * separate hidden inputs that are injected by knockout.
       */
      if ($input.is('.artist-credit-input')) {
        return;
      }

      const error = errorField(ko.observable(!clean($input.val())));

      $input.on('input change', function () {
        error(!clean(this.value));
      });
    });
  });
}
