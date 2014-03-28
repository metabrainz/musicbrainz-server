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
    var self = {};

    self.$relate = $('div.relate-to');

    /* Do not initialize any of this if there is no "relate to ..."
     * link on the page. */
    if (! self.$relate.length)
    {
        return null;
    }

    self.$link = $('a.relate-to');
    self.$select = self.$relate.find ('select:first');
    self.$type0 = self.$relate.find ('input.type');
    self.$gid0 = self.$relate.find ('input.gid');
    self.$returnto = self.$relate.find ('input.returnto');
    self.$cancel = self.$relate.find ('button.cancel');
    self.$create = self.$relate.find ('button.create');
    self.$autocomplete = self.$relate.find ('span.autocomplete');

    self.type = function () {
        return self.$select.find ('option:selected').val ();
    };

    function cleanType(type) {
        return type.replace("-", "_");
    }

    self.createRelationship = function (event) {
        var item = self.autocomplete.currentSelection.peek();

        if (!item.gid) {
            return;
        }
        var location = '/edit/relationship/create',
            query_string = $.param ({
                type0: cleanType(self.$type0.val()),
                type1: cleanType(item.type),
                entity0: self.$gid0.val (),
                entity1: item.gid,
                returnto: self.$returnto.val()
            });

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
        event.stopPropagation();

        self.$relate.appendTo ($('body')).show ();

        var o = self.$link.offset ();
        var top = o.top + self.$link.height () + 8;
        var left = o.left + self.$link.width () - self.$relate.width () + 8;

        self.$relate.offset ({ top: Math.round (top), left: Math.round (left) });

        self.$select.focus();
        self.autocomplete.options.disabled = false;
    };

    self.hide = function (event) {
        /* Normally the autocomplete menu closes on its own, but there's a
           reproducible way to make it stay open. Just force it to close. */
        self.autocomplete.close();
        // Guarantee the menu won't pop up later if a lookup was in-progress.
        self.autocomplete.options.disabled = true;
        self.$relate.hide();
    };

    self.$select.bind ('change.mb', function (event) {
        self.autocomplete.changeEntity (self.type ());
    });

    self.$link.bind ('click.mb', function (event) {
        if (!self.$relate.is(":visible")) {
            self.show(event);
        } else {
            self.hide(event);
        }
    });

    self.$cancel.bind ('click.mb', function (event) { self.hide(event); });
    self.$create.bind ('click.mb', self.createRelationship);

    function setEntity (entity) {
        if (self.$select.find('option[value="' + entity + '"]').length > 0) {
            self.$select.val(entity).trigger("change.mb");
        } else {
            return false
        }
    }

    self.autocomplete = MB.Control.EntityAutocomplete ({
        'entity': self.type (),
        'inputs': self.$autocomplete,
        'resultHook': self.resultHook,
        'position': {
            my: "right top",
            at: "right bottom",
            collision: "none"
        },
        'setEntity': setEntity
    });

    self.autocomplete.$input.keydown(function (event) {
        if (event.keyCode == 13 && !event.isDefaultPrevented()) {
            self.createRelationship(event);
        }
    });

    var hovering = false;

    self.$relate.hover(function () {
        hovering = true;
    }, function() {
        hovering = false;
    });

    $(document)
        .click(function (event) {
            if (!hovering && !event.isDefaultPrevented() && self.$relate.is(":visible")) {
                self.hide(event);
            }
        })
        .keydown(function (event) {
            if (event.keyCode === 27 && !event.isDefaultPrevented() && self.$relate.is(":visible")) {
                self.hide(event);
            }
        });

    /* Opera triggers a click event whenever a select element is focused
       and a key is pressed, for no obvious reason. Prevent the box from
       hiding due to this. */
    self.$relate.click(function () { event.stopPropagation(); });

    return self;
};
