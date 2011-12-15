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

MB.Edit = (MB.Edit) ? MB.Edit : {};


MB.Edit.mapping = {};
MB.Edit.mapping.role = {};
MB.Edit.mapping.role.age = {
    "begin_date\\.year": "lifespan.begin.year",
    "begin_date\\.month": "lifespan.begin.month",
    "begin_date\\.day": "lifespan.begin.day",
    "end_date\\.year": "lifespan.end.year",
    "end_date\\.month": "lifespan.end.month",
    "end_date\\.day": "lifespan.end.day"
};

MB.Edit.mapping.label = jQuery.extend ({
    "name": "name",
    "sort_name": "sort_name"
}, MB.Edit.mapping.role.age);

MB.Edit.Base = function(type, prefix) {
    var self = MB.Object();

    var $submit_button = $('button.submit.positive');

    self.type = type;
    self.prefix = prefix;
    self.reverse_mapping = {};
    $.each (MB.Edit.mapping[type], function (key, value) { self.reverse_mapping[value] = key; });

    self.getInput = function (path) {
        var fieldname = path.replace (/\.errors$/, "");

        if (! self.reverse_mapping[fieldname])
        {
            $.each (MB.utility.keys (self.reverse_mapping), function (idx, key) {
                if ( _(key).startsWith (fieldname) )
                {
                    fieldname = key;
                    return false;
                }
            });
        }

        return $('input[name=' + self.prefix + '\\.' + self.reverse_mapping[fieldname] + ']');
    };

    self.getData = function () {
        var ret = {};

        $.each (MB.Edit.mapping[self.type], function (form_field, json_field) {
            ret[json_field] = $('input[name=' + self.prefix + '\\.' + form_field + ']').val ();
        });

        return MB.utility.expand_hash (ret);
    };

    self.saveEdit = function () {
        var mbid = $('input[name=' + self.prefix + '\\.id]').val ();
        var url = '/ws/2/' + self.type + '/' + mbid;

        $.ajax ({
            "url": url,
            "type": "PUT",
            "beforeSend": function(jqXHR, settings) {
                jqXHR.setRequestHeader("Accept", "application/json");
            },
            "contentType": "application/json",
            "data": JSON.stringify (self.getData ()),
            "statusCode": {
                201: self.saveEditNote,
                400: self.validationError,
                409: function () { console.log ('FIXME: 409 Conflict'); },
            },
        });
    };

    self.saveEditNote = function (data, textStatus, jqXHR) {
        var edit_note = $('#id-' + self.prefix + '\\.edit_note').val ();
        var url = jqXHR.getResponseHeader ('Location');
        var edit_id = url.match (/[0-9]+$/)[0];

        /* FIXME:
           this posts the edit note to the regular edit note
           page.  A webservice for posting edit notes has not
           been implemented yet.  Rewrite this function when
           the webservice is finished.
        */

        var $form = $('<form method="post" action="/edit/enter_votes">');
        $form
            .append ($('<input type="hidden" name="enter-vote.vote.0.edit_id" value="' + edit_id + '">'))
            .append ($('<input type="hidden" name="url" value="' + url + '">'))
            .append ($('<textarea name="enter-vote.vote.0.edit_note">' + edit_note + '</textarea>'));

        $('body').append ($form);
        $form.submit ();
    };

    self.validationError = function (data, textStatus, jqXHR) {
        var data = MB.utility.collapse_hash (JSON.parse (data.responseText));

        // Clear old validation errors.
        $('ul.errors').hide ().empty ();

        $.each (data, function (key, value) {

            var $input = self.getInput (key);
            var $errors = $input.closest ('div.row').find ('ul.errors').show ();

            $.each (value, function (idx, message) {
                $('<li>').text (message).appendTo ($errors);
            });
        });

    };

    $submit_button.bind ('click.mb', function (event) {
        event.preventDefault ();

        self.saveEdit ();

        return false;
    });

    return self;
};

MB.Edit.Label = function () {
    var self = MB.Edit.Base ('label', 'edit-label');

    return self;
};

$(document).ready (function () {
    MB.Edit.Label ();
});

