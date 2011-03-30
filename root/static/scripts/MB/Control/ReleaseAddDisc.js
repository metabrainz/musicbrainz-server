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

            $.each (data, function (idx, item) {
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

            self.$loading.hide ();
            self.$table.show ();

            self.parent.selected = self;
        });
    };

    self.collapse = function (event) {
        self.$icon.removeClass ('ui-icon-triangle-1-s').addClass ('ui-icon-triangle-1-e');
        self.$tracklist.removeClass ('tracklist-padding');
        self.$loading.hide ();
        self.$table.hide ();
    };

    self.renderToDisc = function (basic_disc) {
        //  FIXME: currently not handled correctly by the server.
        if (self.type === 'cdstub')
        {
            basic_disc.$toc.val (self.discid);
        }

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
                trk['artist_credit'] = { names: [ { 'artist_name': artist } ] };
            }

            basic_disc.disc.getTrack (idx - 1).render (trk);

        });

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
    self.$search = self.$container.find ('a[href=#search]');
    self.$next = self.$container.find ('a[href=#next]');
    self.$prev = self.$container.find ('a[href=#prev]');

    self.$release = self.$container.find ('input.release');
    self.$artist = self.$container.find ('input.artist');
    self.$count = self.$container.find ('input.track-count');

    self.$pager_div = self.$container.find ('div.pager');
    self.$pager = self.$container.find ('span.pager');

    self.$template = parent.$add_disc_dialog.find ('div.import-template');

    self.search = function (event, direction) {

        var newPage = self.page + direction;
        if (newPage < 1 || newPage > self.total)
        {
            return;
        }

        self.page = newPage;
        var height = self.$container.innerHeight ();
        self.$container.css ('height', height);
        self.$container.find ('div.search-result').remove ();

        var data = {
            q: self.$release.val (),
            artist: self.$artist.val (),
            tracks: self.$count.val (),
            page: self.page
        };
        $.getJSON ('/ws/js/' + type, data, self.results);
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

        self.$container.css ('height', 'auto');
    };

    self.onChange = function (event) { self.page = 1; };

    self.page = 1;
    self.total = 1;
    self.search_results = [];
    self.selected = null;

    self.$search.bind ('click.mb', function (event) { self.search (event, 0); });
    self.$prev.bind ('click.mb', function (event) { self.search (event, -1); });
    self.$next.bind ('click.mb', function (event) { self.search (event,  1); });

    self.$release.bind ('change.mb', self.onChange);
    self.$artist.bind ('change.mb', self.onChange);
    self.$count.bind ('change.mb', self.onChange);

    return self;
};


MB.Control.ReleaseAddDisc = function (advanced_tab, basic_tab) {
    var self = MB.Object ();

    self.$add_disc_dialog = $('div.add-disc-dialog');

    self.selectTab = function (event) {
        var tab = $(this).attr ('class');
        $('.add-disc-dialog ul.tabs li').removeClass ('sel');
        $(this).closest ('li').addClass ('sel');
        $('div.add-disc-tab').hide ();
        $('div.add-disc-tab.' + tab).show ();
    };

    self.confirm = function (event) {
        var tab = self.$add_disc_dialog.find ('ul.tabs li.sel a').attr ('class');

        self['confirm_' + tab] (event);
    };

    self.confirm_manual = function (event) {
        /* add the disc and start with atleast one track. */
        basic_tab.addDisc ().disc.addTrack ();
        self.close (event);
    };

    self.confirm_tracklist = function (event) {
        var disc = basic_tab.addDisc ();
        disc.$tracklist_id.val (self.use_tracklist.selected.$id.val ());
        disc.collapse ();
        disc.expand ();

        self.close (event);
    };

    self.confirm_freedb = function (event) {
        self.freedb_import.selected.renderToDisc (basic_tab.addDisc ());
        self.close (event);
    };

    self.confirm_cdstub = function (event) {
        self.cdstub_import.selected.renderToDisc (basic_tab.addDisc ());
        self.close (event);
    };

    self.close = function (event) {
        self.$add_disc_dialog.hide ();
    };

    self.$add_disc_dialog.appendTo ($('body'));
    self.$add_disc_dialog.find ('ul.tabs a').bind ('click.mb', self.selectTab);

    self.$add_disc_dialog.find ('input.add-disc').bind ('click.mb', self.confirm);
    self.$add_disc_dialog.find ('input.cancel').bind ('click.mb', self.close);

    $("a[href=#add_disc]").click (function () {

        self.$add_disc_dialog.show ().position ({
            my: "center top",
            at: "center top",
            of: $('#page'),
            offset: "0 15"
        });

        $('html').animate({ scrollTop: 0 }, 500);

    });

    self.use_tracklist = MB.Control.ReleaseImport (self, 'tracklist');
    self.freedb_import = MB.Control.ReleaseImport (self, 'freedb');
    self.cdstub_import = MB.Control.ReleaseImport (self, 'cdstub');

    return self;
};
