// This file is part of MusicBrainz, the open internet music database.
// Copyright (C) 2013 MetaBrainz Foundation
// Released under the GPLv2 license: http://www.gnu.org/licenses/gpl-2.0.txt

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

            $button.text(expand ? MB.text.ShowLess : MB.text.ShowMore);
            return false;
        };

        var $button = $("<a>").attr("href", "#").addClass("annotation-toggle")
                .click(toggleAnnotation);

        toggleAnnotation();
        $annotation.after($("<p>").append($button));
    });
});
