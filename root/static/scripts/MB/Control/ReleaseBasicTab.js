/*
   This file is part of MusicBrainz, the open internet music database.
   Copyright (C) 2010 MetaBrainz Foundation

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

MB.Control._preview_update_timeout = 500;

/**
 * MB.Control.ReleasePreview is used to render the preview.
 */
MB.Control.ReleasePreview = function (advancedtab) {
    var self = MB.Object ();

    var render = function () {
        var preview = $('#preview').html ('');

        $.each (self.adv.discs, function (idx, disc) {

            $('<h3>').text (disc.fullTitle ()).appendTo (preview);

            var table = $('<table class="preview">').appendTo(preview);

            $.each (disc.sorted_tracks, function (idx, item) {
                if (item.isDeleted ())
                {
                    return;
                }

                $('<tr>').appendTo (table).
                    append ($('<td class="trackno">').text (item.position.val ())).
                    append ($('<td class="title">').text (item.title.val ())).
                    append ($('<td class="duration">').text (item.length.val ()));
            });

        });
    };

    self.preview = $('#preview');
    self.adv = advancedtab;

    self.render = render;

    return self;
};


/**
 * MB.Control.ReleaseTextarea is used to render and parse a tracklist textarea.
 */
MB.Control.ReleaseTextarea = function (disc, preview, serialized) {
    var self = MB.Object ();

    var render = function () {
        var str = "";

        $.each (disc.sorted_tracks, function (idx, item) {
            if (item.isDeleted ())
            {
                return;
            }
            
            str += item.position.val () + ". " + item.title.val ();
            str += " (" + item.length.val () + ")";
            str += "\n";
        });

        self.textarea.val (str);
    };

    var updatePreview = function () {
        self.trackparser.run ();
        self.preview.render ();
    };

    self.disc = disc;
    self.preview = preview;
    self.render = render;
    self.updatePreview = updatePreview;
    self.textarea = $('#mediums\\.'+disc.number+'\\.tracklist');
    self.trackparser = MB.TrackParser (self.disc, serialized);

    self.textarea.bind ('keyup', function () {
        if (typeof self.timeout == "number")
        {
            clearTimeout (self.timeout);
        }

        self.timeout = setTimeout (function () {
            delete self.timeout;
            self.updatePreview ();
        }, MB.Control._preview_update_timeout);
    });

    return self;
}

/**
 * MB.Control.ReleaseTracklist is used to render and parse the tracklist textareas.
 */
MB.Control.ReleaseTracklist = function (advancedtab, preview, serialized) {
    var self = MB.Object ();

    var render = function () {
        $.each (self.textareas, function (idx, textarea) {
            textarea.render ();
        });
    };

    var newDisc = function (disc) {
        self.textareas.push (MB.Control.ReleaseTextarea (disc, self.preview));
    };

    self.adv = advancedtab;
    self.preview = preview;

    self.render = render;
    self.newDisc = newDisc;

    self.textareas = [];
    $.each (self.adv.discs, function (idx, disc) {
        self.textareas.push (MB.Control.ReleaseTextarea (disc, self.preview, serialized[idx]));
    });

    return self;
};


MB.Control.ReleaseBasicTab = function (advancedtab, serialized) {
    var self = MB.Object ();

    /* switch between basic / advanced view. */
    var moveMediumFields = function (from, to) {
        var discs = self.adv.discs.length;

        for (var i = 0; i < discs; i++)
        {
            $('.'+from+'-medium-format-and-title').eq(i).contents ().detach ().appendTo (
                $('.'+to+'-medium-format-and-title').eq(i));
        }
    };

    $("a[href=#advanced]").click (function () {
        moveMediumFields ('basic', 'advanced');
        $('.basic-tracklist').hide ();
        $('.advanced-tracklist').show ();
    });

    $("a[href=#basic]").click (function () {
        moveMediumFields ('advanced', 'basic');
        $('.advanced-tracklist').hide ();
        $('.basic-tracklist').show ();
        self.tracklist.render ();
        self.preview.render ();
    });

    $("a[href=#add_disc]").click (function () {
        self.tracklist.newDisc (self.adv.addDisc ());
    });

    self.adv = advancedtab;
    self.preview = MB.Control.ReleasePreview (self.adv);
    self.tracklist = MB.Control.ReleaseTracklist (self.adv, self.preview, serialized);

    self.preview.render ();
    self.tracklist.render ();

    return self;
}