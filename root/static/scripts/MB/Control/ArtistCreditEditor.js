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

(function(MB) {
    $.extend(MB.url, {
        ArtistCreditEditor: {
            removeArtistOn: '/static/images/release_editor/remove-on.png',
            removeArtistOff: '/static/images/release_editor/remove-off.png'
        }
    });

    var currentEditor = undefined;

    MB.Control.ArtistCreditEditor = function(creditContainer, options) {
        var self = this;

        var fieldMapping = {
            join_phrase: 'joinPhrase',
            name: 'altName',
            id: 'id'
        };

        function ArtistCredit(artist) {
            this.row = $(MB.html.tr());
            this.artist = artist;
            var thisRow = this;

            $.extend(this, {
                id: $(MB.html.input({
                    'class': 'id',
                    value: artist.id,
                    type: 'hidden'
                })),
                lookup: new MB.Control.EntityLookup('artist', {
                    defaultValue: artist.name,
                    idInput: this.id,
                    selection: function(result) {
                        thisRow.artist = result;
                        if(!altNames.is(':checked')) {
                            thisRow.altName.val(result.name);
                            updateLivePreview();
                        }
                    }
                }),
                altName: $(MB.html.input({
                    value: artist.name,
                    'class': 'name'
                })),
                joinPhrase: $(MB.html.input({
                    value: artist.joinPhrase,
                    'class': 'join'
                })),
                remove: $(MB.html.input({ type: 'checkbox', 'class': 'removed' }))
            });

            this.row
                .append(
                    $(MB.html.td()).append(this.remove))
                .append(
                    $(MB.html.td())
                        .append(this.lookup.query)
                        .append(this.id))
                .append(
                    $(MB.html.td({ 'class': 'alt-name' })).append(this.altName)
                        .toggle(altNames.is(':checked'))
                )
                .append($(MB.html.td()).append(this.joinPhrase));

            var remove = new MB.Control.ToggleButton({
                    onImage: MB.url.ArtistCreditEditor.removeArtistOn,
                    offImage: MB.url.ArtistCreditEditor.removeArtistOff,
                    toggleOn: function() {
                        thisRow.row.find('input').attr('disabled', true);
                        updateLivePreview();
                    },
                    toggleOff: function() {
                        thisRow.row.find('input').attr('disabled', false);
                        updateLivePreview();
                    }
                });

            remove.draw(this.remove);
        };

        options = $.extend({
            confirmed: undefined,
            withAltNames: false
        }, options);

        // All artist credits
        var credits = [];       // Users edit this
        var savedCredits = [];  // Moved to this array when "done" is clicked

        // Contains the whole editor
        var dialog = new MB.Control.InlineDialog();
        dialog.dialog.addClass('ac-editor');

        // Artist credit editing table
        var editor = $(MB.html.table()).append(
            MB.html.thead(
                {}, MB.html.tr(
                    {}, MB.html.th() +
                        MB.html.th({}, MB.text.Artist) +
                        MB.html.th({ 'class': 'alt-name' }, MB.text.Name) +
                        MB.html.th({}, MB.text.JoinPhrase))))
            .appendTo(dialog.dialog);

        var editorBody = $(MB.html.tbody()).appendTo(editor);

        // Row to add a new artist credit
        var newLookup = new MB.Control.EntityLookup('artist', {
            selection: function(result) {
                self.appendArtist(result);
                newLookup.clear();
                updateLivePreview();
            }
        });
        var addNew = $(MB.html.div({}, 'Add another artist: '))
            .append(newLookup.query).appendTo(dialog.dialog);

        // Toggle whether to use alternative names or not
        var altNames = $(MB.html.input({
            type: 'checkbox', checked: options.withAltNames ? 'checked' : null
        })).click(function() {
            var an = editor.find('.alt-name');
            if(altNames.is(':checked')) {
                an.show();
            }
            else {
                an.hide();
                // Reset all the alt names, then hide
                $.each(credits, function() { this.altName.val(this.artist.name); });
            }
        });
        dialog.dialog.append(
            $(MB.html.div())
                .append(altNames)
                .append(MB.html.label({}, MB.text.UseAltNames)));
        editor.find('.alt-name').toggle(altNames.is(':checked'));

        // For confirming/cancelling
        var cancel = $(MB.html.button({}, MB.text.Cancel));
        var done = $(MB.html.button({}, MB.text.Done));
        var buttons = $(MB.html.div({ 'class': 'buttons' }))
            .append(cancel).append('&nbsp;').append(done).appendTo(dialog.dialog);

        done.click(function() {
            dialog.hide();
            savedCredits = [];

            $.each(credits, function(i) {
                var credit = this;
                if (credit.remove.is(':checked')) {
                    credit.row.remove();
                }

                $.each(fieldMapping, function(name, accessor) {
                    creditContainer.append(MB.html.input({
                        type: 'hidden',
                        name: creditContainer.attr('id') + '.' + i + '.' + name,
                        value: credit[accessor].val()
                    }));
                });
            });

            savedCredits = credits = $.grep(credits, function(credit) {
                return !credit.remove.is(':checked');
            });

            self.textDisplay.html(createTextRepresentation());
            currentEditor = undefined;

            if (options.confirmed) {
                options.confirmed(credits);
            }
        });
        cancel.click(function(event) {
            event.preventDefault();
            self.cancel();
        });

        $.extend(self, {
            appendArtist: function(artist) {
                var ac = new ArtistCredit(artist);
                credits.push(ac);
                editorBody.append(ac.row);
            },
            openAt: function(node) {
                if (currentEditor) {
                    currentEditor.cancel();
                }
                dialog.showAt(node);
                currentEditor = self;
            },
            cancel: function() {
                dialog.hide();
                editorBody.empty();
                creditsFromArray(savedCredits);
                updateLivePreview();
                currentEditor = undefined;
            }
        });

        // Initialize the current artist credit
        creditsFromContainer();
        savedCredits = credits;

        // Previews
        self.textDisplay = $('<span>')
            .insertBefore(creditContainer)
            .click(function() {
                self.openAt(self.textDisplay);
            }).html(createTextRepresentation());

        var livePreview = $('<span>')
            .prependTo(dialog.dialog)
            .before(MB.html.strong({}, MB.text.Preview))
            .html(createTextRepresentation());
        $('input', editorBody[0])
            .live('keyup', updateLivePreview);

        function updateLivePreview() {
            livePreview.html(createTextRepresentation());
        }

        function createTextRepresentation() {
            return $.map(credits, function(v) {
                if (v.remove.is(':checked')) {
                    return undefined;
                }
                else {
                    return v.altName.val() + v.joinPhrase.val();
                }
            }).join('');
        }

        function creditsFromContainer() {
            credits = [];
            editorBody.empty();
            creditContainer.find('div.credit').each(function() {
                var credit = $(this);
                self.appendArtist({
                    name: credit.find('input.name').val(),
                    joinPhrase: credit.find('input.join').val(),
                    id: credit.find('input.id').val()
                });
            }).hide();
        }

        function creditsFromArray(creditArray) {
            credits = [];
            $.each(creditArray, function() {
                self.appendArtist(this.artist);
            });
        }
    };
})(MB);