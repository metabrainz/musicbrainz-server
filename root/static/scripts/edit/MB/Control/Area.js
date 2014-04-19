// This file is part of MusicBrainz, the open internet music database.
// Copyright (C) 2014 MetaBrainz Foundation
// Licensed under the GPL version 2, or (at your option) any later version:
// http://www.gnu.org/licenses/gpl-2.0.txt

MB.Control.Area = function () {
    var bubble =  MB.Control.BubbleDoc().extend({
        canBeShown: function (viewModel) { return viewModel.area().gid }
    });

    ko.applyBindingsToNode($("#area-bubble")[0], { bubble: bubble });

    _(arguments).each(function (selector) {
        var $span = $(selector);
        var name = $span.find("input.name")[0];
        var ac = MB.Control.EntityAutocomplete({ inputs: $span });

        ko.applyBindingsToNode(
            name, { controlsBubble: bubble }, { area: ac.currentSelection }
        );
    });
};
