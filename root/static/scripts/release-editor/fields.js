// This file is part of MusicBrainz, the open internet music database.
// Copyright (C) 2014 MetaBrainz Foundation
// Licensed under the GPL version 2, or (at your option) any later version:
// http://www.gnu.org/licenses/gpl-2.0.txt

const i18n = require('../common/i18n');
const clean = require('../common/utility/clean');
const formatTrackLength = require('../common/utility/formatTrackLength');
const request = require('../common/utility/request');
const dates = require('../edit/utility/dates');
const validation = require('../edit/validation');

(function (releaseEditor) {

    var fields = releaseEditor.fields = releaseEditor.fields || {};
    var utils = releaseEditor.utils;


    fields.ArtistCredit = aclass(MB.Control.ArtistCredit, {

        around$init: function (supr, data) {
            supr({ initialData: data });
        }
    });


    fields.Track = aclass({

        init: function (data, medium) {
            this.medium = medium;

            $.extend(this, _.pick(data, "id", "gid"));

            data.name = data.name || "";
            this.name = ko.observable(data.name);
            this.name.original = data.name;
            this.name.subscribe(this.nameChanged, this);

            this.length = ko.observable(data.length);
            this.length.original = data.length;

            var release = medium && medium.release;

            if (release && !data.artistCredit && !release.artistCredit.isVariousArtists()) {
                data.artistCredit = release.artistCredit.toJSON();
            }

            this.artistCredit = fields.ArtistCredit(data.artistCredit);
            this.artistCredit.track = this;

            this.formattedLength = ko.observable(formatTrackLength(data.length));
            this.position = ko.observable(data.position);
            this.number = ko.observable(data.number);
            this.isDataTrack = ko.observable(!!data.isDataTrack);
            this.hasNewRecording = ko.observable(true);

            this.updateRecordingTitle = ko.observable(releaseEditor.copyTrackTitlesToRecordings());
            this.updateRecordingArtist = ko.observable(releaseEditor.copyTrackArtistsToRecordings());

            releaseEditor.copyTrackTitlesToRecordings.subscribe(this.updateRecordingTitle);
            releaseEditor.copyTrackArtistsToRecordings.subscribe(this.updateRecordingArtist);

            this.recordingValue = ko.observable(
                MB.entity.Recording({ name: data.name })
            );

            // Custom write function is needed around recordingValue because
            // when it's written to there's certain values we need to save
            // beforehand (see methods below).
            this.recording = ko.computed({
                read: this.recordingValue,
                write: this.setRecordingValue,
                owner: this
            });

            this.recording.original = ko.observable();
            this.suggestedRecordings = ko.observableArray([]);
            this.loadingSuggestedRecordings = ko.observable(false);

            var recordingData = data.recording;
            if (recordingData) {
                if (_.isEmpty(recordingData.artistCredit)) {
                    recordingData.artistCredit = this.artistCredit.toJSON();
                }
                this.recording(MB.entity(recordingData, "recording"));
                this.recording.original(MB.edit.fields.recording(this.recording.peek()));
                this.hasNewRecording(false);
            }

            releaseEditor.recordingAssociation.track(this);

            this.uniqueID = this.id || _.uniqueId("new-");
            this.elementID = "track-row-" + this.uniqueID;

            this.formattedLength.subscribe(this.formattedLengthChanged, this);
            this.hasNewRecording.subscribe(this.hasNewRecordingChanged, this);
        },

        recordingGID: function () {
            var recording = this.recording();
            return recording ? recording.gid : null;
        },

        nameChanged: function (name) {
            if (!this.hasExistingRecording()) {
                var recording = this.recording.peek();

                recording.name = this.name();
                this.recording.notifySubscribers(recording);
            }
        },

        formattedLengthChanged: function (length) {
            var lengthLength = length.length;

            // Convert stuff like 111 into 1:11

            if (/^\d+$/.test(length) && (4 - lengthLength) <= 1) {
                var minutes, seconds;

                if (lengthLength === 3) minutes = length[0];
                if (lengthLength === 4) minutes = length.slice(0, 2);

                seconds = length.slice(-2);

                if (parseInt(minutes, 10) < 60 && parseInt(seconds, 10) < 60) {
                    length = minutes + ":" + seconds;
                    this.formattedLength(length);
                }
            }

            var oldLength = this.length();
            var newLength = utils.unformatTrackLength(length);

            if (_.isNaN(newLength)) {
                this.formattedLength('');
                return;
            }

            this.length(newLength);

            var newFormattedLength = formatTrackLength(newLength);
            if (length !== newFormattedLength) {
                this.formattedLength(newFormattedLength);
            }

            // If the length being changed is for a pregap track and the medium
            // has cdtocs attached, make sure the new length doesn't exceed the
            // maximum possible allowed by any of the tocs.

            var $lengthInput = $("input.track-length", "#track-row-" + this.uniqueID);
            $lengthInput.attr("title", "");

            var hasTooltip = !!$lengthInput.data("ui-tooltip");

            if (this.medium.hasInvalidPregapLength()) {
                $lengthInput.attr("title", i18n.l('None of the attached disc IDs can fit a pregap track of the given length.'));

                if (!hasTooltip) {
                    $lengthInput.tooltip();
                }

                $lengthInput.tooltip("open");
            } else if (hasTooltip) {
                $lengthInput.tooltip("close").tooltip("destroy");
            }
        },

        previous: function () {
            var tracks = this.medium.tracks();
            var index = _.indexOf(tracks, this);

            return index > 0 ? tracks[index - 1] : null;
        },

        next: function () {
            var tracks = this.medium.tracks();
            var index = _.indexOf(tracks, this);

            return index < tracks.length - 1 ? tracks[index + 1] : null;
        },

        titleDiffersFromRecording: function () {
            return this.name() !== this.recording().name;
        },

        artistDiffersFromRecording: function () {
            var artistCredit = this.recording().artistCredit;

            if (!artistCredit) {
                return false;
            }

            return !this.artistCredit.isEqual(artistCredit);
        },

        hasExistingRecording: function () {
            return !!this.recording().gid;
        },

        needsRecording: function () {
            return !(this.hasExistingRecording() || this.hasNewRecording());
        },

        hasNewRecordingChanged: function (value) {
            value && this.recording(null);
        },

        setRecordingValue: function (value) {
            value = value || MB.entity.Recording({ name: this.name() });

            var currentValue = this.recording.peek();
            if (value.gid === currentValue.gid) return;

            // Save the current track values to allow for comparison when they
            // change. If they change too much, we unset the recording and find
            // a new suggestion. Only save these if there's a recording to
            // revert back to - it doesn't make sense to save these values for
            // comparison if there's no recording.
            if (value.gid) {
                this.name.saved = this.name.peek();
                this.length.saved = this.length.peek();
                this.recording.saved = value;
                this.recording.savedEditData = MB.edit.fields.recording(value);
                this.hasNewRecording(false);
            }

            if (currentValue.gid) {
                var suggestions = this.suggestedRecordings.peek();

                if (!_.contains(suggestions, currentValue)) {
                    this.suggestedRecordings.unshift(currentValue);
                }
            }

            // Hints for guess-feat. functionality.
            var release = this.medium.release;
            if (release) {
                release.relatedArtists = _.union(release.relatedArtists, value.relatedArtists);
                release.isProbablyClassical = release.isProbablyClassical || value.isProbablyClassical;
            }

            this.recordingValue(value);
        },

        hasNameAndArtist: function () {
            return this.name() && this.artistCredit.isComplete();
        },

        hasVariousArtists: function () {
            return this.artistCredit.isVariousArtists();
        },

        relatedArtists: function () {
            return this.medium.release.relatedArtists;
        },

        isProbablyClassical: function () {
            return this.medium.release.isProbablyClassical;
        }
    });


    fields.Medium = aclass({

        init: function (data, release) {
            this.release = release;
            this.name = ko.observable(data.name);
            this.position = ko.observable(data.position || 1);
            this.formatID = ko.observable(data.formatID);

            var tracks = data.tracks;
            this.tracks = ko.observableArray(utils.mapChild(this, tracks, fields.Track));

            var self = this;

            var hasPregap = ko.computed(function () {
                var tracks = self.tracks();
                return tracks.length > 0 && tracks[0].position() == 0;
            });

            this.hasPregap = ko.computed({
                read: hasPregap,
                write: function (newValue) {
                    var oldValue = hasPregap();

                    if (oldValue && !newValue) {
                        self.tracks.shift();
                    } else if (newValue && !oldValue) {
                        self.tracks.unshift(fields.Track({ position: 0, number: 0 }, self));
                    }
                }
            });

            this.audioTracks = this.tracks.reject("isDataTrack");
            this.dataTracks = this.tracks.filter("isDataTrack");

            var hasDataTracks = ko.computed(function () {
                return self.dataTracks().length > 0;
            });

            this.hasDataTracks = ko.computed({
                read: hasDataTracks,
                write: function (newValue) {
                    var oldValue = hasDataTracks();

                    if (oldValue && !newValue) {
                        var dataTracks = self.dataTracks();

                        if (self.hasToc()) {
                            self.tracks.removeAll(dataTracks);
                        } else {
                            while (dataTracks.length) {
                                dataTracks[0].isDataTrack(false);
                            }
                        }
                    } else if (newValue && !oldValue) {
                        self.pushTrack({ isDataTrack: true });
                    }
                }
            });

            this.needsRecordings = this.tracks.any("needsRecording");
            this.hasTrackInfo = this.tracks.all("hasNameAndArtist");
            this.hasVariousArtistTracks = this.tracks.any("hasVariousArtists");
            this.needsTrackInfo = ko.computed(function () { return !self.hasTrackInfo() });

            $.extend(this, _.pick(data, "id", "originalID"));

            // The medium is considered to be loaded if it has tracks, or if
            // there's no ID to load tracks from.
            var loaded = !!(this.tracks().length || !(this.id || this.originalID));

            if (data.cdtocs) {
                this.cdtocs = data.cdtocs;
            }

            this.toc = ko.observable(data.toc || null);
            this.toc.subscribe(this.tocChanged, this);

            this.hasInvalidFormat = ko.computed(function () {
                return !self.canHaveDiscID() && (self.hasExistingTocs() || hasPregap() || hasDataTracks());
            });

            this.loaded = ko.observable(loaded);
            this.loading = ko.observable(false);
            this.collapsed = ko.observable(!loaded);
            this.collapsed.subscribe(this.collapsedChanged, this);
            this.addTrackCount = ko.observable("");
            this.original = ko.observable(this.id ? MB.edit.fields.medium(this) : {});
            this.uniqueID = this.id || _.uniqueId("new-");

            this.needsTracks = ko.computed(function () {
                return self.loaded() && self.tracks().length === 0;
            });
        },

        pushTrack: function (data) {
            data = data || {};

            if (data.position === undefined) {
                data.position = this.tracks().length + (this.hasPregap() ? 0 : 1);
            }

            if (data.number === undefined) {
                data.number = data.position;
            }

            if (this.hasDataTracks()) {
                data.isDataTrack = true;
            }

            this.tracks.push(fields.Track(data, this));
        },

        hasExistingTocs: function () {
            return !!(this.id && this.cdtocs && this.cdtocs.length);
        },

        hasToc: function () {
            return this.hasExistingTocs() || (this.toc() ? true : false);
        },

        tocChanged: function (toc) {
            if (!_.isString(toc)) return;

            toc = toc.split(/\s+/);

            var tocTrackCount = toc.length - 3;
            var tracks = this.tracks();
            var tocTracks = _.reject(tracks, function (t) { return t.position() == 0 || t.isDataTrack() });
            var trackCount = tocTracks.length;
            var pregapOffset = this.hasPregap() ? 0 : 1;

            var wasConsecutivelyNumbered = _.all(tracks, function (t, index) {
                return t.number() == (index + pregapOffset);
            });

            if (trackCount > tocTrackCount) {
                tocTracks = tocTracks.slice(0, tocTrackCount);

            } else if (trackCount < tocTrackCount) {
                var self = this;

                _.times(tocTrackCount - trackCount, function () {
                    tocTracks.push(fields.Track({}, self));
                });
            }

            this.tracks(
                Array.prototype.concat(
                    this.hasPregap() ? tracks[0] : [],
                    tocTracks,
                    this.dataTracks()
                )
            );

            _.each(tocTracks, function (track, index) {
                track.formattedLength(
                    formatTrackLength(
                        ((toc[index + 4] || toc[2]) - toc[index + 3]) / 75 * 1000
                    )
                );
            });

            _.each(this.tracks(), function (track, index) {
                track.position(pregapOffset + index);

                if (wasConsecutivelyNumbered) {
                    track.number(pregapOffset + index);
                }
            });
        },

        hasInvalidPregapLength: function () {
            if (!this.hasPregap() || !this.hasToc()) {
                return;
            }

            var maxLength = -Infinity;
            var cdtocs = (this.cdtocs || []).concat(this.toc() || []);

            _.each(cdtocs, function (toc) {
                toc = toc.split(/\s+/);
                maxLength = Math.max(maxLength, toc[3] / 75 * 1000);
            });

            return this.tracks()[0].length() > maxLength;
        },

        collapsedChanged: function (collapsed) {
            if (!collapsed && !this.loaded() && !this.loading()) {
                this.loadTracks(true);
            }
        },

        loadTracks: function () {
            var id = this.id || this.originalID;
            if (!id) return;

            this.loading(true);

            var args = {
                url: "/ws/js/medium/" + id,
                data: { inc: "recordings+rels" }
            };

            request(args, this).done(this.tracksLoaded);
        },

        tracksLoaded: function (data) {
            var tracks = data.tracks;

            var pp = this.id ? // no ID means this medium is being reused
                fields.Track :
                function (track, parent) { return fields.Track(_.omit(track, 'id'), parent); };
            this.tracks(utils.mapChild(this, data.tracks, pp));

            if (this.release.seededTocs) {
                var toc = this.release.seededTocs[this.position()];

                if (toc && (toc.split(/\s+/).length - 3) === tracks.length) {
                    this.toc(toc);
                }
            }

            // We already have the original name, format, and position data,
            // which we don't want to overwrite - it could have been changed
            // by the user before they loaded the medium. We just need the
            // tracklist data, now that it's loaded.
            var currentEditData = MB.edit.fields.medium(this);
            var originalEditData = this.original();

            originalEditData.tracklist = currentEditData.tracklist;
            this.original.notifySubscribers(originalEditData);

            this.loaded(true);
            this.loading(false);
            this.collapsed(false);
        },

        hasTracks: function () { return this.tracks().length > 0 },

        formattedName: function () {
            var name = this.name(),
                position = this.position(),
                multidisc = this.release.mediums().length > 1 || position > 1;

            if (name) {
                if (multidisc) {
                    return i18n.l("Medium {position}: {title}", { position: position, title: name });
                }
                return name;

            }
            else if (multidisc) {
                return i18n.l("Medium {position}", { position: position });
            }
            return i18n.l("Tracklist");
        },

        canHaveDiscID: function () {
            var formatID = parseInt(this.formatID(), 10);

            return !formatID || _.contains(MB.formatsWithDiscIDs, formatID);
        }
    });


    fields.ReleaseGroup = aclass(MB.entity.ReleaseGroup, {

        after$init: function (data) {
            data = data || {};

            this.typeID = ko.observable(data.typeID)
            this.secondaryTypeIDs = ko.observableArray(data.secondaryTypeIDs);
        }
    });


    fields.ReleaseEvent = aclass({

        init: function (data, release) {
            var date = dates.parseDate(data.date || "");

            this.date = {
                year:   ko.observable(date.year),
                month:  ko.observable(date.month),
                day:    ko.observable(date.day)
            };

            this.countryID = ko.observable(data.country ? data.country.id : null);
            this.release = release;
            this.isDuplicate = ko.observable(false);

            var self = this;

            this.hasInvalidDate = ko.computed(function () {
                var date = self.unwrapDate();
                return !dates.isDateValid(date.year, date.month, date.day);
            });
        },

        unwrapDate: function () {
            return {
                year: this.date.year(),
                month: this.date.month(),
                day: this.date.day()
            };
        },

        hasAmazonDate: function () {
            var date = this.unwrapDate();
            return date.year == 1990 && date.month == 10 && date.day == 25;
        },

        hasJanuaryFirstDate: function () {
            var date = this.unwrapDate();
            return date.month == 1 && date.day == 1;
        }
    });


    fields.ReleaseLabel = aclass({

        init: function (data, release) {
            if (data.id) this.id = data.id;

            this.label = ko.observable(MB.entity(data.label || {}, "label"));
            this.catalogNumber = ko.observable(data.catalogNumber);
            this.release = release;
            this.isDuplicate = ko.observable(false);

            var self = this;

            this.needsLabel = ko.computed(function () {
                var label = self.label() || {};
                return !!(label.name && !label.gid);
            });
        },

        labelHTML: function () {
            return this.label().html({ target: "_blank" });
        }
    });


    fields.Barcode = aclass({

        weights: [1, 3, 1, 3, 1, 3, 1, 3, 1, 3, 1, 3],

        init: function (data) {
            this.original = data;
            this.barcode = ko.observable(data);
            this.message = ko.observable("");
            this.confirmed = ko.observable(false);
            this.error = validation.errorField(ko.observable(""));

            this.value = ko.computed({
                read: this.barcode,
                write: this.writeBarcode,
                owner: this
            });

            // Always notify of changes, so that when non-digits are stripped,
            // the text in the input element will update even if the stripped
            // value is identical to the old value.
            this.barcode.equalityComparer = null;
            this.value.equalityComparer = null;

            this.none = ko.computed({
                read: function () {
                    return this.barcode() === "";
                },
                write: function (bool) {
                    this.barcode(bool ? "" : null);
                },
                owner: this
            });
        },

        checkDigit: function (barcode) {
            if (barcode.length !== 12) return false;

            for (var i = 0, calc = 0; i < 12; i++) {
                calc += parseInt(barcode[i]) * this.weights[i];
            }

            var digit = 10 - (calc % 10);
            return digit === 10 ? 0 : digit;
        },

        validateCheckDigit: function (barcode) {
            return this.checkDigit(barcode.slice(0, 12)) === parseInt(barcode[12], 10);
        },

        writeBarcode: function (barcode) {
            this.barcode((barcode || "").replace(/[^\d]/g, "") || null);
            this.confirmed(false);
        }
    });


    fields.Release = aclass(MB.entity.Release, {

        after$init: function (data) {
            if (data.gid) {
                MB.entityCache[data.gid] = this; // XXX HACK
            }

            var self = this;
            var errorField = validation.errorField;
            var currentName = data.name;

            this.gid = ko.observable(data.gid);
            this.name = ko.observable(currentName);
            this.needsName = errorField(ko.observable(!currentName));

            this.name.subscribe(function (newName) {
                var releaseGroup = self.releaseGroup();

                if (!releaseGroup.name || (!releaseGroup.gid &&
                                            releaseGroup.name === currentName)) {
                    releaseGroup.name = newName;
                    self.releaseGroup.notifySubscribers(releaseGroup);
                }
                currentName = newName;
                self.needsName(!newName);
            });

            this.artistCredit = fields.ArtistCredit(data.artistCredit);
            this.artistCredit.saved = fields.ArtistCredit(data.artistCredit);

            this.needsArtistCredit = errorField(function () {
                return !self.artistCredit.isComplete();
            });

            this.statusID = ko.observable(data.statusID);
            this.languageID = ko.observable(data.languageID);
            this.scriptID = ko.observable(data.scriptID);
            this.packagingID = ko.observable(data.packagingID);
            this.barcode = fields.Barcode(data.barcode);
            this.comment = ko.observable(data.comment);
            this.annotation = ko.observable(data.annotation || "");
            this.annotation.original = ko.observable(data.annotation || "");

            this.events = ko.observableArray(
                utils.mapChild(this, data.events, fields.ReleaseEvent)
            );

            function countryID(event) { return event.countryID() }

            function nonEmptyEvent(event) {
                var date = event.unwrapDate();
                return event.countryID() || date.year || date.month || date.day;
            }

            ko.computed(function () {
                _(self.events()).groupBy(countryID).each(function (events) {
                    _.invoke(events, "isDuplicate", _.filter(events, nonEmptyEvent).length > 1);
                }).value();
            });

            this.hasDuplicateCountries = errorField(this.events.any("isDuplicate"));
            this.hasInvalidDates = errorField(this.events.any("hasInvalidDate"));

            this.labels = ko.observableArray(
                utils.mapChild(this, data.labels, fields.ReleaseLabel)
            );

            this.labels.original = ko.observable(
                _.map(this.labels.peek(), MB.edit.fields.releaseLabel)
            );

            function releaseLabelKey(releaseLabel) {
                return ((releaseLabel.label() || {}).id || '') + '\0' + clean(releaseLabel.catalogNumber());
            }

            function nonEmptyReleaseLabel(releaseLabel) {
                return releaseLabelKey(releaseLabel) !== '\0';
            }

            ko.computed(function () {
                _(self.labels()).groupBy(releaseLabelKey).each(function (labels) {
                    _.invoke(labels, "isDuplicate", _.filter(labels, nonEmptyReleaseLabel).length > 1);
                }).value();
            });

            this.needsLabels = errorField(this.labels.any("needsLabel"));
            this.hasDuplicateLabels = errorField(this.labels.any("isDuplicate"));

            this.releaseGroup = ko.observable(
                fields.ReleaseGroup(data.releaseGroup || {})
            );

            this.releaseGroup.subscribe(function (releaseGroup) {
                if (releaseGroup.artistCredit && !self.artistCredit.text()) {
                    self.artistCredit.setNames(releaseGroup.artistCredit.names);
                }
            });

            this.needsReleaseGroup = errorField(function () {
                return releaseEditor.action === "edit" && !self.releaseGroup().gid;
            });

            this.mediums = ko.observableArray(
                utils.mapChild(this, data.mediums, fields.Medium)
            );

            this.formats = data.formats;
            this.mediums.original = ko.observableArray([]);
            this.mediums.original(this.existingMediumData());
            this.original = ko.observable(MB.edit.fields.release(this));

            this.loadedMediums = this.mediums.filter("loaded");
            this.hasTrackInfo = this.loadedMediums.all("hasTrackInfo");
            this.hasTracks = this.mediums.any("hasTracks");
            this.hasUnknownTracklist = ko.observable(!this.mediums().length && releaseEditor.action === "edit");
            this.needsRecordings = errorField(this.mediums.any("needsRecordings"));
            this.hasInvalidFormats = errorField(this.mediums.any("hasInvalidFormat"));
            this.needsMediums = errorField(function () { return !(self.mediums().length || self.hasUnknownTracklist()) });
            this.needsTracks = errorField(this.mediums.any("needsTracks"));
            this.needsTrackInfo = errorField(function () { return !self.hasTrackInfo() });
            this.hasInvalidPregapLength = errorField(this.mediums.any("hasInvalidPregapLength"));

            // Ensure there's at least one event, label, and medium to edit.

            if (!this.events().length) {
                this.events.push(fields.ReleaseEvent({}, this));
            }

            if (!this.labels().length) {
                this.labels.push(fields.ReleaseLabel({}, this));
            }

            if (!this.mediums().length && !this.hasUnknownTracklist()) {
                this.mediums.push(fields.Medium({}, this));
            }
        },

        loadMedia: function () {
            var mediums = this.mediums();

            if (mediums.length <= 3) {
                _.invoke(mediums, "loadTracks");
            }
        },

        hasOneEmptyMedium: function () {
            var mediums = this.mediums();
            return mediums.length === 1 && !mediums[0].hasTracks();
        },

        tracksWithUnsetPreviousRecordings: function () {
            return _.transform(this.mediums(), function (result, medium) {
                _.each(medium.tracks(), function (track) {
                    if (track.recording.saved && track.needsRecording()) {
                        result.push(track);
                    }
                });
            });
        },

        existingMediumData: function () {
            // This function should return the mediums on the release as they
            // hopefully exist in the DB, so including ones removed from the
            // page (as long as they have an id, i.e. were attached before).

            var mediums = _.union(this.mediums(), this.mediums.original());

            return _.transform(mediums, function (result, medium) {
                if (medium.id) {
                    result.push(medium);
                }
            });
        }
    });


    ko.bindingHandlers.disableBecauseDiscIDs = {

        update: function (element, valueAccessor, allBindings, viewModel) {
            var disabled = ko.unwrap(valueAccessor()) && viewModel.medium.hasToc();

            $(element)
                .prop("disabled", disabled)
                .toggleClass("disabled-hint", disabled)
                .attr("title", disabled ? i18n.l("This medium has one or more discids which prevent this information from being changed.") : "");
        }
    };

}(MB.releaseEditor = MB.releaseEditor || {}));
