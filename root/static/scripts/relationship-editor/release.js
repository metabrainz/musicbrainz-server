// This file is part of MusicBrainz, the open internet music database.
// Copyright (C) 2014 MetaBrainz Foundation
// Licensed under the GPL version 2, or (at your option) any later version:
// http://www.gnu.org/licenses/gpl-2.0.txt

(function (RE) {

    var UI = RE.UI = RE.UI || {};


    RE.ReleaseViewModel = aclass(RE.GenericEntityViewModel, {

        reject: /url|work-recording/,

        after$init: function (options) {
            var self = this;

            this.checkboxes = {
                recordingStrings: ko.observable([]),
                workStrings: ko.observable([]),

                recordingCount: ko.observable(0),
                workCount: ko.observable(0),

                recordingMessage: function () {
                    var strings = this.recordingStrings();
                    var msg = strings[Math.min(strings.length - 1, this.recordingCount())];

                    return msg ? "(" + msg + ")" : "";
                },

                workMessage: function () {
                    var strings = this.workStrings();
                    var msg = strings[Math.min(strings.length - 1, this.workCount())];

                    return msg ? "(" + msg + ")" : "";
                }
            };

            this.source.releaseGroup.parseRelationships(
                options.sourceData.releaseGroup.relationships, this
            );

            this.source.mediums = ko.observableArray([]);

            MB.entity.Recording.around("displayRelationships", function (supr, vm) {
                return _.difference(supr(vm), this.performances());
            });

            MB.entity.Work.around("displayRelationships", function (supr, vm) {
                return _.reject(supr(vm), { entityTypes: "recording-work" });
            });

            ko.applyBindings(this, document.getElementById("content"));

            var gid = this.source.gid;
            var url = "/ws/js/release/" + gid + "?inc=rels+media+recordings";

            MB.utility.request({ url: url }, this)
                .done(this.releaseLoaded)
                .done(function () {
                    ko.computed(function () {
                        var hasChanges = self.hasChanges(self.source);

                        window.onbeforeunload = hasChanges ?
                            _.constant(MB.text.ConfirmNavigation) : undefined;
                    });
                });
        },

        around$hasChanges: function (supr, entity) {
            return supr(entity) || entity.releaseGroup.changedRelationships(this).length > 0;
        },

        after$getEdits: function (addChanged) {
            _.each(this.source.releaseGroup.changedRelationships(this), addChanged);
        },

        submissionDone: function () {
            window.location.replace("/release/" + this.source.gid);
        },

        releaseLoaded: function (data) {
            var self = this;
            var release = this.source;

            release.mediums(_.map(data.mediums, function (mediumData) {
                _.each(mediumData.tracks, function (trackData) {
                    MB.entity(trackData.recording).parseRelationships(
                        trackData.recording.relationships, self
                    );
                });
                return MB.entity.Medium(mediumData, release);
            }));

            var trackCount = _.reduce(release.mediums,
                function (memo, medium) { return memo + medium.tracks.length }, 0);

            initCheckboxes(this.checkboxes, trackCount);
        },

        openAddDialog: function (source, event) {
            UI.AddDialog({
                source: source,
                target: MB.entity.Artist({}),
                viewModel: this
            }).open(event.target);
        },

        openEditDialog: function (relationship, event) {
            if (!relationship.removed()) {
                UI.EditDialog({
                    relationship: relationship,
                    source: ko.contextFor(event.target).$parent,
                    viewModel: this
                }).open(event.target);
            }
        },

        openBatchRecordingsDialog: function () {
            var sources = UI.checkedRecordings();

            if (sources.length > 0) {
                UI.BatchRelationshipDialog({ sources: sources, viewModel: this }).open();
            }
        },

        openBatchWorksDialog: function () {
            var sources = UI.checkedWorks();

            if (sources.length > 0) {
                UI.BatchRelationshipDialog({ sources: sources, viewModel: this }).open();
            }
        },

        openBatchCreateWorksDialog: function () {
            var sources = _.filter(UI.checkedRecordings(), function (recording) {
                return recording.performances().length === 0;
            });

            if (sources.length > 0) {
                UI.BatchCreateWorksDialog({ sources: sources, viewModel: this }).open();
            }
        },

        openRelateToWorkDialog: function (track) {
            var source = track.recording;
            var target = MB.entity.Work({ name: source.name });

            UI.AddDialog({
                source: source,
                target: target,
                viewModel: this
            }).open();
        },

        after$removeRelationship: function (relationship, event) {
            if (relationship.added()) {
                $(event.target)
                    .parent()
                    .children("input[type=checkbox]:checked")
                    .prop("checked", false)
                    .click();
            }
        }
    });


    var recordingCheckboxes = "td.recording > input[type=checkbox]";
    var workCheckboxes = "td.works > div.ar > input[type=checkbox]";


    UI.checkedRecordings = function () {
        return $.map($(recordingCheckboxes + ":checked", "#tracklist"), ko.dataFor);
    };


    UI.checkedWorks = function () {
        return $.map($(workCheckboxes + ":checked", "#tracklist"), ko.dataFor);
    };


    function initCheckboxes(checkboxes, trackCount) {

        var medium_recording_selector = "input.medium-recordings";
        var medium_work_selector = "input.medium-works";
        var $tracklist = $("#tracklist tbody");

        // get translated strings for the checkboxes
        function getPlurals(singular, plural, max, name) {

            var url = "/ws/js/plurals?singular=" + encodeURIComponent(singular) +
                      "&plural=" + encodeURIComponent(plural) + "&max=" + max;

            $.getJSON(url, function (data) {
                checkboxes[name](data.strings);
            });
        }
        getPlurals("{n} recording selected", "{n} recordings selected", trackCount, "recordingStrings");
        getPlurals("{n} work selected", "{n} works selected", Math.max(10, Math.min(trackCount * 2, 100)), "workStrings");

        function count($inputs) {
            return _.uniq($inputs, ko.dataFor).length;
        }

        function medium(medium_selector, selector, counter) {
            $tracklist.on("change", medium_selector, function (event) {
                var checked = this.checked,
                    $changed = $(this).parents("tr.subh").nextUntil("tr.subh")
                        .find(selector).filter(checked ? ":not(:checked)" : ":checked")
                        .prop("checked", checked);
                counter(counter() + count($changed) * (checked ? 1 : -1));
            });
        }

        function _release(medium_selector, cls) {
            $('<input type="checkbox"/>&#160;')
                .change(function (event) {
                    $tracklist.find(medium_selector)
                        .prop("checked", this.checked).change();
                })
                .prependTo("#tracklist th." + cls);
        }

        function range(selector, counter) {
            var last_clicked = null;

            $tracklist.on("click", selector, function (event) {
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

        medium(medium_recording_selector, recordingCheckboxes, checkboxes.recordingCount);
        medium(medium_work_selector, workCheckboxes, checkboxes.workCount);

        _release(medium_recording_selector, "recordings");
        _release(medium_work_selector, "works");

        range(recordingCheckboxes, checkboxes.recordingCount);
        range(workCheckboxes, checkboxes.workCount);
    }

}(MB.relationshipEditor = MB.relationshipEditor || {}));
