// This file is part of MusicBrainz, the open internet music database.
// Copyright (C) 2014 MetaBrainz Foundation
// Licensed under the GPL version 2, or (at your option) any later version:
// http://www.gnu.org/licenses/gpl-2.0.txt

import $ from 'jquery';
import _ from 'lodash';
import ko from 'knockout';

import MB from '../../../common/MB';

MB.Control.Area = function () {
    var bubble = new MB.Control.BubbleDoc();

    bubble.canBeShown = function (viewModel) {
        return viewModel.area().gid;
    };

    ko.applyBindingsToNode($("#area-bubble")[0], {bubble: bubble});

    _.each(arguments, function (selector) {
        var $span = $(selector);
        var name = $span.find("input.name")[0];
        var ac = MB.Control.EntityAutocomplete({inputs: $span});

        ko.applyBindingsToNode(
            name, {controlsBubble: bubble}, {area: ac.currentSelection},
        );
    });
};

export const initializeArea = MB.Control.Area;
