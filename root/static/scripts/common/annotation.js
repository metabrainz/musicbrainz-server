// This file is part of MusicBrainz, the open internet music database.
// Copyright (C) 2013 MetaBrainz Foundation
// Licensed under the GPL version 2, or (at your option) any later version:
// http://www.gnu.org/licenses/gpl-2.0.txt

$(function () {
    $(".annotation-collapse").each(function () {
        var $annotation = $(this);

        if ($annotation.height() <= 100) {
            return;
        }
        var toggleAnnotation = function () {
            var expand = $annotation.hasClass("annotation-collapsed");

            $annotation.toggleClass("annotation-collapsed", !expand)
                       .toggleClass("annotation-collapse", expand);

            $button.text(expand ? MB.i18n.l("Show less...") : MB.i18n.l("Show more..."));
            return false;
        };

        var $button = $("<a>").attr("href", "#").addClass("annotation-toggle")
                .click(toggleAnnotation);

        toggleAnnotation();
        $annotation.after($("<p>").append($button));
    });
});
