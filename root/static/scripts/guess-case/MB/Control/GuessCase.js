/*
 * Copyright (C) 2015 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import $ from 'jquery';
import ko from 'knockout';

import getBooleanCookie from '../../../common/utility/getBooleanCookie';
import setCookie from '../../../common/utility/setCookie';
import gc from '../GuessCase/Main';
import * as modes from '../../modes';
import MB from '../../../common/MB';

MB.Control.initializeGuessCase = function (type, formPrefix) {
  formPrefix = formPrefix ? (formPrefix + '\\.') : '';

  const $name = $('#' + formPrefix + 'name');
  const $options = $('#guesscase-options');

  if ($options.length && !$options.data('ui-dialog')) {
    $options.dialog({title: l('Guess Case Options'), autoOpen: false});
    ko.applyBindingsToNode($options[0], {guessCase: () => undefined});
  }

  const guess = gc.entities[type];

  function setVal($input, value) {
    $input.val(value).trigger('change');
  }

  $name.parent()
    .find('button.guesscase-title')
    .on('click', function () {
      setVal($name, guess.guess($name.val()));
    })
    .end()
    .find('button.guesscase-options')
    .on('click', function () {
      $options.dialog('open');
    });

  const $sortname = $('#' + formPrefix + 'sort_name');
  const $artistType = $('#id-edit-artist\\.type_id');

  $sortname.parent()
    .find('button.guesscase-sortname').on('click', function () {
      const args = [$name.val()];

      if (type === 'artist') {
        args.push($artistType.val() != 2 /* person */);
      }

      setVal($sortname, guess.sortname.apply(guess, args));
    })
    .end()
    .find('button.sortname-copy')
    .on('click', function () {
      setVal($sortname, $name.val());
    });
};

const guessCaseOptions = {
  modeName: ko.observable(),
  keepUpperCase: ko.observable(),
  upperCaseRoman: ko.observable(),
};

const mode = ko.computed({
  read: function () {
    const modeName = guessCaseOptions.modeName();

    if (modeName !== gc.modeName) {
      gc.modeName = modeName;
      setCookie('guesscase_mode', modeName);
    }
    return modes[modeName];
  },
  deferEvaluation: true,
});

guessCaseOptions.help = ko.computed({
  read: function () {
    return mode().description;
  },
  deferEvaluation: true,
});

guessCaseOptions.keepUpperCase.subscribe(function (value) {
  gc.CFG_KEEP_UPPERCASED = value;
  setCookie('guesscase_keepuppercase', value);
});

guessCaseOptions.upperCaseRoman.subscribe(function (value) {
  setCookie('guesscase_roman', value);
});

ko.bindingHandlers.guessCase = {

  init: function (
    element,
    valueAccessor,
    allBindingsAccessor,
    viewModel,
    bindingContext,
  ) {
    if (!guessCaseOptions.modeName.peek()) {
      guessCaseOptions.modeName(gc.modeName);
    }

    if (!guessCaseOptions.keepUpperCase.peek()) {
      guessCaseOptions.keepUpperCase(gc.CFG_KEEP_UPPERCASED);
    }

    if (!guessCaseOptions.upperCaseRoman.peek()) {
      guessCaseOptions.upperCaseRoman(getBooleanCookie('guesscase_roman'));
    }

    const bindings = {...guessCaseOptions};
    bindings.guessCase = valueAccessor().bind(bindings);

    const context = bindingContext.createChildContext(bindings);
    ko.applyBindingsToDescendants(context, element);

    return {controlsDescendantBindings: true};
  },
};

ko.virtualElements.allowedBindings.guessCase = true;

export const initializeGuessCase = MB.Control.initializeGuessCase;
