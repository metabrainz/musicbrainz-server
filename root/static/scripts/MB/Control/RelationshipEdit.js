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

MB.Control.RelationshipEntity = function (entity) {
    var self = MB.Object ();

    self.$id = $('#id-ar\\.' + entity + '\\.id');

    if (self.$id.length === 0)
    {
        return self; // URL entity type, not currently supported.
    }

    self.$name = $('#id-ar\\.' + entity + '\\.name');
    self.$link = self.$name.closest ('span').siblings ('span.link').find ('a');
    self.type = self.$link.attr ('class');

    self.selected = function (event, data) {
        if (data.name)
        {
            self.$name.val (data.name).removeClass ('error');
            self.$id.val (data.id);
            self.$link.html (MB.text.link).
                attr('href', '/' + self.type + '/' + data.gid).
                attr('title', data.comment);
        }

        event.preventDefault();
        return false;
    };

    MB.Control.Autocomplete ({
        'input': self.$name,
        'entity': self.type.replace ("_", "-"),
        'select': self.selected
    });

    return self;
}

MB.Control.RelationshipEdit = function () {
    var self = MB.Object ();

    self.$direction = $('#id-ar\\.direction');
    self.entity0 = MB.Control.RelationshipEntity ('entity0');
    self.entity1 = MB.Control.RelationshipEntity ('entity1');

    self.changeDirection = function (event) {

        var newval = self.$direction.val () === "1" ? "0" : "1";
        self.$direction.val (newval);

        var entity0 = $('#entity0').children ().detach ();
        var entity1 = $('#entity1').children ().detach ();

        $('#entity0').append (entity1);
        $('#entity1').append (entity0);
    };

    $('#changedirection').bind ('click.mb', self.changeDirection);

    return self;
};
