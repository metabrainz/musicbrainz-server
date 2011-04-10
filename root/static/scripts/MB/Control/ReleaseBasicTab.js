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

    self.render = function () {
        var preview = $('#preview').html ('');

        $.each (self.adv.discs, function (idx, disc) {

            $('<h3>').text (disc.fullTitle ()).appendTo (preview);

            var table = $('<table class="preview">').appendTo(preview);

            $.each (disc.sorted_tracks, function (idx, item) {
                if (item.isDeleted ())
                {
                    return;
                }

                var tr = $('<tr>').appendTo (table);
                tr.append ($('<td class="trackno">').text (item.$position.val ()));
                tr.append ($('<td class="title">').text (item.$title.val ()));
                if (disc.isVariousArtists ())
                {
                    tr.append ($('<td class="artist">').text (item.$artist.val ()));
                }
                tr.append ($('<td class="duration">').text (item.$length.val ()));
            });

        });
    };

    self.preview = $('#preview');
    self.adv = advancedtab;

    return self;
};


/**
 * MB.Control.ReleaseTextarea is used to render and parse a tracklist textarea.
 */
MB.Control.ReleaseTextarea = function (disc, preview) {
    var self = MB.Object ();

    self.render = function () {
        var str = "";

        $.each (disc.sorted_tracks, function (idx, item) {
            if (item.isDeleted ())
            {
                return;
            }

            str += item.$position.val () + ". " + item.$title.val ();

            if (self.isVariousArtists () && item.$artist.val () !== '')
            {
                str += MB.TrackParser.separator + item.$artist.val ();
            }

            var len = item.lengthOrNull ();
            if (len)
            {
                str += " (" + len + ")";
            }

            str += "\n";
        });

        self.$textarea.val (str);
    };

    self.updatePreview = function () {
        if (typeof self.timeout == "number")
        {
            clearTimeout (self.timeout);
        }

        delete self.timeout;

        if (self.trackparser)
        {
            self.trackparser.run ();
            self.preview.render ();
        }
    };

    self.collapse = function (chained) {
        self.trackparser = null;
        self.$textarea.val ('');

        self.$textarea.hide ();
        self.$basicdisc.removeClass ('expanded');
        self.$collapse_icon.hide ();
        self.$expand_icon.show ();

        if (!chained)
        {
            self.disc.collapse (true);
        }

        self.preview.render ();
    };

    self.expand = function (chained) {

        self.$nowloading.show ();
        self.$basicdisc.addClass ('expanded');
        self.$expand_icon.hide ();
        self.$collapse_icon.show ();

        if (!chained)
        {
            self.disc.expand (true);
        }
    };

    self.removeDisc = function (chained) {
        if (!chained && self.disc.isLastDisc ())
            return;

        /* FIXME: remove from parent textareas. */
        self.$textarea.val ('');
        self.$textarea.hide ();
        self.$basicdisc.hide ();

        if (!chained)
        {
            self.disc.removeDisc (true);
        }

        /* render preview after the advanced tab has also removed all tracks. */
        self.preview.render ();
    };

    self.loadTracklist = function (data) {
        self.$textarea.show ();
        self.$nowloading.hide ();
        self.render ();
        self.trackparser = MB.TrackParser.Parser (self.disc, self.$textarea, data);
        self.updatePreview ();
    };

    self.lines = function (data) {
        if (data)
        {
            self.$textarea.val (data.join ("\n"));
        }
        else
        {
            return self.$textarea.val ().split ("\n");
        }
    };

    /**
     * isVariousArtists returns false only if all tracks on the disc are identical
     * to the release artist.
     */
    self.isVariousArtists = function () {
        return self.$various_artists.val() == '1';
    };

    self.disc = disc;
    self.preview = preview;

    self.$basicdisc = $('#mediums\\.'+disc.number+'\\.basicdisc');
    self.$textarea = self.$basicdisc.find ('textarea.tracklist');
    self.$nowloading = self.$basicdisc.find ('div.tracklist-loading');
    self.$expand_icon = self.$basicdisc.find ('input.expand-disc');
    self.$collapse_icon = self.$basicdisc.find ('input.collapse-disc');
    self.$delete_icon = self.$basicdisc.find ('input.remove-disc');
    self.$tracklist_id = self.$basicdisc.find ('input.tracklist-id');
    self.$various_artists = self.$basicdisc.find ('input.various-artists');

    if (!self.$tracklist_id.length)
    {
        self.$tracklist_id = self.disc.fieldset.find ('input.tracklist-id');
    }

    self.$expand_icon.bind ('click.mb', function (ev) { self.expand (); });
    self.$collapse_icon.bind ('click.mb', function (ev) { self.collapse (); });
    self.$delete_icon.bind ('click.mb', function (ev) { self.removeDisc (); });

    self.$textarea.bind ('keyup.mb', function () {
        var newTimeout = setTimeout (function () {
            self.updatePreview ();
        }, MB.Control._preview_update_timeout);

        self.timeout = newTimeout;
    });

    self.$textarea.bind ('blur.mb', function () {
        self.updatePreview ();
    });

    self.disc.registerBasic (self);

    return self;
}

/**
 * MB.Control.ReleaseTracklist is used to render and parse the tracklist textareas.
 */
MB.Control.ReleaseTracklist = function (advancedtab, preview) {
    var self = MB.Object ();

    var render = function () {
        $.each (self.textareas, function (idx, textarea) {
            textarea.render ();
        });
    };

    var newDisc = function (disc, expand_discs) {
        var ta = MB.Control.ReleaseTextarea (disc, self.preview);
        self.textareas.push (ta);

        if (expand_discs)
        {
            ta.expand ();
        }

        return ta;
    };

    var guessCase = function () {
        /* make sure all the input fields on the advanced tab are up-to-date. */
        $.each (self.textareas, function (i, textarea) {
            textarea.updatePreview ();
        });

        /* have the advanced view guess case all the discs. */
        self.adv.guessCase ();

        /* take the new inputs and render them to our textareas and the preview. */
        self.render ();
        self.preview.render ();
    };

    self.adv = advancedtab;
    self.preview = preview;

    self.render = render;
    self.newDisc = newDisc;
    self.guessCase = guessCase;

    self.textareas = [];
    $.each (self.adv.discs, function (idx, disc) {
        self.newDisc (disc, self.adv.discs.length < 4);
    });

    return self;
};


MB.Control.ReleaseBasicTab = function (advancedtab, serialized) {
    var self = MB.Object ();

    /* switch between basic / advanced view. */
    var moveFields = function (from, to) {
        var discs = self.adv.discs.length;

        for (var i = 0; i < discs; i++)
        {
            $('.'+from+'-medium-format-and-title').eq(i).contents ().detach ().appendTo (
                $('.'+to+'-medium-format-and-title').eq(i));
        }

        $('div.guesscase-'+from).children().appendTo($('div.guesscase-'+to));
    };

    var addDisc = function () {
        return self.tracklist.newDisc (self.adv.addDisc (), true);
    };

    $("a[href=#advanced]").click (function () {
        moveFields ('basic', 'advanced');
        $('.basic-tracklist').hide ();
        $('.advanced-tracklist').show ();
        $('#id-advanced').val ('1');
        $(window).scrollTop (0);
    });

    $("a[href=#basic]").click (function () {
        moveFields ('advanced', 'basic');
        $('.advanced-tracklist').hide ();
        $('.basic-tracklist').show ();
        $('#id-advanced').val ('0');
        self.tracklist.render ();
        self.preview.render ();
    });

    $("a[href=#add_disc]").click (function () {
        self.addDisc ();
    });

    $("a[href=#guesscase]").click (function () {
        if ($('.advanced-tracklist:visible').length)
        {
            self.adv.guessCase ();
        }
        else
        {
            self.tracklist.guessCase ();
        }
    });

    self.addDisc = addDisc;
    self.adv = advancedtab;
    self.preview = MB.Control.ReleasePreview (self.adv);
    self.tracklist = MB.Control.ReleaseTracklist (self.adv, self.preview);

    self.preview.render ();
    self.tracklist.render ();

    if ($('#id-advanced').val () == '1')
    {
        $("a[href=#advanced]").trigger ('click');
    }

    self.adv.basic = self;

    return self;
}

