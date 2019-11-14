// This file is part of MusicBrainz, the open internet music database.
// Copyright (C) 2015 MetaBrainz Foundation
// Licensed under the GPL version 2, or (at your option) any later version:
// http://www.gnu.org/licenses/gpl-2.0.txt

import $ from 'jquery';
import _ from 'lodash';
import ko from 'knockout';

import getBooleanCookie from '../../../common/utility/getBooleanCookie';
import setCookie from '../../../common/utility/setCookie';
import gc from '../GuessCase/Main';
import * as modes from '../../modes';
import MB from '../../../common/MB';

MB.Control.initialize_guess_case = function (type, formPrefix) {
    formPrefix = formPrefix ? (formPrefix + '\\.') : '';

    var $name = $('#' + formPrefix + 'name');
    var $options = $('#guesscase-options');

    if ($options.length && !$options.data('ui-dialog')) {
        $options.dialog({title: l('Guess Case Options'), autoOpen: false});
        ko.applyBindingsToNode($options[0], {guessCase: _.noop});
    }

    var guess = MB.GuessCase[type];

    function setVal($input, value) {
        $input.val(value).trigger('change');
    }

    $name.parent()
        .find('button.guesscase-title').on('click', function () { setVal($name, guess.guess($name.val())) })
        .end()
        .find('button.guesscase-options').on('click', function () { $options.dialog('open') });

    var $sortname = $('#' + formPrefix + 'sort_name');
    var $artistType = $('#id-edit-artist\\.type_id');

    $sortname.parent()
        .find('button.guesscase-sortname').on('click', function () {
            var args = [$name.val()];

            if (type === 'artist') {
                args.push($artistType.val() != 2 /* person */);
            }

            setVal($sortname, guess.sortname.apply(guess, args));
        })
        .end()
        .find('button.sortname-copy').on('click', function () {
            setVal($sortname, $name.val());
        });
};

var guessCaseOptions = {
    modeName: ko.observable(),
    keepUpperCase: ko.observable(),
    upperCaseRoman: ko.observable(),
};

var mode = ko.computed({
    read: function () {
        var modeName = guessCaseOptions.modeName()

        if (modeName !== gc.modeName) {
            gc.modeName = modeName;
            gc.mode = modes[modeName];
            setCookie('guesscase_mode', modeName);
        }
        return gc.mode;
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
    gc.CFG_UC_UPPERCASED = value;
    setCookie('guesscase_keepuppercase', value);
});

guessCaseOptions.upperCaseRoman.subscribe(function (value) {
    setCookie('guesscase_roman', value);
});

ko.bindingHandlers.guessCase = {

    init: function (element, valueAccessor, allBindingsAccessor, viewModel, bindingContext) {
        if (!guessCaseOptions.modeName.peek()) {
            guessCaseOptions.modeName(gc.modeName);
        }

        if (!guessCaseOptions.keepUpperCase.peek()) {
            guessCaseOptions.keepUpperCase(gc.CFG_UC_UPPERCASED);
        }

        if (!guessCaseOptions.upperCaseRoman.peek()) {
            guessCaseOptions.upperCaseRoman(getBooleanCookie('guesscase_roman'));
        }

        var bindings = {...guessCaseOptions};
        bindings.guessCase = _.bind(valueAccessor(), bindings);

        var context = bindingContext.createChildContext(bindings);
        ko.applyBindingsToDescendants(context, element);

        return {controlsDescendantBindings: true};
    },
};

ko.virtualElements.allowedBindings.guessCase = true;

export const initialize_guess_case = MB.Control.initialize_guess_case;
