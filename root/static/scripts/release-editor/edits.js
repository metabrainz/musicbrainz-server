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
                if (!newLabel.label && !newLabel.catalog_number) {
                    return;
                }
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

                if (!newLabel || !(newLabel.label || newLabel.catalog_number)) {
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

            // oldPositions are the original positions for all the original
            // mediums (as they exist in the database). newPositions are all
            // the new positions for the new mediums (as they exist on the
            // page). tmpPositions stores any positions we use to avoid
            // conflicts between oldPositions/newPositions.

            var oldPositions = _.pluck(release.mediums.original, "position");
            var newPositions = newMediums().invoke("position").value();
            var tmpPositions = [];

            newMediums().each(function (medium) {
                var newMediumData = MB.edit.fields.medium(medium);
                var oldMediumData = medium.original();

                _.each(medium.tracks(), function (track, i) {
                    var trackData = newMediumData.tracklist[i];
                    var newRecording = track.recording();

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

                            var oldRecording = track.recording.savedEditData;

                            if (!_.isEqual(newRecording, oldRecording)) {
                                edits.push(MB.edit.recordingEdit(newRecording, oldRecording));
                            }
                        }
                    }
                });

                // The medium already exists
                newMediumData = _.cloneDeep(newMediumData);

                if (medium.id) {
                    var newNoPosition = _.omit(newMediumData, "position");
                    var oldNoPosition = _.omit(oldMediumData, "position");

                    if (!_.isEqual(newNoPosition, oldNoPosition)) {
                        newNoPosition.to_edit = medium.id;
                        edits.push(MB.edit.mediumEdit(newNoPosition, oldNoPosition));
                    }
                }
                else if (medium.hasTracks()) {
                    // With regards to the medium position, make sure that:
                    //
                    //  (1) The position doesn't conflict with an existing
                    //      medium as present in the database. If it does,
                    //      pick a position that doesn't and enter a reorder
                    //      edit.
                    //
                    //  (2) The position doesn't conflict with the new
                    //      position of any moved medium, unless they swap.

                    var newPosition = newMediumData.position;

                    if (_.contains(oldPositions, newPosition)) {
                        var lastAttempt = (_.last(tmpPositions) + 1) || 1;
                        var attempt;

                        while (attempt = lastAttempt++) {
                            if (_.contains(oldPositions, attempt) ||
                                _.contains(tmpPositions, attempt)) {
                                // This position is taken.
                                continue;
                            }

                            if (_.contains(newPositions, attempt)) {
                                // Another medium is being moved to the
                                // position we want. Avoid this *unless* we're
                                // swapping with that medium.

                                var possibleSwap = newMediums().find(
                                    function (other) {
                                        return other.position() === attempt;
                                    }
                                );

                                if (possibleSwap.original().position === newPosition) {
                                    break;
                                }

                                continue;
                            }

                            break;
                        }

                        tmpPositions.push(attempt);
                        newMediumData.position = attempt;
                        medium.tmpPosition = attempt;
                    } else {
                        // The medium may have been moved again.
                        delete medium.tmpPosition;
                    }

                    newMediumData.release = release.id;
                    edits.push(MB.edit.mediumCreate(newMediumData))
                }
            });

            _(release.mediums.original).pluck("id").difference(newMediumsIDs)
                .each(function (id) {
                    edits.push(MB.edit.mediumDelete({ medium: id }));
                });

            return edits;
        },

        mediumReorder: function (release) {
            var edits = [];
            var newOrder = [];

            newMediums().each(function (medium) {
                var newPosition = medium.position();

                var oldPosition = medium.tmpPosition || (
                    medium.id ? medium.original().position : newPosition
                );

                if (oldPosition !== newPosition) {
                    newOrder.push({
                        medium_id:  medium.id,
                        "old":      oldPosition,
                        "new":      newPosition
                    });
                }
            });

            if (newOrder.length) {
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
                var toc = medium.toc();

                if (toc && medium.canHaveDiscID()) {
                    edits.push(
                        MB.edit.mediumAddDiscID({
                            medium_id:          medium.id,
                            medium_position:    medium.position(),
                            release:            release.id,
                            release_name:       release.name(),
                            cdtoc:              toc
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
                releaseEditor.edits.mediumReorder(release),
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
                    if (data && current.callback) {
                        current.callback(release, data.edits);
                    }

                    _.defer(nextSubmission);
                })
                .fail(submissionErrorOccurred);
        }
        nextSubmission();
    }


    function submissionErrorOccurred(data) {
        var error;

        try {
            error = JSON.parse(data.responseText).error;
        } catch (e) {
            error = data.statusText + ": " + data.status;
        }

        releaseEditor.submissionError(error);
        releaseEditor.submissionInProgress(false);
    }


    releaseEditor.orderedEditSubmissions = [
        {
            edits: releaseEditor.edits.releaseGroup,

            callback: function (release, edits) {
                release.releaseGroup(
                    releaseEditor.fields.ReleaseGroup(edits[0].entity)
                );
            }
        },
        {
            edits: releaseEditor.edits.release,

            callback: function (release, edits) {
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

            callback: function (release, edits) {
                release.labels.original(
                    _.map(release.labels.peek(), function (label) {
                        var newData = _.where(edits, {
                            entity: {
                                labelID: label.label().id || null,
                                catalogNumber: label.catalogNumber() || null
                            }
                        });

                        if (newData) {
                            label.id = newData.id;
                        }
                        return MB.edit.fields.releaseLabel(label);
                    })
                );
            }
        },
        {
            edits: releaseEditor.edits.medium,

            callback: function (release, edits) {
                var added = _(edits).pluck("entity").compact()
                                    .indexBy("position").value();

                newMediums().each(function (medium) {
                    var addedData = added[medium.tmpPosition || medium.position()];

                    if (addedData) {
                        medium.id = addedData.id;
                    }

                    var currentData = MB.edit.fields.medium(medium);

                    // mediumReorder edits haven't been submitted yet,
                    // so we must keep the old position.
                    currentData.position = medium.original().position;

                    medium.original(currentData);
                });

                newMediums.notifySubscribers(newMediums());
            }
        },
        {
            edits: releaseEditor.edits.mediumReorder
        },
        {
            edits: releaseEditor.edits.discID,

            callback: function (release) {
                newMediums().invoke("toc", null);
            }
        },
        {
            edits: releaseEditor.edits.annotation,

            callback: function (release) {
                release.annotation.original(release.annotation());
            }
        },
        {
            edits: releaseEditor.edits.externalLinks
        }
    ];


    releaseEditor.submitEdits = function () {
        if (releaseEditor.submissionInProgress() ||
            releaseEditor.validation.errorCount() > 0) {
            return;
        }

        releaseEditor.submissionInProgress(true);
        var release = releaseField();

        chainEditSubmissions(release, releaseEditor.orderedEditSubmissions);
    };

}(MB.releaseEditor = MB.releaseEditor || {}));
