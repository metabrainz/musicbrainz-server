/*
   This file is part of MusicBrainz, the open internet music database.
   Copyright (C) 2011 MetaBrainz Foundation

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

MB.Control.ReleaseImportSearchResult = function (parent, $template) {
    var self = MB.Object ();

    self.parent = parent;
    self.$tracklist = $template;
    self.$table = self.$tracklist.find('table.import-tracklist');
    self.$loading = self.$tracklist.find('.tracklist-loading');
    self.$icon = self.$tracklist.find ('span.ui-icon');
    self.$id = self.$tracklist.find ('input.id');
    self.$toc = self.$tracklist.find ('input.toc');

    self.$tracklist
        .appendTo (parent.$container)
        .removeClass ('import-template')
        .addClass ('search-result');

    self.remove = function () {
        self.$tracklist.remove ();
    };

    self.toggle = function (event) {
        if (self.$table.is(':visible') || self.$loading.is(':visible'))
        {
            self.collapse (event);
        }
        else
        {
            self.expand (event);
        }
    };

    self.expand = function (event) {
        self.parent.collapseAll ();

        self.$icon.removeClass ('ui-icon-triangle-1-e').addClass ('ui-icon-triangle-1-s');
        self.$tracklist.addClass ('tracklist-padding');
        self.$loading.show ();

        $.getJSON ('/ws/js/' + self.type + '/' + self.$id.val (), function (data) {
            self.$table.find ('tr.track').eq (0).nextAll ().remove ();

            $.each (data.tracks, function (idx, item) {
                var tr = self.$table.find ('tr.track').eq(0).clone ()
                    .appendTo (self.$table.find ('tbody'));

                var artist = item.artist ? item.artist :
                    item.artist_credit ? item.artist_credit.preview : "";

                tr.find ('td.position').text (idx + 1);
                tr.find ('td.title').text (item.name);
                tr.find ('td.artist').text (artist);
                tr.find ('td.length').text (item.length);
                tr.show ();
            });

            self.$toc.val (data.toc);

            self.$loading.hide ();
            self.$table.show ();

            self.parent.selected = self;
            self.parent.updateButtons ();
        });
    };

    self.collapse = function (event) {
        self.$icon.removeClass ('ui-icon-triangle-1-s').addClass ('ui-icon-triangle-1-e');
        self.$tracklist.removeClass ('tracklist-padding');
        self.$loading.hide ();
        self.$table.hide ();

        self.parent.selected = null;
        self.parent.updateButtons ();
    };

    self.renderToDisc = function (basic_disc) {

        var data = [];
        $.each (self.$table.find ('tr.track'), function (idx, row) {

            if (idx === 0)
            {
                return; /* skip template track. */
            }

            var $row = $(row);

            var trk = {
                'position': $row.find ('td.position').text (),
                'name': $row.find ('td.title').text (),
                'length': $row.find ('td.length').text (),
                'deleted': 0
            };

            var artist = $row.find ('td.artist').text ();
            if (artist)
            {
                trk['artist_credit'] = { names: [ {
                    'artist': {
                        'name': artist,
                        'gid': '',
                        'id': ''
                    },
                    'name': artist,
                    'join_phrase': ''
                } ] };
            }

            basic_disc.disc.getTrack (idx - 1).render (trk);
        });

        basic_disc.$toc.val (self.$toc.val ());
        basic_disc.disc.sort ();
        basic_disc.render ();
        basic_disc.updatePreview ();
    };

    self.initialize = function (type, item) {

        self.type = type;

        if (item.position)
        {
            var format = item.format ? item.format : 'Disc';
            var medium = '(' + format + ' ' + item.position +
                (item.medium ? ': ' + item.medium : '') + ')';

            self.$tracklist.find ('span.medium').text (medium);
        };

        var id = item.tracklist_id ? item.tracklist_id :
            item.category ? item.category + '/' + item.discid :
            item.discid;

        self.discid = item.discid;

        self.$id.val (id);
        self.$tracklist.find ('span.title').text (item.name);
        self.$tracklist.find ('span.artist').text (item.artist);
        self.$tracklist.find ('a.icon').bind ('click.mb', self.toggle);

        self.$tracklist.show ();
    };

    return self;
};

MB.Control.ReleaseImport = function (parent, type) {
    var self = MB.Object ();

    self.$container = $('div.add-disc-tab.' + type);
    self.$next = self.$container.find ('a[href=#next]');
    self.$prev = self.$container.find ('a[href=#prev]');

    self.$pager_div = self.$container.find ('div.pager');
    self.$pager = self.$container.find ('span.pager');
    self.$searching = self.$container.find ('div.tracklist-searching');
    self.$noresults = self.$container.find ('div.tracklist-no-results');
    self.$error = self.$container.find ('div.tracklist-error');

    self.$template = parent.$dialog.find ('div.import-template');

    self.search = function (event, direction) {

        var newPage = self.page + direction;
        if (newPage < 1 || newPage > self.total)
        {
            return;
        }

        self.$error.hide ();
        self.$noresults.hide ();
        self.$searching.show ();

        self.page = newPage;
        var height = self.$container.innerHeight ();
        self.$container.css ('height', height);
        self.$container.find ('div.search-result').remove ();

        var data = {
            q: parent.$release.val (),
            artist: parent.$artist.val (),
            tracks: parent.$count.val (),
            page: self.page
        };

        $.ajax ({
            url: '/ws/js/' + type,
            dataType: 'json',
            data: data,
            success: self.results,
            error: self.error,
            timeout: 20000
        });

    };

    self.collapseAll = function () {
        $.each (self.search_results, function (idx, result) {
            result.collapse ();
        });

        self.selected = null;
    };

    self.results = function (data) {

        while (self.search_results.length)
        {
            self.search_results.pop ().remove ();
        }

        self.$searching.hide ();

        $.each (data, function (idx, item) {
            if (item.current)
            {
                var pager = MB.utility.template (MB.text.Pager);
                self.total = item.pages;

                self.$pager.text (pager.draw ({ 'page': item.current, 'total': item.pages }));
                self.$pager_div.show ();
                return;
            }

            var sr = MB.Control.ReleaseImportSearchResult (self, self.$template.clone ());

            sr.initialize (type, item);

            self.search_results.push (sr);
        });

        if (data.length < 2)
        {
            self.$pager_div.hide ();
            self.$noresults.show ();
        }

        self.$container.css ('height', 'auto');
    };

    self.error = function (jqxhr, text, error) {
        self.$searching.hide ();
        self.$error.show ().find ('span.message').text (text);
    };

    self.updateButtons = function () {
        if (self.selected)
        {
            parent.$confirm.removeClass ('disabled').addClass ('positive');
        }
        else
        {
            parent.$confirm.removeClass ('positive').addClass ('disabled');
        }
    };

    self.onChange = function (event) { self.page = 1; };

    self.page = 1;
    self.total = 1;
    self.search_results = [];
    self.selected = null;

    self.$prev.bind ('click.mb', function (event) { self.search (event, -1); });
    self.$next.bind ('click.mb', function (event) { self.search (event,  1); });

    return self;
};

MB.Control.ReleaseTrackParserBase = function (dialog) {
    var self = MB.Object ();

    self.$dialog = $('div.' + dialog);

    self.openDialog = function (event) {

        /* should render tracklist here? */
        self.$textarea.val ('');

        self.$dialog.show ().position ({
            my: "center top",
            at: "center top",
            of: $('#page'),
            offset: "0 15",
            collision: "none none"
        });

        $('#track-parser-options').insertAfter (self.$dialog.find ('h3.track-parser-options'));

        $('html').animate({ scrollTop: 0 }, 500);
    };

    self.parseTracks = function (disc) {
        disc.trackparser.run (self.$textarea.val ());
        disc.expanded = true;
    };

    self.close = function (event) {
        self.$dialog.hide ();
    };

    self.$textarea = self.$dialog.find ('textarea.tracklist');
    self.$cancel = self.$dialog.find ('input.cancel');

    self.$cancel.bind ('click.mb', self.close);

    return self;
};


MB.Control.ReleaseTrackParser = function (dialog) {
    var self = MB.Control.ReleaseTrackParserBase ('track-parser-dialog');

    self.render = function (disc) {
        var str = "";

        $.each (disc.sorted_tracks, function (idx, item) {
            if (item.isDeleted ())
            {
                return;
            }

            if (MB.TrackParser.options.trackNumbers ())
            {
                str += item.$position.val () + ". ";
            }

            str += item.$title.val ();

            if (MB.TrackParser.options.trackArtists ()
                && item.$artist.val () !== '')
            {
                str += MB.TrackParser.separator + item.$artist.val ();
            }

            /* do not render a track length if:
               - the track does not have a duration
               - the duration cannot be changed (attached discid). */
            var len = item.lengthOrNull ();
            if (len && !disc.hasToc ())
            {
                str += " (" + len + ")";
            }

            str += "\n";
        });

        self.$textarea.val (str);
    };

    parent_openDialog = self.openDialog;
    self.openDialog = function (event, disc) {
        parent_openDialog ();

        self.disc = disc;
        self.render (self.disc);
    };

    self.$dialog.find ('input.parse-tracks').bind ('click.mb', function (event) {
        self.parseTracks (self.disc);
    });
    self.$dialog.find ('input.close').bind ('click.mb', function (event) {
        self.parseTracks (self.disc);
        self.close (event);
    });

    self.disc = null;

    return self;
};


MB.Control.ReleaseAddDisc = function () {
    var self = MB.Control.ReleaseTrackParserBase ('add-disc-dialog');

    self.$release = self.$dialog.find ('input.release');
    self.$artist = self.$dialog.find ('input.artist');
    self.$count = self.$dialog.find ('input.track-count');

    self.selectTab = function (event) {
        var tab = $(this).attr ('class');
        $('.add-disc-dialog ul.tabs li').removeClass ('sel');
        $(this).closest ('li').addClass ('sel');
        $('div.add-disc-tab').hide ();

        $('div.add-disc-tab.' + tab)
            .show ()
            .find ('div.pager').before ($('table.import-search-fields'));

        if (tab === 'manual')
        {
            self.$dialog.find ('input.add-disc')
                .addClass ('positive').removeClass ('disabled');
        }
        else if (tab === 'tracklist')
        {
            self.use_tracklist.updateButtons ();
        }
        else if (tab === 'freedb')
        {
            self.freedb_import.updateButtons ();
        }
        else if (tab === 'cdstub')
        {
            self.cdstub_import.updateButtons ();
        }
    };

    self.confirm = function (event) {
        var tab = self.$dialog.find ('ul.tabs li.sel a').attr ('class');

        self['confirm_' + tab] (event);
    };

    self.confirm_manual = function (event) {
        /* add the disc. */
        disc = MB.Control.release_tracklist.emptyDisc ();

        /* start with atleast one track (that track may already be there,
         * added in a previous attempt). */
        if (disc.tracks.length < 1)
        {
            disc.addTrack ();
        }

        self.parseTracks (disc);

        self.close (event);
    };

    self.confirm_tracklist = function (event) {
        if (!self.use_tracklist.selected)
            return;

        var disc = MB.Control.release_tracklist.emptyDisc ();
        disc.$tracklist_id.val (self.use_tracklist.selected.$id.val ());
        disc.collapse ();
        disc.expand ();

        self.close (event);
    };

    self.confirm_freedb = function (event) {
        if (!self.freedb_import.selected)
            return;

        self.freedb_import.selected.renderToDisc (
            MB.Control.release_tracklist.emptyDisc ());
        self.close (event);
    };

    self.confirm_cdstub = function (event) {
        if (!self.cdstub_import.selected)
            return;

        self.cdstub_import.selected.renderToDisc (
            MB.Control.release_tracklist.emptyDisc ());
        self.close (event);
    };

    self.onChange = function (event) {
        self.use_tracklist.onChange ();
        self.freedb_import.onChange ();
        self.cdstub_import.onChange ();
    };

    self.$dialog.appendTo ($('body'));
    self.$dialog.find ('ul.tabs a').bind ('click.mb', self.selectTab);

    self.$confirm = self.$dialog.find ('input.add-disc');

    self.$confirm.bind ('click.mb', self.confirm);

    self.$release.bind ('change.mb', self.onChange);
    self.$artist.bind ('change.mb', self.onChange);
    self.$count.bind ('change.mb', self.onChange);

    $("a[href=#add_disc]").bind ('click.mb', self.openDialog);

    $('a[href=#import-search]').click (function (event) {

        if ($('div.add-disc-tab:visible').hasClass ('tracklist'))
        {
            self.use_tracklist.search (event, 0);
        }
        else if ($('div.add-disc-tab:visible').hasClass ('freedb'))
        {
            self.freedb_import.search (event, 0);
        }
        else if ($('div.add-disc-tab:visible').hasClass ('cdstub'))
        {
            self.cdstub_import.search (event, 0);
        }
    });

    self.use_tracklist = MB.Control.ReleaseImport (self, 'tracklist');
    self.freedb_import = MB.Control.ReleaseImport (self, 'freedb');
    self.cdstub_import = MB.Control.ReleaseImport (self, 'cdstub');

    return self;
};

$('document').ready (function () {
    MB.Control.release_track_parser = MB.Control.ReleaseTrackParser ();
    MB.Control.release_add_disc = MB.Control.ReleaseAddDisc ();
});
