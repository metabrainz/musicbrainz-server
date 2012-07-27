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

var RE = {Util: {}, serverFields: {}, newWorks: {}};


(function() {

var UI = RE.UI = {}, Util = RE.Util;


UI.release = {
    media: ko.observableArray([]),

    relationships: ko.observableArray([]),

    addRelationship: function(element, i, relationship) {
        $(element).hide().fadeIn("fast");

        if (relationship.promise) {
            var promise = relationship.promise;
            delete relationship.promise;
            setTimeout(promise, 0);
        }
    },

    removeRelationship: function(element, i, relationship) {
        $(element).fadeOut("fast", function() {$(this).remove()});
    },

    checkboxes: (function() {

        var rstr = MB.text.RecordingSelection, wstr = MB.text.WorkSelection,
            checkboxes = {
                recordingCount: ko.observable(0),
                workCount: ko.observable(0)
            };

        checkboxes.recordingMessage = ko.computed(function() {

            var count = checkboxes.recordingCount();
            return "(" + (count == 1 ? rstr[0] : rstr[1]).replace("{num}", count) + ")";

        }).extend({throttle: 20});

        checkboxes.workMessage = ko.computed(function() {

            var count = checkboxes.workCount();
            return "(" + (count == 1 ? wstr[0] : wstr[1]).replace("{num}", count) + ")";

        }).extend({throttle: 20});

        return checkboxes;
    })(),

    loadingIndicator:
        '<span class="loading">' +
            '<img src="/static/images/icons/loading.gif" class="bottom"/> ' +
             MB.text.LoadingRelationships +
        '</span>',
};


UI.init = function(releaseGID) {

    UI.$tbody = $("#tracklist tbody");

    UI.Dialog.init();

    // preload image to avoid flickering
    $("<img/>").attr("src", "/static/images/icons/add.png");

    UI.release.entity = RE.Entity({type: "release", gid: releaseGID});

    ko.applyBindings(UI.release, document.getElementById("form"));

    var url = "/ws/js/release/" + releaseGID + "?inc=recordings+rels",
        $loading = $(UI.release.loadingIndicator).insertAfter("#tracklist");

    function renderTrack(track, medium, release) {
        var recording = track.recording;

        recording.type = "recording";
        recording.name = track.name;
        recording.position = track.position;
        recording.number = track.number;
        delete recording.artist_credit;
        recording.artistCredit = "";

        if (!RE.Util.compareArtistCredits(release.artist_credit, track.artist_credit))
            recording.artistCredit = UI.renderArtistCredit(track.artist_credit);

        Util.parseRelationships(recording, true);
        medium.recordings.push(RE.Entity(recording));
    }

    var media = UI.release.media;

    $.getJSON(url, function(data) {
        data.type = "release";
        RE.Entity(data);

        $.each(data.mediums, function(i, medium) {
            medium.format = (medium.format || MB.text.Medium) + " " + medium.position;
            var tracks = medium.tracks;
            delete medium.tracks;
            medium.recordings = ko.observableArray([]);
            media.push(medium);

            $.each(tracks, function(i, track) {
                setTimeout(function() {renderTrack(track, medium, data)}, 0);
            });
        });

        Util.parseRelationships(data, true);

        UI.initButtons();
        UI.initCheckboxes();
        $loading.remove();
    });
};


UI.initCheckboxes = function() {

    var $medium_recordings = UI.$tbody.find("input.medium-recordings"),
        $medium_works = UI.$tbody.find("input.medium-works"),
        recording_selector = "td.recording > input[type=checkbox]",
        work_selector = "td.works > div.ar > input[type=checkbox]";

    var checkboxes = UI.release.checkboxes;

    function count($inputs) {
        var src = {}, count = 0, input;
        for (var i = 0; input = $inputs[i]; i++) {
            var id = ko.dataFor(input).id;
            if (src[id] === undefined) count += (src[id] = 1);
        }
        return count;
    }

    function medium($inputs, selector, counter) {
        $inputs.change(function(event) {
            var checked = this.checked,
                $changed = $(this).parents("tr.subh").nextUntil("tr.subh")
                    .find(selector).filter(checked ? ":not(:checked)" : ":checked")
                    .prop("checked", checked);
            counter(counter() + count($changed) * (checked ? 1 : -1));
        });
    }

    function release($inputs, cls) {
        $('<input type="checkbox"/>&#160;')
            .change(function(event) {
                $inputs.prop("checked", this.checked).change();
            })
            .prependTo("#tracklist th." + cls);
    }

    function range(selector, counter) {
        var last_clicked = null;

        UI.$tbody.on("click", selector, function(event) {
            var checked = this.checked, $inputs = $(selector, UI.$tbody);
            if (event.shiftKey && last_clicked && last_clicked != this) {
                var first = $inputs.index(last_clicked), last = $inputs.index(this);

                (first > last
                    ? $inputs.slice(last, first + 1)
                    : $inputs.slice(first, last + 1))
                    .prop("checked", checked);
            }
            counter(count($inputs.filter(":checked")));
            last_clicked = this;
        });
    }

    medium($medium_recordings, recording_selector, checkboxes.recordingCount);
    medium($medium_works, work_selector, checkboxes.workCount);

    release($medium_recordings, "recordings");
    release($medium_works, "works");

    range(recording_selector, checkboxes.recordingCount);
    range(work_selector, checkboxes.workCount);
};


UI.checkedRecordings = function() {
    return $.map(UI.$tbody.find("td.recording > input[type=checkbox]:checked"),
        function(input) {return ko.dataFor(input)});
};


UI.checkedWorks = function() {
    return $.map(UI.$tbody.find("td.works > div.ar > input[type=checkbox]:checked"),
        function(input) {return ko.dataFor(input)});
};


UI.initButtons = function() {
    $("#batch-recording").click(function() {
        if (!$(this).hasClass("disabled"))
            UI.BatchRecordingRelationshipDialog.show();
    });

    $("#batch-work").click(function() {
        if (!$(this).hasClass("disabled"))
            UI.BatchWorkRelationshipDialog.show();
    });

    $("#batch-create-works").click(function() {
        if (!$(this).hasClass("disabled")) UI.BatchCreateWorksDialog.show();
    });

    $("#form").on("click", "span.add-rel", function(event) {
        UI.Dialog.posx = event.pageX;
        UI.Dialog.posy = event.pageY;
        UI.AddDialog.show({source: ko.dataFor(this), target: RE.Util.tempEntity("artist")});
    });

    $("#form").on("click", "span.relate-work", function() {
        UI.AddDialog.show({source: ko.dataFor(this), target: RE.Util.tempEntity("work")});
    });

    $("#form").on("click", "span.remove-button", function() {
        var relationship = ko.dataFor(this), action = relationship.action(), newAction = "remove";

        if (action == "add") {
            $(this).parent().children("input[type=checkbox]:checked")
                .prop("checked", false).click();
            relationship.remove();
            return;
        }
        if (action == "remove") newAction = "";
        if (action == "edit" && newAction == "remove") relationship.reset();
        relationship.action(newAction);
    });

    $("#form").on("click", "span.link-phrase", function(event) {
        var relationship = ko.dataFor(this);

        if (relationship.action() != "remove") {
            UI.Dialog.posx = event.pageX;
            UI.Dialog.posy = event.pageY;
            UI.EditDialog.show(relationship);
        }
    });
};


UI.renderArtistCredit = function(obj) {
    var html = "", name;
    for (var i = 0; name = obj[i]; i++)
        html += RE.Entity(name.artist).rendering() + name.joinphrase;
    return html;
};

})();
