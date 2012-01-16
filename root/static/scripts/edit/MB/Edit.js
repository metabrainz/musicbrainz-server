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

MB.Edit.render_field = function (key, val) {
    if (_(key).startsWith ('life-span.'))
    {
        _.each (
            _.zip ([ "year", "month", "day"], val.split ("-")),
            function (fv) {
                $(
                    MB.utility.escapeID ([ '#entity', key, fv[0]].join ('.'))
                ).val (fv[1]);
            }
        );
    }
    else
    {
        $(MB.utility.escapeID ('#entity.' + key)).val (val);
    }
};


MB.Edit.render_fields = function (data, textStatus, jqXHR) {
    $.each (MB.utility.collapse_hash (data), MB.Edit.render_field);
};


MB.Edit.load_entity = function (url) {
    $.ajax ({
        "url": url,
        "type": "GET",
        "beforeSend": function(jqXHR, settings) {
            jqXHR.setRequestHeader("Accept", "application/json");
        },
        "contentType": "application/json",
        "statusCode": {
            200: MB.Edit.render_fields,
            404: function () { console.log ('FIXME: entity deleted while loading page'); }
        }
    });
};


MB.Edit.read_fields = function (inputs) {
    var ret = {};

    _.chain (inputs)
        .filter (function (elem) {
            return _($(elem).attr ('name')).startsWith ('entity.');
        })
        .each (function (elem) {
            ret[$(elem).attr ('name').replace ('entity.', '')] = $(elem).val ();
        });

    return ret;
};


MB.Edit.compact_lifespan = function (data) {

    _.each (['life-span.begin', 'life-span.end'], function (prefix) {

        var year  = data[prefix + '.year'];   delete data[prefix + '.year'];
        var month = data[prefix + '.month'];  delete data[prefix + '.month'];
        var day   = data[prefix + '.day'];    delete data[prefix + '.day'];

        if (_(year).isEmpty ())
        {
            /* nothing. */
        }
        else if (_(month).isEmpty ())
        {
            data[prefix] = year;
        }
        else if (_(day).isEmpty ())
        {
            data[prefix] = year + "-" + month;
        }
        else
        {
            data[prefix] = year + "-" + month + "-" + day;
        }
    });

    return data;
};


MB.Edit.save_edit_note = function (data, textStatus, jqXHR) {
    var edit_note = $('textarea.edit-note').val ();
    var url = jqXHR.getResponseHeader ('Location');
    var edit_id = url.match (/[0-9]+$/)[0];

    if (edit_note === '')
    {
        window.location.href = url;
        return;
    }

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


MB.Edit.validation_error = function (data, textStatus, jqXHR) {
    var data = MB.utility.collapse_hash (JSON.parse (data.responseText));

    // Clear old validation errors.
    $('ul.errors').hide ().empty ();

    $.each (data, function (key, value) {

        var $errors = $(MB.utility.escapeID ('#entity.' + key))
            .closest ('div.row').find ('ul.errors').show ();

        $.each (value, function (idx, message) {
            $('<li>').text (message).appendTo ($errors);
        });
    });
};


MB.Edit.save_edit = function (url, data) {
    $.ajax ({
        "url": url,
        "type": "PUT",
        "beforeSend": function(jqXHR, settings) {
            jqXHR.setRequestHeader("Accept", "application/json");
        },
        "contentType": "application/json",
        "data": JSON.stringify (data),
        "statusCode": {
            201: MB.Edit.save_edit_note,
            400: MB.Edit.validation_error,
            409: function () { console.log ('FIXME: 409 Conflict'); },
        }
    });
};


MB.Edit.initialize = function (type, gid) {
    var url = '/ws/2/' + type + '/' + gid;

    MB.Edit.load_entity (url);

    $('button.submit.positive').bind ('click.mb', function (event) {
        event.preventDefault ();

        MB.Edit.save_edit (url, 
                           MB.utility.expand_hash (
                               MB.Edit.compact_lifespan (
                                   MB.Edit.read_fields ($('input')))));

        return false;
    });
};
