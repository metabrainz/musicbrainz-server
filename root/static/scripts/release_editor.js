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

    var mediumSorter, trackSorter, mediumImporter;

    $(function() {
        // Very simple overlays
        $("#sidebar dd:not(.date) > :input")
            .add($('li.release-label input.catalog-number'))
            .add($('#release-name'))
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
        trackSorter = new MB.Control.TableSorting({
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

        trackSorter.addDragSource('table#mediums table.medium');
        trackSorter.addDropTarget('table#mediums table.medium');

        // Support moving mediums
        mediumSorter = new MB.Control.TableSorting({
            dragHandle: 'th.medium-position',
            dragComplete: function(row, oldTable) {
                reorderMediums();
            }
        });
        mediumSorter.addDropTarget('table#mediums');
        mediumSorter.addDragSource('table#mediums');

        // Editing artist credits
        acEditor($('#release-artist div.artist-credit'));

        // Editing mediums
        $('table#mediums .medium').each(function() {
            setupMedium($(this));
        });

        // Creating new mediums
        var newMedium = $(MB.html.button({}, MB.text.AddAnotherMedium))
            .insertAfter('#mediums')
            .click(function(ev) {
                ev.preventDefault();
                addNewMedium();
            });

        // Support for looking tracklistings
        mediumImporter = new MB.Control.TableSorting({
            doRemove: false,
            dragHandle: 'table.medium th.name',
            dragComplete: function(row) {
                var medium = createMedium(0);
                medium.find('tbody').replaceWith(row.find('tbody'));
                row.empty().append(medium);
                setupMedium(medium, true);
                $('#lookup-tracklist-results').empty();
                reorderMediums();
            }
        });
        mediumImporter.addDropTarget('table#mediums');

        var loading = $(MB.html.img({ src: '/static/images/loading-small.gif' })).hide();
        $('#lookup-release')
            .click(function(ev) {
                ev.preventDefault();
                loading.show();
                $.get('/ajax/lookup_tracklist', {
                    release: $('#existing-release-name').val()
                }, function(data) {
                    loading.hide();
                    $('#lookup-tracklist-results').replaceWith(data);
                    mediumImporter.addDragSource($('#lookup-tracklist-results'));
                });
            }).after(loading);
    });

    function reorderMediums() {
        // Loop over each medium
        $('table#mediums table.medium').each(function(i) {
            i++;
            var posCell = $(this).find('th.medium-position');
            posCell.find('input').val(i);
            posCell.find('span').text(i);
        });
    }

    function setupMedium(mediumTable, locked) {
        mediumSorter.rebind();

        // Support for creating new tracks
        var newRow = $(MB.html.tr());

        // Overlay the medium name
        spanOverlay(mediumTable.find('input.medium-name'));
        spanOverlay(mediumTable.find('select.medium-format'));

        if(locked) { return; }

        var createTrackRow = function(ev) {
            ev.preventDefault();

            var pos = mediumTable.find('tr.track').length;
            var prefix = mediumTable.attr('id') + '.tracklist.tracks.' + pos + '.';

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
            mediumTable.append(tr);
            setupTrackRow(tr);
            trackSorter.rebind();
        };

        $(MB.html.td({ colspan: '4' }))
            .append(
                $(MB.html.button({}, MB.text.AddNewTrack))
                    .click(createTrackRow))
            .appendTo(newRow);
        mediumTable.find('tfoot').append(newRow);

        // Setup track rows
        mediumTable.find('tr.track').each(function() {
            setupTrackRow($(this));
        });
    }

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

    function addNewMedium()
    {
        var pos = $('#mediums .medium').length;
        var medium = createMedium(pos);

        // Make sure we can drag tracks in and out of this medium
        trackSorter.addDragSource(medium);
        trackSorter.addDropTarget(medium);

        setupMedium(medium);
    }

    function createMedium(pos) {
        var medium = $('#new-medium')
            .clone()
            .show()
            .attr('id', 'edit-release.mediums.' + pos);

        $('#mediums > tbody').append(
            $(MB.html.tr()).append(
                $(MB.html.td()).append(medium)));

        // Set the position field
        var posCell = medium.find('.medium-position');
        posCell.find('span').html(pos + 1);
        posCell.find('input').val(pos);

        // Make sure we can sort it too
        mediumSorter.rebind();

        return medium;
    }
})(jQuery);
