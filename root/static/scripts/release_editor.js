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
            dragHandle: 'tr.subh th.position',
            dragComplete: function(row, oldTable) {
                // Loop over each medium
                $('table#mediums table.medium').each(function(i) {
                    i++;
                    var posCell = $(this).find('th.position');
                    posCell.find('input').val(i);
                    posCell.find('span').text(i);
                });
            }
        });
        mediumSorter.addTables('table#mediums');
        mediumSorter.activate();

        // Editing artist credits
        acEditor($('#release-artist div.artist-credit'));

        // Setup track rows
        $('table#mediums tbody tr.track').each(function() {
            setupTrackRow($(this));
        });

        // Support for creating new tracks
        $('table#mediums .medium tbody').each(function(mediumNumber) {
            var table = $(this);
            var newRow = $(MB.html.tr());

            var createTrackRow = function(ev) {
                ev.preventDefault();
                
                var pos = table.find('tr.track').length;
                var prefix = 'edit-release.mediums.' + mediumNumber
                    + '.tracklist.tracks.' + pos + '.';
                
                pos++; // We display tracks with '1' as the starting index

                var artistCredit = $('#release-artist .artist-credit').clone();
                artistCredit.attr('id', prefix + 'artist_credit');
                artistCredit.find('input').each(function() {
                    var inp = $(this);
                    inp.attr('name', inp.attr('name').replace('edit-release.', prefix));
                });
                
                var tr = $(MB.html.tr({ 'class': 'track' + (pos % 2 == 0 ? ' ev' : '') },
                    MB.html.td({ 'class': 'position' },
                        MB.html.input({
                            'class': 'pos',
                            value: pos,
                            name: prefix + 'position'
                        })) +
                    MB.html.td({},
                        MB.html.input({
                            'class': 'track-name',
                            name: prefix + 'name'
                        })) +
                    MB.html.td({},
                        MB.html.div({
                            'class': 'artist-credit',
                            id: prefix + 'artist_credit'
                        }, artistCredit.html())) +
                    MB.html.td({},
                        MB.html.input({
                            'class': 'track-length',
                            value: '?:??',
                            name: prefix + 'length'
                        }))
                ));
                table.append(tr);
                setupTrackRow(tr);
                trackSorter.activate();
            };
            
            $(MB.html.td({ colspan: '4' }))
                .append(
                    $(MB.html.button({}, MB.text.AddNewTrack))
                        .click(createTrackRow))
                .appendTo(newRow);
            table.closest('table').find('tfoot').append(newRow);
        });

        // Overlay Medium Format
        $('select.medium-format').each(function() {
            spanOverlay($(this));
            console.log(MB.utility.displayedValue($(this)));
        });
    });

    function setupTrackRow(row) {
        // Deleting tracks
        var checkbox = $('input.remove', this);
        var removeButton = new MB.Control.ToggleButton(MB.url.ReleaseEditor.removeImages);
        removeButton.draw(checkbox);

        // Overlays
        row.find('input.track-name, input.track-length')
           .each(function() { spanOverlay($(this)); });

        // Artist credit editor
        acEditor(row.find('div.artist-credit'));

        // Moving tracks
        var pos = row.find('input.pos');
        pos.after(MB.html.span({ 'class': 'position' }, pos.val())).hide();
    }

    function acEditor(container) {
        var acEditor = new MB.Control.ArtistCreditEditor(container);
        acEditor.textDisplay.addClass('overlay');
        return acEditor
    }

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
