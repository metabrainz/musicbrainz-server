// This file is part of MusicBrainz, the open internet music database.
// Copyright (C) 2014 MetaBrainz Foundation
// Licensed under the GPL version 2, or (at your option) any later version:
// http://www.gnu.org/licenses/gpl-2.0.txt

$(function () {
    $(".cover-art-image").each(function () {
        var $e = $(this);

        $("<img />").bind('error', function (event) {
            if ($e.data("fallback") && $e.attr("src") === $e.data("thumbnail")) {
                $e.attr("src", $e.data("fallback"));
            } else {
                $e.closest('a').replaceWith('<em>' + $e.data("message") + '</em>');
            }
        }).attr({
            "src": $e.data("thumbnail"),
            "title": $e.data("title")
        }).appendTo(this);

    });
});
