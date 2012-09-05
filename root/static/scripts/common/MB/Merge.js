/*
   This file is part of MusicBrainz, the open internet music database.
   Copyright (C) 2010,2011 MetaBrainz Foundation

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

MB.Merge = function () {
    var self = MB.Object();

    var parts = window.location.pathname.split ("/");
    self.type = parts[1];
    self.mbid = parts[2];

    var store = new Persist.Store('MusicBrainz', {
        about: "MusicBrainz session data",
        swf_path: "/static/lib/persist-js/persist.swf"
    });

    self.merge = {};

    self.add_to_merge = function (event) {
        event.preventDefault ();

        var entity = {
            "type": self.type,
            "mbid": self.mbid,
            "name": $('#descriptive-link').html ()
        };

        self.merge[entity.type][entity.mbid] = entity;
        store.set ("merge", JSON.stringify (self.merge), function () {
            self.display_merge_add_row (entity);
        });
    };

    self.display_merge_add_row = function (entity) {
        var $ul = $('#merge-js');
        var $template = $ul.find ('li.template');

        $template
            .clone ()
            .removeClass ('template')
            .show ()
            .data ('entity', entity)
            .appendTo ($ul)
            .find ('label').html (entity.name)
    };

    self.display_merge = function (merge, type) {
        $.each (merge[type], function (mbid, entity) {
            self.display_merge_add_row (entity);
        });
    };

    store.get ("merge", function (ok, val) {
        if (ok) {
            var obj = JSON.parse (val);
            self.merge = (obj instanceof Object) ? obj : {};
            self.merge[self.type] = (self.merge[self.type]
                                     ? self.merge[self.type] : {});
        }

        /* don't bind the click event until data has been loaded from
         * localStorage.  (To prevent overwriting data by accident). */
        if ($('#add-to-merge').length)
        {
            $('#add-to-merge').bind ('click.mb', self.add_to_merge);
        }

        self.display_merge (self.merge, self.type);
    });

    return self;
}

$(document).ready (function () {
    MB.merge = MB.Merge ();
});

