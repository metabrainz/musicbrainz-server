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

MB.Edit = (MB.Edit) ? MB.Edit : {};

MB.Edit.Base = function(obj, boxnumber, container) {
    var self = MB.Object();

    var $submit_button = $('button.submit.positive');

    self.getData = function () {
        return {
            "name": $('input[name=edit-label\\.name]').val (),
            "sort_name": $('input[name=edit-label\\.sort_name]').val (),
            "lifespan": {
                "begin": {
                    "year": $('input[name=edit-label\\.begin_date\\.year]').val (),
                    "month": $('input[name=edit-label\\.begin_date\\.month]').val (),
                    "day": $('input[name=edit-label\\.begin_date\\.day]').val ()
                },
                "end": {
                    "year": $('input[name=edit-label\\.end_date\\.year]').val (),
                    "month": $('input[name=edit-label\\.end_date\\.month]').val (),
                    "day": $('input[name=edit-label\\.end_date\\.day]').val ()
                }
            }
        }
    };

    self.saveEdit = function () {
        var mbid = $('input[name=edit-label\\.id]').val ();
        var url = 'http://localhost:3000/ws/2/label/' + mbid;

        $.ajax ({
            "url": url,
            "type": "PUT",
            "accepts": { "json": "application/json" },
            "contentType": "application/json",
            "data": JSON.stringify (self.getData ()),
            "statusCode": {
                201: self.saveEditNote,
                400: function () { console.log ('FIXME: 400 Bad Request'); },
                409: function () { console.log ('FIXME: 409 Conflict'); },
            },
            "error": function () { console.log ('FIXME: error') },
            "success": function () { console.log ('FIXME: success') }
        });
    };

    self.saveEditNote = function (data, textStatus, jqXHR) {
        var edit_note = $('#id-edit-label\\.edit_note').val ();
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

    $submit_button.bind ('click.mb', function (event) {
        event.preventDefault ();

        self.saveEdit ();

        return false;
    });

    return self;
};

$(document).ready (function () {
    MB.Edit.Base ();
});

