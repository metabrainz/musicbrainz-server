// This file is part of MusicBrainz, the open internet music database.
// Copyright (C) 2014 MetaBrainz Foundation
// Licensed under the GPL version 2, or (at your option) any later version:
// http://www.gnu.org/licenses/gpl-2.0.txt

(function (RE) {

    var UI = RE.UI = RE.UI || {};


    RE.ReleaseViewModel = aclass(RE.GenericEntityViewModel, {

        after$init: function (options) {
            var self = this;

            this.checkboxes = {
                recordingCount: ko.observable(0),
                workCount: ko.observable(0),

                recordingMessage: function () {
                    var n = this.recordingCount();
                    return "(" + MB.i18n.ln("{n} recording selected", "{n} recordings selected", n, { n: n }) + ")";
                },

                workMessage: function () {
                    var n = this.workCount();
                    return "(" + MB.i18n.ln("{n} work selected", "{n} works selected", n, { n: n }) + ")";
                }
            };

            this.source.releaseGroup.parseRelationships(
                options.sourceData.releaseGroup.relationships, this
            );

            this.source.mediums = ko.observableArray([]);
            this.loadingRelease = ko.observable(false);

            ko.applyBindings(this, document.getElementById("content"));

            this.loadingRelease(true);
            var url = "/ws/js/release/" + this.source.gid + "?inc=rels+media+recordings";
            MB.utility.request({ url: url }, this)
                .done(this.releaseLoaded)
                .always(function () {
                    self.loadingRelease(false);
                });

            window.onbeforeunload = function () {
                var $changes = $(".link-phrase")
                    .filter(".rel-edit:eq(0), .rel-add:eq(0), .rel-remove:eq(0)");

                if ($changes.length) {
                    return MB.i18n.l("All of your changes will be lost if you leave this page.");
                }
            };
        },

        after$getEdits: function (addChanged) {
            var self = this;

            _.each(this.source.mediums(), function (medium) {
                _.each(medium.tracks, function (track) {
                    var recording = track.recording;

                    _.each(recording.relationships(), function (r) {
                        addChanged(r, recording);

                        if (r.entityTypes === "recording-work") {
                            var work = r.entities()[1];

                            _.each(work.relationships(), function (r) {
                                addChanged(r, work);
                            });
                        }
                    });
                });
            });

            var rg = this.source.releaseGroup;
            _.each(rg.relationships(), function (r) {
                addChanged(r, rg);
            });
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

            var trackCount = _.reduce(release.mediums(),
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
        },

        _sortedRelationships: function (relationships, source) {
            var self = this;

            return relationships.filter(function (relationship) {
                return relationship.entityTypes !== "recording-work";

            }).sortBy(function (relationship) {
                return relationship.lowerCaseTargetName(source);

            }).sortBy("linkOrder").sortBy(function (relationship) {
                return relationship.lowerCasePhrase(source);
            });
        },

        _acceptedTypes: ["release", "release_group", "recording", "work"],

        typesAreAccepted: function (sourceType, targetType) {
            return targetType !== "url" && _.contains(this._acceptedTypes, sourceType);
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
