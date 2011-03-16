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

MB.Control.ReleaseUseTracklist = function (parent) {
    var self = MB.Object ();

    self.parent = parent;
    self.$fieldset = $('div.add-disc-tab.tracklist');
    self.$release = self.$fieldset.find ('input.tracklist-release');
    self.$artist = self.$fieldset.find ('input.tracklist-artist');
    self.$count = self.$fieldset.find ('input.tracklist-count');
    self.$template = self.$fieldset.find ('.use-tracklist-template');
    self.$pager_div = self.$fieldset.find ('div.pager');
    self.$pager = self.$fieldset.find ('span.pager-tracklist');

    self.$search = $('a[href=#search_tracklist]');
    self.$next = $('a[href=#next_tracklist]');
    self.$prev = $('a[href=#prev_tracklist]');

    self.expand = function (event) {

        var $div = $(this).closest('div');
        var $table = $div.find('table');
        var $icon = $div.find ('span.ui-icon');
        var $loading = $div.find('.tracklist-loading');
        var $buttons = $div.find ('div.buttons');
        var tracklist = $div.find ('input.tracklist-id').val ();

        if ($table.is(':visible') || $loading.is(':visible'))
        {
            $icon.removeClass ('ui-icon-triangle-1-s').addClass ('ui-icon-triangle-1-e');
            $div.removeClass ('tracklist-padding');
            $loading.hide ();
            $table.hide ();
            $buttons.hide ();

            return;
        }

        $('table.use-tracklist').hide ();
        $('div.use-tracklist a.icon span').removeClass ('ui-icon-triangle-1-s').addClass ('ui-icon-triangle-1-e');
        $('div.use-tracklist').removeClass ('tracklist-padding');

        $icon.removeClass ('ui-icon-triangle-1-e').addClass ('ui-icon-triangle-1-s');
        $div.addClass ('tracklist-padding');
        $loading.show ();

        $.getJSON ('/ws/js/tracklist/' + tracklist, function (data) {
            $table.find ('tr.track').eq (0).nextAll ().remove ();

            $.each (data, function (idx, item) {
                var tr = $table.find ('tr.track').eq(0).clone ()
                    .appendTo ($table.find ('tbody'));

                tr.find ('td.position').text (idx + 1);
                tr.find ('td.title').text (item.name);
                tr.find ('td.artist').text (item.artist_credit.preview);
                tr.find ('td.length').text (item.length);
                tr.show ();
            });

            $loading.hide ();
            $table.show ();
            $buttons.show ();
        });

    };

    self.results = function (data) {

        $.each (data, function (idx, item) {
            if (item.current)
            {
                var pager = MB.utility.template (MB.text.Pager);
                self.total = item.pages;

                self.$pager.text (pager.draw ({ 'page': item.current, 'total': item.pages }));
                self.$pager_div.show ();
                return;
            }

            var tl = self.$template.clone ()
                .appendTo (self.$fieldset)
                .removeClass ('use-tracklist-template')
                .addClass ('use-tracklist');

            var format = item.format ? item.format : 'Disc';
            var medium = '(' + format + ' ' + item.position +
                (item.medium ? ': ' + item.medium : '') + ')';

            tl.find ('span.title').text (item.name);
            tl.find ('span.medium').text (medium);
            tl.find ('span.artist').text (item.artist);
            tl.find ('input.tracklist-id').val (item.tracklist_id);
            tl.find ('a.icon').bind ('click.mb', self.expand);

            tl.show ();
        });

        self.$fieldset.css ('height', 'auto');
    };

    self.search = function (event, direction) {
        var newPage = self.page + direction;
        if (newPage < 1 || newPage > self.total)
        {
            return;
        }

        self.page = newPage;
        var height = self.$fieldset.innerHeight ();
        self.$fieldset.css ('height', height);
        self.$fieldset.find ('div.use-tracklist').remove ();

        var data = {
            q: self.$release.val (),
            artist: self.$artist.val (),
            tracks: self.$count.val (),
            page: self.page
        };
        $.getJSON ('/ws/js/tracklist', data, self.results);
    };

    self.useTracklist = function (id) {

        var ta = self.parent.basic.addDisc ();
        ta.tracklist_id.val (id);
        ta.collapse ();
        ta.expand ();

        self.$fieldset.hide ();
    };

    self.onChange = function (event) { self.page = 1; };

    self.page = 1;
    self.total = 1;

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
        basic_tab.addDisc ();
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

    return self;
};
