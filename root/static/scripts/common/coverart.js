// This file is part of MusicBrainz, the open internet music database.
// Copyright (C) 2014 MetaBrainz Foundation
// Licensed under the GPL version 2, or (at your option) any later version:
// http://www.gnu.org/licenses/gpl-2.0.txt

import $ from 'jquery';

$(function () {
    $(".cover-art-image").each(function () {
        var $e = $(this);
        var thumbnail_url = window.devicePixelRatio > 1
            ? $e.data("large-thumbnail")
            : $e.data("small-thumbnail");

        $("<img />").bind('error', function (event) {
            if ($e.data("fallback") && $e.attr("src") === thumbnail_url) {
                $e.attr("src", $e.data("fallback"));
            } else {
                $e.closest('a')
                    .replaceWith('<em>' + $e.data("message") + '</em>');
            }
        }).attr({
            src: thumbnail_url,
            title: $e.data("title"),
        }).appendTo(this);
    });
});
