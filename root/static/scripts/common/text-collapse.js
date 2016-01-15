// This file is part of MusicBrainz, the open internet music database.
// Copyright (C) 2013 MetaBrainz Foundation
// Licensed under the GPL version 2, or (at your option) any later version:
// http://www.gnu.org/licenses/gpl-2.0.txt

const {l} = require('./i18n');

function makeCollapsible(className) {
    $('.' + className + '-collapse').each(function () {
        var $container = $(this);

        if ($container.height() <= 100) {
            return;
        }

        var toggleContainer = function () {
            var expand = $container.hasClass(className + "-collapsed");

            $container
                .toggleClass(className + "-collapsed", !expand)
                .toggleClass(className + "-collapse", expand);

            $button.text(expand ? l("Show less...") : l("Show more..."));
            return false;
        };

        var $button = $("<a>")
            .attr("href", "#")
            .addClass(className + "-toggle")
            .click(toggleContainer);

        toggleContainer();
        $container.after($("<p>").append($button));
    });
}

$(function () {
    _.each(['annotation', 'review', 'wikipedia-extract'], makeCollapsible);
});

MB.makeCollapsible = makeCollapsible;
