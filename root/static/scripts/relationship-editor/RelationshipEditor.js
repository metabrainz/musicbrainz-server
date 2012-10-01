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
    $tracklist, parseMedium, parseTrack, releaseLoaded;

RE.releaseViewModel = {
    RE: RE,
    media: ko.observableArray([]),

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

    submissionLoading: ko.observable(false),
    submissionError: ko.observable(""),

    submit: function(data, event) {
        event.preventDefault();

        var self = this, data = {}, changed = [], addChanged;
        this.submissionLoading(true);

        addChanged = function(relationship) {
            if (relationship.action.peek()) changed.push(relationship);
        };

        _.each(this.media.peek(), function(medium) {
            _.each(medium.recordings.peek(), function(recording) {
                _.each(recording.relationships.peek(), addChanged);

                _.each(recording.performanceRelationships.peek(), function(relationship) {
                    addChanged(relationship);
                    _.each(relationship.target.peek().relationships.peek(), addChanged);
                });
            });
        });
        _.each(this.entity.relationships.peek(), addChanged);

        if (changed.length == 0) {
            this.submissionLoading(false);
            this.submissionError(MB.text.NoChanges);
            return;
        }
        changed = _.uniq(changed);

        _.each(changed, function(relationship, num) {
            relationship.buildFields(num, data);
        });

        data["rel-editor.edit_note"] = _.trim($("#id-rel-editor\\.edit_note").val());
        data["rel-editor.as_auto_editor"] = $("#id-rel-editor\\.as_auto_editor").is(":checked") ? 1 : 0;

        $.post("/relationship-editor", data)
            .success(function() {
                window.location.replace("/release/" + self.GID);
            })
            .error(function(jqXHR, statusText) {
                try {
                    self.handlerErrors(JSON.parse(jqXHR.responseText), changed);
                } catch(e) {
                    self.submissionLoading(false);
                    self.submissionError(statusText);
                }
            });
    },

    handlerErrors: function(data, changed) {
        _.each(data.errors, function(keys, num) {
            var relationship = changed[num];

            _.each(keys, function(error, key) {
                var parts = key.split(".");

                if (parts[0] == "entity") {
                    var i = parts[1];

                    if (relationship.entity()[i] === relationship.target())
                        relationship.target.error(error[0]);

                } else if (parts[1] == "begin_date" || parts[1] == "end_date") {
                    relationship[parts[1]].error(error[0]);

                } else if (parts.length == 1 && _.isObject(relationship[key]) &&
                    _.isFunction(relationship[key].error)) {

                    relationship[key].error(error[0]);
                } else {
                    relationship.errorCount += 1;
                    relationship.hasErrors(true);
                }
            });
        });
        this.submissionLoading(false);
        this.submissionError(data.message);
    }
};


UI.init = function(releaseGID, data) {
    RE.releaseViewModel.GID = releaseGID;

    UI.Dialog.init();
    UI.WorkDialog.init();

    $("#overlay").on("click", function() {
        UI.Dialog.instance().hide();
    });

    $tracklist = $("#tracklist tbody");
    // preload image to avoid flickering
    $("<img/>").attr("src", "../../../static/images/icons/add.png");

    RE.releaseViewModel.entity = RE.Entity({type: "release", gid: releaseGID});

    ko.applyBindings(RE.releaseViewModel, document.getElementById("content"));

    if (data) {
        releaseLoaded(data);
    } else {
        var url = "/ws/js/release/" + releaseGID + "?inc=recordings+rels",
            $loading = $(UI.loadingIndicator).insertAfter("#tracklist");

        $.getJSON(url, function(data) {
            releaseLoaded(data);
            $loading.remove();
        });
    }
};


releaseLoaded = function(data) {
    data.type = "release";
    RE.Entity(data);
    var trackCount = 0;

    var media = data.mediums;
    for (var i = 0; i < media.length; i++)
        trackCount += parseMedium(media[i], RE.releaseViewModel.media, data);

    Util.parseRelationships(data, true);

    initButtons();
    initCheckboxes(trackCount);
};


UI.loadingIndicator =
    '<span class="loading">' +
        '<img src="../../../static/images/icons/loading.gif" class="bottom"/> ' +
         MB.text.Loading +
    '</span>';


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
        recording.artistCredit = renderArtistCredit(track.artist_credit);

    Util.parseRelationships(recording, true);
    medium.recordings.push(RE.Entity(recording));
};


RE.createWorks = function(works, editNote, success, error) {
    var fields = {};

    _.each(works, function(work, i) {
        var prefix = ["create-works", "works", i, ""].join(".");
        fields[prefix + "name"] = _.clean(work.name);
        fields[prefix + "comment"] = _.clean(work.comment);
        fields[prefix + "type_id"] = work.type;
        fields[prefix + "language_id"] = work.language;
    });

    fields["create-works.edit_note"] = _.trim(editNote);
    $.post("/relationship-editor/create-works", fields).success(success).error(error);
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
        checkboxes = RE.releaseViewModel.checkboxes;

    // get translated strings for the checkboxes
    function getPlurals(singular, plural, max, name) {

        var url = "/ws/js/plurals?singular=" + encodeURIComponent(singular) +
                  "&plural=" + encodeURIComponent(plural) + "&max=" + max;

        $.getJSON(url, function(data) {
            checkboxes[name](data.strings);
        });
    }
    getPlurals("{n} recording selected", "{n} recordings selected", trackCount, "recordingStrings");
    getPlurals("{n} work selected", "{n} works selected", Math.max(10, Math.min(trackCount * 2, 100)), "workStrings");

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

    $("#content").on("click", "span.add-rel", function(event) {
        UI.AddDialog.show({source: ko.dataFor(this), target: Util.tempEntity("artist")}, event.pageX, event.pageY);
    });

    $("#content").on("click", "span.relate-work", function() {
        UI.AddDialog.show({source: ko.dataFor(this), target: Util.tempEntity("work")});
    });

    $("#content").on("click", "span.remove-button", function() {
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

    $("#content").on("click", "span.link-phrase", function(event) {
        var relationship = ko.dataFor(this);

        if (relationship.action() != "remove")
            UI.EditDialog.show(relationship, event.pageX, event.pageY);
    });
}


function renderArtistCredit(obj) {
    var html = "", name;
    for (var i = 0; name = obj[i]; i++)
        html += RE.Entity(name.artist, "artist").rendering() + name.joinphrase;
    return html;
}

return RE;

}(MB.RelationshipEditor || {}));
