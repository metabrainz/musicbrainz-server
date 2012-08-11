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

MB.RelationshipEditor = (function(RE) {

var UI = RE.UI = RE.UI || {}, Util = RE.Util = RE.Util || {},
    $tracklist, release, parseMedium, parseTrack;

release = {
    media: ko.observableArray([]),

    relationships: ko.observableArray([]),

    addRelationship: function(elements, relationship) {
        if (relationship.promise) {
            _.defer(relationship.promise);
            delete relationship.promise;
        }
    },

    checkboxes: (function() {

        var data = {
            recordingStrings: ko.observable([]),
            workStrings: ko.observable([]),
            recordingCount: ko.observable(0),
            workCount: ko.observable(0)
        };

        data.recordingMessage = ko.computed(function() {
            var strings = data.recordingStrings(),
                msg = strings[Math.min(strings.length - 1, data.recordingCount())];

            return msg ? "(" + msg + ")" : "";
        }).extend({throttle: 100});

        data.workMessage = ko.computed(function() {
            var strings = data.workStrings(),
                msg = strings[Math.min(strings.length - 1, data.workCount())];

            return msg ? "(" + msg + ")" : "";
        }).extend({throttle: 100});

        return data;
    }()),

    loadingIndicator:
        '<span class="loading">' +
            '<img src="../../../static/images/icons/loading.gif" class="bottom"/> ' +
             MB.text.LoadingRelationships +
        '</span>',
};


RE.init = function(params, errorFields) {
    RE.serverFields = {};
    RE.newWorks = {};
    RE.attrRoots = {};

    for (var id in RE.attrMap) {
        var attr = RE.attrMap[id];
        if (!attr.parent) RE.attrRoots[attr.name] = attr;
    }

    var foo = RE.typeInfoByEntities = {};

    $.each(RE.typeInfo, function(id, root) {
        if (root.parent) return;
        var entities = root.types.join("-");
        (foo[entities] = foo[entities] || []).push(root);
    });

    $.each(foo, function(entities, children) {
        children.sort(function(a, b) {
            return a.child_order - b.child_order;
        });
    });
    delete foo;

    Util.CGI.parseParams(params, errorFields);
};


UI.init = function(releaseGID) {
    UI.Dialog.init();

    $tracklist = $("#tracklist tbody");
    // preload image to avoid flickering
    $("<img/>").attr("src", "../../../static/images/icons/add.png");

    release.entity = RE.Entity({type: "release", gid: releaseGID});

    ko.applyBindings(release, document.getElementById("form"));

    var url = "/ws/js/release/" + releaseGID + "?inc=recordings+rels",
        $loading = $(release.loadingIndicator).insertAfter("#tracklist");

    $.getJSON(url, function(data) {
        data.type = "release";
        RE.Entity(data);
        var trackCount = 0;

        var media = data.mediums;
        for (var i = 0; i < media.length; i++)
            trackCount += parseMedium(media[i], release.media, data);

        Util.parseRelationships(data, true);

        initButtons();
        initCheckboxes(trackCount);

        $loading.remove();
    });
};


parseMedium = function(medium, media, release) {
    medium.format = (medium.format || MB.text.Medium) + " " + medium.position;
    var tracks = medium.tracks;
    delete medium.tracks;
    medium.recordings = ko.observableArray([]);
    media.push(medium);

    _.map(tracks, function(track) {
        _.defer(parseTrack, track, medium, release);
    });
    return tracks.length;
};


parseTrack = function(track, medium, release) {
    var recording = track.recording;

    recording.type = "recording";
    recording.name = track.name;
    recording.position = track.position;
    recording.number = track.number;
    delete recording.artist_credit;
    recording.artistCredit = "";

    if (!Util.compareArtistCredits(release.artist_credit, track.artist_credit))
        recording.artistCredit = UI.renderArtistCredit(track.artist_credit);

    Util.parseRelationships(recording, true);
    medium.recordings.push(RE.Entity(recording));
};


UI.checkedRecordings = function() {
    return $.map($tracklist.find("td.recording > input[type=checkbox]:checked"),
        function(input) {return ko.dataFor(input)});
};


UI.checkedWorks = function() {
    return $.map($tracklist.find("td.works > div.ar > input[type=checkbox]:checked"),
        function(input) {return ko.dataFor(input)});
};


function initCheckboxes(trackCount) {

    var $medium_recordings = $tracklist.find("input.medium-recordings"),
        $medium_works = $tracklist.find("input.medium-works"),
        recording_selector = "td.recording > input[type=checkbox]",
        work_selector = "td.works > div.ar > input[type=checkbox]",
        checkboxes = release.checkboxes;

    // get translated strings for the checkboxes
    function getPlurals(singular, plural, max, name) {

        var url = "/ws/js/plurals?singular=" + encodeURIComponent(singular) +
                  "&plural=" + encodeURIComponent(plural) + "&max=" + max;

        $.getJSON(url, function(data) {
            checkboxes[name](data.strings);
        });
    }
    getPlurals("{n} recording selected", "{n} recordings selected", trackCount, "recordingStrings");
    getPlurals("{n} work selected", "{n} works selected", trackCount, "workStrings");

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

    function _release($inputs, cls) {
        $('<input type="checkbox"/>&#160;')
            .change(function(event) {
                $inputs.prop("checked", this.checked).change();
            })
            .prependTo("#tracklist th." + cls);
    }

    function range(selector, counter) {
        var last_clicked = null;

        $tracklist.on("click", selector, function(event) {
            var checked = this.checked, $inputs = $(selector, $tracklist);
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

    _release($medium_recordings, "recordings");
    _release($medium_works, "works");

    range(recording_selector, checkboxes.recordingCount);
    range(work_selector, checkboxes.workCount);
}


function initButtons() {
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
        UI.AddDialog.show({source: ko.dataFor(this), target: Util.tempEntity("artist")});
    });

    $("#form").on("click", "span.relate-work", function() {
        UI.AddDialog.show({source: ko.dataFor(this), target: Util.tempEntity("work")});
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
}


function renderArtistCredit(obj) {
    var html = "", name;
    for (var i = 0; name = obj[i]; i++)
        html += RE.Entity(name.artist).rendering() + name.joinphrase;
    return html;
}

return RE;

}(MB.RelationshipEditor || {}));
