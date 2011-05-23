/*
   This file is part of MusicBrainz, the open internet music database.
   Copyright (C) 2010-2011 MetaBrainz Foundation

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

    self.warnings_active = [];
    self.do_not_add_tracks = MB.utility.template (MB.text.DoNotAddTracks);
    self.do_not_remove_tracks = MB.utility.template (MB.text.DoNotRemoveTracks);

    self.warning = function (template, disc) {
        self.warnings_active.push (template.draw ({ "disc": disc.fullTitle () }));
    };

    self.updateWarnings = function () {
        if (self.warnings_active.length)
        {
            $('#discid-warning').show ().find ('div.warning p').html (
                self.warnings_active.join ("<br />"));
        }
        else
        {
            $('#discid-warning').hide ().find ('div.warning p').html ("");
        }

        self.warnings_active = [];
    };

    self.render = function () {
        var preview = $('#preview').html ('');

        $.each (self.adv.positions, function (idx, disc) {

            if (!disc) { return; }

            $('<h3>').text (disc.fullTitle ()).appendTo (preview);

            var table = $('<table class="preview">').appendTo(preview);

            var count = 0;
            $.each (disc.sorted_tracks, function (idx, item) {
                if (item.isDeleted ())
                {
                    return;
                }

                count++;
                var tr = $('<tr>').appendTo (table);
                tr.append ($('<td class="trackno">').text (item.$position.val ()));
                tr.append ($('<td class="title">').text (item.$title.val ()));
                if (disc.isVariousArtists ())
                {
                    tr.append ($('<td class="artist">').text (item.$artist.val ()));
                }
                tr.append ($('<td class="duration">').text (item.$length.val ()));
            });

            if (disc.track_count && (count > disc.track_count))
            {
                self.warning (self.do_not_add_tracks, disc);
            }
            else if (disc.track_count && (count < disc.track_count))
            {
                self.warning (self.do_not_remove_tracks, disc);
            }

        });

        self.updateWarnings ();

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

            /* do not render a track length if:
               - the track does not have a duration
               - the duration cannot be changed (attached discid). */
            var len = item.lengthOrNull ();
            if (len && !self.hasToc ())
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
        /* FIXME: remove from parent textareas. */
        self.$textarea.val ('');
        self.$textarea.addClass ('deleted');
        self.$basicdisc.addClass ('deleted');

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

        if (self.isVariousArtists ())
        {
            self.disc.$artist_column_checkbox.attr ('checked', 'checked');
            self.disc.updateArtistColumn ();
        }
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

    self.hasToc = function () {
        return MB.medium_cdtocs[disc.number] || self.$toc.val () !== '';
    };

    self.disc = disc;
    self.preview = preview;

    self.$basicdisc = $('#mediums\\.'+disc.number+'\\.basicdisc');
    self.$textarea = self.$basicdisc.find ('textarea.tracklist');
    self.$nowloading = self.$basicdisc.find ('div.tracklist-loading');
    self.$expand_icon = self.$basicdisc.find ('input.expand-disc');
    self.$collapse_icon = self.$basicdisc.find ('input.collapse-disc');
    self.$delete_icon = self.$basicdisc.find ('input.remove-disc');
    self.$toc = self.$basicdisc.find ('input.toc');
    self.$tracklist_id = self.$basicdisc.find ('input.tracklist-id');
    self.$toc = self.$basicdisc.find ('input.toc');
    self.$various_artists = self.$basicdisc.find ('input.various-artists');

    if (!self.$tracklist_id.length)
    {
        self.$tracklist_id = self.disc.$fieldset.find ('input.tracklist-id');
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

    if (self.disc.isDeleted ())
    {
        self.$textarea.addClass ('deleted');
        self.$basicdisc.addClass ('deleted');
    }
    else
    {
        self.$textarea.removeClass ('deleted');
        self.$basicdisc.removeClass ('deleted');
    }

    return self;
}

/**
 * MB.Control.ReleaseTracklist is used to render and parse the tracklist textareas.
 */
MB.Control.ReleaseTracklist = function (advancedtab, preview) {
    var self = MB.Object ();

    self.render = function () {
        $.each (self.textareas, function (idx, textarea) {
            textarea.render ();
        });
    };

    self.newDisc = function (disc, expand_discs) {
        var ta = MB.Control.ReleaseTextarea (disc, self.preview);
        self.textareas.push (ta);

        if (expand_discs)
        {
            ta.expand ();
        }

        return ta;
    };

    self.guessCase = function () {
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

    self.addDisc = function () {
        return self.tracklist.newDisc (self.adv.addDisc (), true);
    };

    $("a[href=#advanced]").click (function () {
        moveFields ('basic', 'advanced');
        $('.basic-tracklist').hide ();
        $('.advanced-tracklist').show ();
        $(window).scrollTop (0);
        $.cookie ('tracklist_mode', 'advanced', { path: '/', expires: 365 });
    });

    $("a[href=#basic]").click (function () {
        moveFields ('advanced', 'basic');
        $('.advanced-tracklist').hide ();
        $('.basic-tracklist').show ();
        self.tracklist.render ();
        self.preview.render ();
        $.cookie ('tracklist_mode', 'basic', { path: '/', expires: 365 });
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

    self.adv = advancedtab;
    self.preview = MB.Control.ReleasePreview (self.adv);
    self.tracklist = MB.Control.ReleaseTracklist (self.adv, self.preview);

    self.preview.render ();
    self.tracklist.render ();

    if ($.cookie ('tracklist_mode') === "advanced")
    {
        $("a[href=#advanced]").trigger ('click');
    }

    self.adv.basic = self;

    return self;
}

