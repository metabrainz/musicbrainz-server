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

MB.Control.RelateTo = function () {
    var self = MB.Object();

    self.$relate = $('div.relate-to');

    /* Do not initialize any of this if there is no "relate to ..."
     * link on the page. */
    if (! self.$relate.length)
    {
        return null;
    }

    self.$link = $('a[href=#relate_to]');
    self.$select = self.$relate.find ('select.select:first');
    self.$endpoint = self.$relate.find('select.endpoint');
    self.$type0 = self.$relate.find ('input.type');
    self.$gid0 = self.$relate.find ('input.gid');
    self.$input = self.$relate.find ('input.entity');
    self.$cancel = self.$relate.find ('input.cancel');
    self.$create = self.$relate.find ('input.create');

    self.type = function () {
        return self.$relate.find ('option:selected').val ();
    };

    self.select = function (event, data) {
        self.$input.val (data.name);
        self.selected_item = data;
        self.selected_item.type = self.type ();
    };

    function cleanType(type) {
        if (type === 'release-group') {
            return 'release_group';
        }
        else {
            return type;
        }
    }

    self.createRelationship = function (event) {
        var endpoint = self.$endpoint.val(),
            location,
            query_string;
        if (endpoint && endpoint == 'recording') {
            location = '/edit/relationship/create-recordings';
            query_string = $.param ({
                release: self.$gid0.val (),
                type: cleanType(self.selected_item.type),
                gid: self.selected_item.gid,
                returnto: window.location.toString()
            });
        }
        else {
            location = '/edit/relationship/create';
            query_string = $.param ({
                type0: cleanType(self.$type0.val()),
                type1: cleanType(self.selected_item.type),
                entity0: self.$gid0.val (),
                entity1: self.selected_item.gid,
                returnto: window.location.toString()
            });
        }

        window.location = location + '?' + query_string;
    };

    self.resultHook = function (result) {

        if (self.$type0.val () !== self.type ())
            return result;

        // filter out any results which refer to the same entity as the one
        // we're viewing.
        var ret = [];
        $.each (result, function (idx, item) {
            if (item.gid === undefined || item.gid !== self.$gid0.val ()) {
                ret.push (item);
            }
        });

        return ret;
    };

    self.show = function (event) {
        self.$relate.appendTo ($('body')).show ()

        var o = self.$link.offset ();
        var top = o.top + self.$link.height () + 8;
        var left = o.left + self.$link.width () - self.$relate.width () + 8;

        self.$relate.offset ({ top: Math.round (top), left: Math.round (left) });
    };

    self.$select.bind ('change.mb', function (event) {
        self.autocomplete.changeEntity (self.type ());
    });

    self.$link.bind ('click.mb', self.show);
    self.$cancel.bind ('click.mb', function (event) { self.$relate.hide (); });
    self.$create.bind ('click.mb', self.createRelationship);

    self.autocomplete = MB.Control.Autocomplete ({
        'entity': self.type (),
        'input': self.$input,
        'select': self.select,
        'resultHook': self.resultHook,
        'position': {
            my: "right top",
            at: "right bottom",
            collision: "none"
        }
    });

    return self;
};
