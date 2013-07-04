/*
   This file is part of MusicBrainz, the open internet music database.
   Copyright (C) 2010, 2013 MetaBrainz Foundation

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

MB.Control.ArtistEdit = function () {
    var self = MB.Object ();

    self.$name   = $('#id-edit-artist\\.name');
    self.$begin  = $('#label-id-edit-artist\\.period\\.begin_date');
    self.$ended  = $('#label-id-edit-artist\\.period\\.ended');
    self.$end    = $('#label-id-edit-artist\\.period\\.end_date');
    self.$beginarea    = $('#edit-artist\\.begin_area\\.label');
    self.$endarea    = $('#edit-artist\\.end_area\\.label');
    self.$type   = $('#id-edit-artist\\.type_id');
    self.$gender = $('#id-edit-artist\\.gender_id');
    self.old_gender = self.$gender.val();

    self.changeDateText = function (text) {
        self.$begin.text(text[0]);
        self.$end.text(text[1]);
        self.$ended.text(text[2]);
    };

    self.changeAreaText = function (text) {
        self.$beginarea.text(text[0]);
        self.$endarea.text(text[1]);
    };

    /* Sets the label descriptions depending upon the artist type:

           Unknown: 0
           Person: 1
           Group: 2
    */
    self.typeChanged = function() {
        switch (self.$type.val()) {
            default:
            case '0':
                self.changeDateText(MB.text.ArtistDate.Unknown);
                self.changeAreaText(MB.text.ArtistArea.Unknown);
                self.enableGender();
                break;

            case '1':
                self.changeDateText(MB.text.ArtistDate.Person);
                self.changeAreaText(MB.text.ArtistArea.Person);
                self.enableGender();
                break;

            case '2':
                self.changeDateText(MB.text.ArtistDate.Founded);
                self.changeAreaText(MB.text.ArtistArea.Founded);
                self.disableGender();
                break;
        }
    };

    self.enableGender = function() {
        if (self.$gender.prop('disabled')) {
            self.$gender
               .prop("disabled", false)
               .val(self.old_gender);
        }
    };

    self.disableGender = function() {
        self.$gender.prop("disabled", true);
        self.old_gender = self.$gender.val();
        self.$gender.val('');
    };

    self.typeChanged();
    self.$type.bind ('change.mb', self.typeChanged);

    self.initializeArtistCreditPreviews = function(gid) {
        var artist_re = new RegExp("/artist/" + gid + "$");
        $('span.rename-artist-credit').each(function() {
            var $ac = $(this);
            $ac.find('input').change(function() {
                var checked = this.checked;
                var new_name = self.$name.val();
                $ac.find('span.ac-preview')[checked ? 'show' : 'hide']();
                $ac.find('span.ac-preview a').each(function() {
                    var $link = $(this);
                    if ($link.data('old_name')) {
                        $link.text(checked ? new_name : $link.data('old_name'));
                    }
                });
            });
            $ac.find('input').each(function () {
                $ac.find('span.ac-preview')[this.checked ? 'show' : 'hide']();
            });
            $ac.find('span.ac-preview a').each(function() {
                var $link = $(this);
                if (artist_re.test($link.attr('href'))) {
                    $link.data('old_name', $link.text());
                }
            });
        });
        self.$name.change(function() {
            var new_name = self.$name.val();
            $('span.rename-artist-credit').each(function() {
                var $ac = $(this);
                if ($ac.find('input:checked').length) {
                    $ac.find('span.ac-preview a').each(function() {
                        var $link = $(this);
                        if ($link.data('old_name')) {
                            $link.text(new_name);
                        }
                    });
                }
            });
        });
    }

    var bubbles = MB.Control.BubbleCollection ();
    MB.Control.initialize_guess_case (bubbles, 'artist', 'id-edit-artist');

    MB.Control.Area('#area', bubbles);
    MB.Control.Area('#begin_area', bubbles);
    MB.Control.Area('#end_area', bubbles);

    return self;
};
