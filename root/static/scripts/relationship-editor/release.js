// This file is part of MusicBrainz, the open internet music database.
// Copyright (C) 2014 MetaBrainz Foundation
// Licensed under the GPL version 2, or (at your option) any later version:
// http://www.gnu.org/licenses/gpl-2.0.txt

const i18n = require('../common/i18n');
const request = require('../common/utility/request');

(function (RE) {

    var UI = RE.UI = RE.UI || {};


    RE.ReleaseViewModel = aclass(RE.ViewModel, {

        after$init: function (options) {
            MB.releaseRelationshipEditor = this;

            this.editNote = ko.observable("");
            this.makeVotable = ko.observable(false);

            this.submissionLoading = ko.observable(false);
            this.submissionError = ko.observable("");

            var self = this;

            this.checkboxes = {
                recordingCount: ko.observable(0),
                workCount: ko.observable(0),

                recordingMessage: function () {
                    var n = this.recordingCount();
                    return "(" + i18n.ln("{n} recording selected", "{n} recordings selected", n, { n: n }) + ")";
                },

                workMessage: function () {
                    var n = this.workCount();
                    return "(" + i18n.ln("{n} work selected", "{n} works selected", n, { n: n }) + ")";
                }
            };

            this.source = MB.entity(options.sourceData);
            this.source.parseRelationships(options.sourceData.relationships);

            this.source.releaseGroup.parseRelationships(
                options.sourceData.releaseGroup.relationships
            );

            this.source.mediums = ko.observableArray([]);
            this.loadingRelease = ko.observable(false);

            ko.applyBindings(this, document.getElementById("content"));

            this.loadingRelease(true);
            var url = "/ws/js/release/" + this.source.gid + "?inc=rels+recordings";
            request({ url: url }, this)
                .done(this.releaseLoaded)
                .always(function () {
                    self.loadingRelease(false);
                });

            window.addEventListener('beforeunload', function (event) {
                if (self.redirecting) {
                    return;
                }
                var $changes = $(".link-phrase")
                    .filter(".rel-edit:eq(0), .rel-add:eq(0), .rel-remove:eq(0)");

                if ($changes.length) {
                    event.returnValue = i18n.l("All of your changes will be lost if you leave this page.");
                    return event.returnValue;
                }
            });
        },

        getEdits: function (addChanged) {
            var self = this;
            var release = this.source;

            _.each(release.mediums(), function (medium) {
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

            _.each(release.relationships(), function (r) {
                addChanged(r, release);
            });

            var rg = release.releaseGroup;
            _.each(rg.relationships(), function (r) {
                addChanged(r, rg);
            });
        },

        submit: function (data, event) {
            event.preventDefault();

            var self = this;
            var edits = [];
            var alreadyAdded = {};

            this.submissionLoading(true);

            function addChanged(relationship, source) {
                if (alreadyAdded[relationship.uniqueID]) {
                    return;
                }
                if (self !== relationship.parent) {
                    return;
                }
                alreadyAdded[relationship.uniqueID] = true;

                var editData = relationship.editData();

                if (relationship.added()) {
                    edits.push(MB.edit.relationshipCreate(editData));
                }
                else if (relationship.edited()) {
                    edits.push(MB.edit.relationshipEdit(editData, relationship.original, relationship));
                }
                else if (relationship.removed()) {
                    edits.push(MB.edit.relationshipDelete(editData));
                }
            }

            this.getEdits(addChanged);

            if (edits.length == 0) {
                this.submissionLoading(false);
                this.submissionError(i18n.l("You haven’t made any changes!"));
                return;
            }

            var data = {
                editNote: this.editNote(),
                makeVotable: this.makeVotable(),
                edits: edits
            };

            MB.edit.create(data, this)
                .always(function () {
                    this.submissionLoading(false);
                })
                .done(this.submissionDone)
                .fail(function (jqXHR) {
                    try {
                        var response = JSON.parse(jqXHR.responseText);
                        var message = _.isObject(response.error) ?
                                        response.error.message : response.error;

                        this.submissionError(message);
                    }
                    catch (e) {
                        this.submissionError(jqXHR.responseText);
                    }
                });
        },

        submissionDone: function () {
            this.redirecting = true;
            window.location.replace("/release/" + this.source.gid);
        },

        releaseLoaded: function (data) {
            var release = this.source;

            release.mediums(_.map(data.mediums, function (mediumData) {
                _.each(mediumData.tracks, function (trackData) {
                    MB.entity(trackData.recording).parseRelationships(
                        trackData.recording.relationships
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
