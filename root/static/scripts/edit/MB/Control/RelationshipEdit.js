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

    self.$name = $('#id-ar\\.' + entity + '\\.name');

    if (self.$name.length === 0)
    {
        return self; // URL entity type, not currently supported.
    }

    self.$id = $('#id-ar\\.' + entity + '\\.id');
    self.$link = self.$name.closest ('span').siblings ('span.link').find ('a');
    self.type = self.$link.attr ('class');

    self.$name.bind ('lookup-performed', function (event, data) {
        self.$link.show ().html (MB.text.link).
            attr('href', '/' + self.type.replace('_', '-') + '/' + data.gid).
            attr('title', data.comment);
    });

    self.$name.bind ('cleared', function (event, data) {
        self.$link.hide ();
    });

    MB.Control.EntityAutocomplete ({
        'inputs': self.$name.parent (),
        'entity': self.type
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

    // The user has submitted the form, and changed direction, but the form
    // wasnt valid. In this case, we should swap the entities around again, to match
    // the form state.
    if (self.$direction.val() == 1) {
        var entity0 = $('#entity0').children ().detach ();
        var entity1 = $('#entity1').children ().detach ();

        $('#entity0').append (entity1);
        $('#entity1').append (entity0);
    }

    return self;
};
