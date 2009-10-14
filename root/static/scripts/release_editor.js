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
    $.extend(MB.url, {
        ReleaseEditor: {
            removeImages: {
                onImage: '/static/images/release_editor/remove-on.png',
                offImage: '/static/images/release_editor/remove-off.png'
            }
        }
    });

    $(function() {
        // Very simple overlays
        $("#sidebar dd:not(.date) > :input")
            .add($('li.release-label input.catalog-number'))
            .add($('#release-name'))
            .add($('#mediums input.medium-name'))
            .add($('#mediums input.track-name'))
            .add($('#mediums input.track-length'))
            .each(function() { spanOverlay($(this)); });

        // Release disambiguation comment
        var comment = $('#comment');
        spanOverlay(comment, MB.html.escape(comment.val()) || MB.text.DisambiguationComment);

        // Overlay the date property by combining all of the date fields together
        var date = $('#sidebar dl.properties dd.date');
        var dateText = date
            .find(":input[value!='']")
            .map(function() { return MB.html.escape(this.value); })
            .get().join('&ndash;') || MB.text.UnknownPlaceholder;

        var dateOverlay = new MB.Control.Overlay(MB.html.dd({}, dateText));
        dateOverlay.draw(date);

        // Deleting release labels & mediums
        $('#sidebar li.release-label input.remove')
            .add('#mediums tr.medium input.remove')
            .each(function() {
                var remove = new MB.Control.ToggleButton(MB.url.ReleaseEditor.removeImages);
                remove.draw($(this));
            });

        // Deleting tracks labels
        $('#mediums tr.track').each(function() {
            var row = this;
            var checkbox = $('input.remove', this);
            var removeButton = new MB.Control.ToggleButton(MB.url.ReleaseEditor.removeImages);
            removeButton.draw(checkbox);
        });

        // Label lookups
        $('#sidebar ul.release-labels span.label').each(overlayLabelLookup);

        // Support moving tracks
        var trackSorter = new MB.Control.TableSorting({
            dragComplete: function(row, oldTable) {
                // Loop over each changed medium...
                var mediums = row.parent('table');
                mediums.add(oldTable);
                $('table#mediums tbody').each(function() {
                    // Loop over each track
                    $(this).find('tr').each(function(i) {
                        i += 1; // Tracks are indexed from 1, not 0
                        var trackRow = $(this);
                        trackRow.toggleClass('ev', i % 2 == 0);
                        var posCell = trackRow.find('td.position');
                        posCell.find('span').text(i);
                        posCell.find('input:first').val(i);
                    });
                });
            },
            dragHandle: 'td.position'
        });

        trackSorter.addTables('table#mediums table.medium');
        trackSorter.activate();

        // Support moving mediums
        var mediumSorter = new MB.Control.TableSorting({
            dragHandle: 'tr.subh th.position'
        });
        mediumSorter.addTables('table#mediums');
        mediumSorter.activate();
    });

    function overlayLabelLookup() {
        var labelText = $(this);
        var idField = labelText.parent().find('input.label-id');
        var lookup = new MB.Control.EntityLookup('label' ,{
            defaultValue: labelText.text(),
            idInput: idField,
            selection: function(result) {
                labelText.text(result.name).show();
                lookup.query.hide();
            }
        });
        idField.after(lookup.query);

        var lookupOverlay = new MB.Control.Overlay(labelText);
        lookupOverlay.draw(lookup.query);
    }

    function spanOverlay(field, text) {
        text = text || (field.val() ? MB.html.escape(MB.utility.displayedValue(field))
                                    : MB.text.UnknownPlaceholder);
        var overlay = new MB.Control.Overlay(MB.html.span({}, text));
        overlay.draw(field);
    }
})(jQuery);
