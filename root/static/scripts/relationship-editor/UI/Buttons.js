/*
   This file is part of MusicBrainz, the open internet music database.
   Copyright (C) 2012 MetaBrainz Foundation

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


(function() {

var UI = RE.UI, Buttons = UI.Buttons = {};


Buttons.initEvents = function() {

    $("#form").on("click", "a.remove-button", Buttons.Remove.clicked)

    .on("click", "span.link-phrase", function(event) {

        if ($(this).hasClass("disabled")) return;
        var rel = $(this).data("relationship");
        UI.Dialog.posx = event.pageX;
        UI.Dialog.posy = event.pageY;
        UI.EditDialog.show([rel, rel.source, rel.target.type]);

    }).on("click", "span.add-rel", function(event) {

        var source = $(this).data("source");
        UI.AddDialog.show([source, "artist"]); // default to artist

    }).on("click", "span.relate-work", function(event) {

        var source = $(this).data("source");
        UI.AddDialog.show([source, "work"]);
    });

    $("#batch-recording").click(function() {
        UI.BatchAddDialog.show("recording");
    });

    $("#batch-work").click(function() {
        UI.BatchAddDialog.show("work");
    });

    $("#batch-create-works").click(function() {
        UI.BatchCreateWorksDialog.show();
    });
};


Buttons.Remove = function(relationship) {
    return $(this.template).data("relationship", relationship);
};


Buttons.Remove.clicked = function(event) {
    event && event.preventDefault();

    var rel = $(this).data("relationship"), $container = rel.$container;

    if (rel.fields.action != "remove") {
        if (rel.fields.action == "add") {
            $container.fadeOut("fast", function() {
                $.each($container.children("input[type=checkbox]"), function(i, input) {
                    var $input = $(input);
                    if ($input.is(":checked")) $input.prop("checked", false).click();
                });
                rel.remove();
            });
        } else {
            rel.fields.action = "remove";
            rel.update();
            $container.children("span.link-phrase").addClass("rel-remove disabled");
        }
    } else {
        delete rel.fields.action;
        rel.update();
        $container.children("span.link-phrase").removeClass("rel-remove disabled");
    }
};


Buttons.Remove.prototype.template =
    '<a href="#" class="remove-button">&#215;</a>';


Buttons.AddRelationship = function(source) {
    return $(this.template).data("source", source);
};


Buttons.AddRelationship.prototype.template =
    '<span class="add-rel btn">&#160;' +
        '<img src="/static/images/icons/add.png" class="bottom"/> ' +
        MB.text.AddRelationship +
    '</span>';


Buttons.RelateToWork = function(source) {
    return Buttons.AddRelationship.call(this, source);
};


Buttons.RelateToWork.prototype.template =
    '<span class="relate-work btn">' +
        '&#8592 <img src="/static/images/icons/add.png" class="bottom"/> ' +
        MB.text.RelateRecordingWork + ' &#8594;' +
    '</span>';

})();
