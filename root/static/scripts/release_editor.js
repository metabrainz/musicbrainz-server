/* Copyright (C) 2009 Oliver Charles

   This program is free software; you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation; either version 2 of the License, or
   (at your option) any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program; if not, write to the Free Software
   Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
*/

(function ($) {
    $(function() {
        // Very simple overlays
        $("#sidebar dd:not(.date) > :input")
            .add($('li.release-label input.catalog-number'))
            .add($('#release-name'))
            .add($('#mediums input.medium-name'))
            .add($('#mediums input.track-name'))
            .add($('#mediums input.track-length'))
            .each(function() { spanOverlay($(this)) });

        // Release disambiguation comment
        var comment = $('#comment');
        spanOverlay(comment, MB.html.escape(comment.val()) || MB.text.DisambiguationComment);

        // Overlay the date property by combining all of the date fields together
        var date = $('#sidebar dl.properties dd.date');
        var dateText = date
            .find(":input[value!='']")
            .map(function() { return MB.html.escape(this.value) })
            .get().join('&ndash;') || MB.text.UnknownPlaceholder;

        var dateOverlay = new MB.Control.Overlay(MB.html.dd({}, dateText));
        dateOverlay.draw(date);
    });

    function spanOverlay(field, text) {
        text = text || (field.val() ? MB.html.escape(MB.utility.displayedValue(field))
                                    : MB.text.UnknownPlaceholder);
        var overlay = new MB.Control.Overlay(MB.html.span({}, text));
        overlay.draw(field);
    }
})(jQuery);
