// This file is part of MusicBrainz, the open internet music database.
// Copyright (C) 2014 MetaBrainz Foundation
// Licensed under the GPL version 2, or (at your option) any later version:
// http://www.gnu.org/licenses/gpl-2.0.txt

(function (releaseEditor) {

    var utils = releaseEditor.utils;
    var releaseField = ko.observable().subscribeTo("releaseField", true);


    var releaseEditData = utils.withRelease(MB.edit.fields.release);

    var newMediums = utils.withRelease(function (release) {
        return _(release.mediums());
    }, []);


    releaseEditor.edits = {

        releaseGroup: function (release) {
            var releaseGroup = release.releaseGroup();
            var releaseName = release.name();

            if (releaseGroup.id || !(releaseGroup.name || releaseName)) return [];

            var editData = MB.edit.fields.releaseGroup(releaseGroup);
            editData.name = editData.name || releaseName;
            editData.artist_credit = MB.edit.fields.artistCredit(release.artistCredit);

            return [ MB.edit.releaseGroupCreate(editData) ];
        },

        release: function (release) {
            if (!release.name() && !release.artistCredit.text()) return [];

            var newData = releaseEditData();
            var oldData = release.original();
            var edits = [];

            if (!release.id) {
                edits.push(MB.edit.releaseCreate(newData));
            }
            else if (!_.isEqual(newData, oldData)) {
                newData = _.extend(_.clone(newData), { to_edit: release.id });
                edits.push(MB.edit.releaseEdit(newData, oldData));
            }
            return edits;
        },

        annotation: function (release) {
            var editData = MB.edit.fields.annotation(release);
            var edits = [];

            if (editData.text !== release.annotation.original()) {
                edits.push(MB.edit.releaseAddAnnotation(editData));
            }
            return edits;
        },

        releaseLabel: function (release) {
            var newLabels = _.map(release.labels(), MB.edit.fields.releaseLabel);
            var oldLabels = release.labels.original();

            var newLabelsByID = _.indexBy(newLabels, "release_label");
            var oldLabelsByID = _.indexBy(oldLabels, "release_label");

            var edits = [];

            _.each(newLabels, function (newLabel) {
                var id = newLabel.release_label;

                if (id) {
                    var oldLabel = oldLabelsByID[id];

                    if (oldLabel && !_.isEqual(newLabel, oldLabel)) {
                        // Edit ReleaseLabel
                        edits.push(MB.edit.releaseEditReleaseLabel(newLabel));
                    }
                } else {
                    // Add ReleaseLabel
                    newLabel = _.clone(newLabel);

                    if (newLabel.label || newLabel.catalog_number) {
                        newLabel.release = release.id || null;
                        edits.push(MB.edit.releaseAddReleaseLabel(newLabel));
                    }
                }
            });

            _.each(oldLabels, function (oldLabel) {
                var id = oldLabel.release_label;
                var newLabel = newLabelsByID[id];

                if (!newLabel) {
                    // Delete ReleaseLabel
                    oldLabel = _.omit(oldLabel, "label", "catalogNumber");
                    edits.push(MB.edit.releaseDeleteReleaseLabel(oldLabel));
                }
            });

            return edits;
        },

        medium: function (release) {
            var newMediumsIDs = newMediums().pluck("id").compact().value();
            var newOrder = [];
            var edits = [];
            var inferTrackDurations = releaseEditor.inferTrackDurationsFromRecordings();

            newMediums().each(function (medium) {
                if (!medium.loaded()) return;
                if (!medium.formatID() && !medium.hasTracks()) return;

                var newMediumData = MB.edit.fields.medium(medium);
                var oldMediumData = medium.original && medium.original();

                _.each(medium.tracks(), function (track, i) {
                    var trackData = newMediumData.tracklist[i];
                    var newRecording = track.recording();
                    var oldRecording = track.recording.original();

                    if (newRecording) {
                        newRecording = MB.edit.fields.recording(newRecording);

                        if (inferTrackDurations) {
                            trackData.length = newRecording.length || trackData.length;
                        }

                        if (track.updateRecording() && track.differsFromRecording()) {
                            _.extend(newRecording, {
                                name:           trackData.name,
                                artist_credit:  trackData.artist_credit,
                                length:         trackData.length
                            });

                            if (!_.isEqual(newRecording, oldRecording)) {
                                edits.push(MB.edit.recordingEdit(newRecording));
                            }
                        }
                    }
                });

                // The medium already exists
                newMediumData = _.clone(newMediumData);

                if (medium.id) {
                    if (_.isEqual(newMediumData, oldMediumData)) {
                        return;
                    }
                    newOrder.push({
                        medium_id:  medium.id,
                        "old":      oldMediumData.position,
                        "new":      newMediumData.position
                    });

                    newMediumData.to_edit = medium.id;
                    delete newMediumData.position;
                    edits.push(MB.edit.mediumEdit(newMediumData, oldMediumData));
                }
                else {
                    newMediumData.release = release.id;
                    edits.push(MB.edit.mediumCreate(newMediumData))
                }
            });

            _(release.mediums.originalIDs).difference(newMediumsIDs)
                .each(function (id) {
                    edits.push(MB.edit.mediumDelete({ medium: id }));
                });

            var wasReordered = _.any(newOrder, function (order) {
                return order["old"] !== order["new"];
            });

            if (wasReordered) {
                edits.push(
                    MB.edit.releaseReorderMediums({
                        release: release.id,
                        medium_positions: newOrder
                    })
                );
            }

            return edits;
        },

        discID: function (release) {
            var edits = [];

            newMediums().each(function (medium) {
                if (medium.toc && medium.canHaveDiscID()) {
                    edits.push(
                        MB.edit.mediumAddDiscID({
                            medium_id:  medium.id,
                            release:    release.id,
                            cdtoc:      medium.toc
                        })
                    );
                }
            });
            return edits;
        },

        externalLinks: function (release) {
            var edits = [];

            _(release.externalLinks.links()).each(function (link) {
                link.entity0ID(release.gid || "");

                if (!link.linkTypeID() || !link.url() || link.error()) {
                    return;
                }

                var editData = MB.edit.fields.relationship(link);
                if (release.gid) delete editData.entity0Preview;

                if (link.removed()) {
                    edits.push(MB.edit.relationshipDelete(editData));
                }
                else if (link.id) {
                    if (!_.isEqual(editData, link.original)) {
                        edits.push(MB.edit.relationshipEdit(editData, link.original));
                    }
                }
                else {
                    edits.push(MB.edit.relationshipCreate(editData));
                }
            });

            return edits;
        }
    };


    releaseEditor.allEdits = utils.debounce(
        utils.withRelease(function (release) {
            var root = releaseEditor.rootField;

            return Array.prototype.concat(
                releaseEditor.edits.releaseGroup(release),
                releaseEditor.edits.release(release),
                releaseEditor.edits.releaseLabel(release),
                releaseEditor.edits.medium(release),
                releaseEditor.edits.discID(release),
                releaseEditor.edits.annotation(release),
                releaseEditor.edits.externalLinks(release)
            );
        }, []),
        1500
    );


    releaseEditor.editPreviews = ko.observableArray([]);
    releaseEditor.loadingEditPreviews = ko.observable(false);


    releaseEditor.getEditPreviews = function () {
        var previews = {};

        function refreshPreviews(edits) {
            releaseEditor.editPreviews(_.compact(_.map(edits, getPreview)));
        }

        function getPreview(edit) { return previews[edit.hash] }
        function addPreview(tuple) { previews[tuple[0].hash] = tuple[1] }
        function isNewEdit(edit) { return previews[edit.hash] === undefined }

        ko.computed(function () {
            var edits = releaseEditor.allEdits();

            // Don't generate edit previews if there are errors, *unless*
            // having a missing edit note is the only error. However, do
            // remove stale previews that may reference changed data.
            if (releaseEditor.validation.errorsExistOtherThanAMissingEditNote()) {
                refreshPreviews([]);
                return;
            }

            var addedEdits = _.filter(edits, isNewEdit);

            if (addedEdits.length === 0) {
                refreshPreviews(edits);
                return;
            }

            releaseEditor.loadingEditPreviews(true);

            MB.edit.preview({ edits: addedEdits })
                .done(function (data) {
                    _.each(_.zip(addedEdits, data.previews), addPreview);

                    refreshPreviews(edits);
                })
                .always(function () {
                    releaseEditor.loadingEditPreviews(false);
                });
        });
    };


    releaseEditor.submissionInProgress = ko.observable(false);
    releaseEditor.submissionError = ko.observable();


    function chainEditSubmissions(release, submissions) {
        var root = releaseEditor.rootField;

        var args = {
            as_auto_editor: root.asAutoEditor(),
            edit_note: root.editNote()
        };

        function nextSubmission() {
            var current = submissions.shift();

            if (!current) {
                // We're done!

                // Don't ask for confirmation before redirecting.
                window.onbeforeunload = null;

                if (releaseEditor.redirectURI) {
                    var a = document.createElement("a");
                    a.href = releaseEditor.redirectURI;

                    a.search += /^\?/.test(a.search) ? "&" : "?";
                    a.search += "release_mbid=" + release.gid;

                    window.location.href = a.href;
                } else {
                    window.location.pathname = "/release/" + release.gid;
                }
                return;
            }

            var edits = current.edits(release),
                submitted = null;

            if (edits.length) {
                submitted = MB.edit.create($.extend({ edits: edits }, args));
            }

            $.when(submitted)
                .done(function (data) {
                    data && current.callback && current.callback(data.edits);

                    _.defer(nextSubmission);
                })
                .fail(submissionErrorOccurred);
        }
        nextSubmission();
    }


    function submissionErrorOccurred(data) {
        var response = JSON.parse(data.responseText);

        releaseEditor.submissionError(response.error);
        releaseEditor.submissionInProgress(false);
    }


    releaseEditor.submitEdits = function () {
        if (releaseEditor.submissionInProgress() ||
            releaseEditor.validation.errorCount() > 0) {
            return;
        }

        releaseEditor.submissionInProgress(true);
        var release = releaseField();

        chainEditSubmissions(release, [
            {
                edits: releaseEditor.edits.releaseGroup,

                callback: function (edits) {
                    release.releaseGroup(
                        releaseEditor.fields.ReleaseGroup(edits[0].entity)
                    );
                }
            },
            {
                edits: releaseEditor.edits.release,

                callback: function (edits) {
                    var entity = edits[0].entity;

                    if (entity) {
                        release.id = entity.id;
                        release.gid = entity.gid;
                    }

                    release.original(MB.edit.fields.release(release));
                    releaseField.notifySubscribers(release);
                }
            },
            {
                edits: releaseEditor.edits.releaseLabel,

                callback: function () {
                    release.labels.original(
                        _.map(release.labels.peek(), MB.edit.fields.releaseLabel)
                    );
                }
            },
            {
                edits: releaseEditor.edits.medium,

                callback: function (edits) {
                    var added = _(edits).pluck("entity").compact()
                                    .indexBy("position").value();

                    newMediums().each(function (medium) {
                        var addedData = added[medium.position()];

                        if (addedData) medium.id = addedData.id;

                        medium.original(MB.edit.fields.medium(medium));
                    });

                    newMediums.notifySubscribers(newMediums());
                }
            },
            {
                edits: releaseEditor.edits.discID,

                callback: function () {
                    newMediums().each(function (medium) { delete medium.toc });

                    newMediums.notifySubscribers(newMediums());
                }
            },
            {
                edits: releaseEditor.edits.annotation,

                callback: function () {
                    release.annotation.original(release.annotation());
                }
            },
            {
                edits: releaseEditor.edits.externalLinks
            }
        ]);
    };

}(MB.releaseEditor = MB.releaseEditor || {}));
