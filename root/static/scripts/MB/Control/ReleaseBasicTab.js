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
MB.Control.ReleaseTextarea = function (disc, preview) {
    var self = MB.Object ();

    var render = function () {
        var str = "";

        $.each (disc.sorted_tracks, function (idx, item) {
            if (item.isDeleted ())
            {
                return;
            }

            str += item.position.val () + ". " + item.title.val ();

            var len = item.lengthOrNull ();
            if (len)
            {
                str += " (" + len + ")";
            }

            str += "\n";
        });

        self.textarea.val (str);
    };

    var updatePreview = function (filter) {
        if (self.trackparser)
        {
            self.trackparser.run (filter);
            self.preview.render ();
        }
    };

    var collapse = function (chained) {
        self.trackparser = null;
        self.textarea.val ('');

        self.textarea.hide ();
        self.basicdisc.removeClass ('expanded');
        self.expand_icon.find ('span.ui-icon')
            .removeClass ('ui-icon-triangle-1-s')
            .addClass ('ui-icon-triangle-1-e');

        if (!chained)
        {
            self.disc.collapse (true);
        }

        self.preview.render ();
    };

    var expand = function (chained) {
        self.textarea.show ();
        self.basicdisc.addClass ('expanded');
        self.expand_icon.find ('span.ui-icon')
            .removeClass ('ui-icon-triangle-1-e')
            .addClass ('ui-icon-triangle-1-s');

        if (!chained)
        {
            self.disc.expand (true);
        }
    };

    var loadTracklist = function (data) {
        self.render ();
        self.trackparser = MB.TrackParser (self.disc, self.textarea, data);
        self.updatePreview ();
    };

    var lines = function (data) {
        if (data)
        {
            self.textarea.val (data.join ("\n"));
        }
        else
        {
            return self.textarea.val ().split ("\n");
        }
    };

    self.disc = disc;
    self.preview = preview;
    self.render = render;
    self.updatePreview = updatePreview;
    self.lines = lines;

    self.collapse = collapse;
    self.expand = expand;
    self.loadTracklist = loadTracklist;

    self.basicdisc = $('#mediums\\.'+disc.number+'\\.basicdisc'); 
    self.textarea = self.basicdisc.find ('textarea.tracklist');
    self.expand_icon = self.basicdisc.find ('.expand a.icon');
    self.tracklist_id = self.basicdisc.find ('input.tracklist-id');

    if (!self.tracklist_id.length)
    {
        self.tracklist_id = self.disc.fieldset.find ('input.tracklist-id');
    }

    self.expand_icon.click (function (event) {
        if (self.textarea.is (':visible'))
        {
            self.collapse ();
        }
        else
        {
            self.expand ();
        }

        event.preventDefault ();
        return false;
    });

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

    var newDisc = function (disc) {
        var ta = MB.Control.ReleaseTextarea (disc, self.preview);
        self.textareas.push (ta);

        ta.expand ();

        return ta;
    };

    var guessCase = function () {
        $.each (self.textareas, function (i, textarea) {
            textarea.updatePreview (MB.GuessCase.track.guess);
            textarea.render ();
        });
    };

    self.adv = advancedtab;
    self.preview = preview;

    self.render = render;
    self.newDisc = newDisc;
    self.guessCase = guessCase;

    self.textareas = [];
    $.each (self.adv.discs, function (idx, disc) {
        self.newDisc (disc);
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
        return self.tracklist.newDisc (self.adv.addDisc ());
    };

    $("a[href=#advanced]").click (function () {
        moveFields ('basic', 'advanced');
        $('.basic-tracklist').hide ();
        $('.advanced-tracklist').show ();
        $('#id-advanced').val ('1');
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

