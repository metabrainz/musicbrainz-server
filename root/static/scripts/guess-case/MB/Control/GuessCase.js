/*
 * Copyright (C) 2015 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import $ from 'jquery';
import ko from 'knockout';

import '../../../../lib/jquery.ui/ui/jquery-ui.custom.js';
import '../../../common/dialogs.js';

import getBooleanCookie from '../../../common/utility/getBooleanCookie.js';
import setCookie from '../../../common/utility/setCookie.js';
import * as modes from '../../modes.js';
import gc from '../GuessCase/Main.js';

export default function initializeGuessCase(type, formPrefix) {
  formPrefix = formPrefix ? (formPrefix + '\\.') : '';

  var $name = $('#' + formPrefix + 'name');
  var $options = $('#guesscase-options');

  if ($options.length && !$options.data('ui-dialog')) {
    $options.dialog({title: l('Guess case options'), autoOpen: false});
    ko.applyBindingsToNode($options[0], {guessCase: () => undefined});
    $options[0].style.display = 'unset';
  }

  var guess = gc.entities[type];

  function setVal($input, value) {
    $input.val(value).trigger('change');
    $input.removeData('orig-value');
    $input.removeClass('preview');
  }
  function showPreview($input, value) {
    const orig = $input.val();
    if (value !== orig) {
      $input.val(value);
      $input.data('orig-value', orig);
      $input.addClass('preview');
    }
  }
  function hidePreview($input) {
    const orig = $input.data('orig-value');
    if (orig !== undefined) {
      $input.val(orig);
      $input.removeData('orig-value');
      $input.removeClass('preview');
    }
  }

  $name.parent()
    .find('button.guesscase-title')
    .on('click', () => setVal($name, guess.guess($name.val())))
    .on('mouseenter', (event) => {
      // Don't change the value while the user is dragging to select text.
      if (event.originalEvent.buttons === 0) {
        showPreview($name, guess.guess($name.val()));
      }
    })
    .on('mouseleave', () => hidePreview($name))
    .end()
    .find('button.guesscase-options')
    .on('click', function () {
      $options.dialog('open');
    });

  var $sortname = $('#' + formPrefix + 'sort_name');
  var $artistType = $('#id-edit-artist\\.type_id');

  function guessSortName() {
    var args = [$name.val()];
    if (type === 'artist') {
      args.push($artistType.val() != 2 /* person */);
    }
    return guess.sortname(...args);
  }

  $sortname.parent()
    .find('button.guesscase-sortname')
    .on('click', () => setVal($sortname, guessSortName()))
    .on('mouseenter', (event) => {
      if (event.originalEvent.buttons === 0) {
        showPreview($sortname, guessSortName());
      }
    })
    .on('mouseleave', () => hidePreview($sortname))
    .end()
    .find('button.sortname-copy')
    .on('click', function () {
      setVal($sortname, $name.val());
    });
}

var guessCaseOptions = {
  modeName: ko.observable(),
  keepUpperCase: ko.observable(),
  upperCaseRoman: ko.observable(),
};

var mode = ko.computed({
  read() {
    var modeName = guessCaseOptions.modeName();

    if (modeName !== gc.modeName) {
      gc.modeName = modeName;
      setCookie('guesscase_mode', modeName);
    }
    return modes[modeName];
  },
  deferEvaluation: true,
});

guessCaseOptions.help = ko.computed({
  read() {
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

  init(
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

    var bindings = {...guessCaseOptions};
    bindings.guessCase = valueAccessor().bind(bindings);

    var context = bindingContext.createChildContext(bindings);
    ko.applyBindingsToDescendants(context, element);

    return {controlsDescendantBindings: true};
  },
};

ko.virtualElements.allowedBindings.guessCase = true;
