// This file is part of MusicBrainz, the open internet music database.
// Copyright (C) 2014 MetaBrainz Foundation
// Licensed under the GPL version 2, or (at your option) any later version:
// http://www.gnu.org/licenses/gpl-2.0.txt

import ko from 'knockout';
import _ from 'lodash';

import MB_entity from '../common/entity';
import releaseLabelKey from '../common/utility/releaseLabelKey';
import {
  artistCreditsAreEqual,
  hasVariousArtists,
  isCompleteArtistCredit,
  reduceArtistCredit,
} from '../common/immutable-entities';
import MB from '../common/MB';
import clean from '../common/utility/clean';
import debounce from '../common/utility/debounce';
import formatTrackLength from '../common/utility/formatTrackLength';
import nonEmpty from '../common/utility/nonEmpty';
import isBlank from '../common/utility/isBlank';
import request from '../common/utility/request';
import MB_edit from '../edit/MB/edit';
import * as dates from '../edit/utility/dates';
import * as validation from '../edit/validation';

import 'knockout-arraytransforms';

import actions from './actions';
import recordingAssociation from './recordingAssociation';
import utils from './utils';
import releaseEditor from './viewModel';

const fields = {};

releaseEditor.fields = fields;

class Track {
    constructor(data, medium) {
        this.medium = medium;

        if (data.id != null) {
            this.id = data.id;
        }

        if (data.gid != null) {
            this.gid = data.gid;
        }

        data.name = data.name || "";
        this.name = ko.observable(data.name);
        this.name.original = data.name;
        this.name.subscribe(this.nameChanged, this);

        this.length = ko.observable(data.length);
        this.length.original = data.length;

        var release = medium && medium.release;

        if (release && !data.artistCredit && !hasVariousArtists(release.artistCredit.peek())) {
            data.artistCredit = release.artistCredit.peek();
        }

        this.artistCredit = ko.observable(data.artistCredit ? _.cloneDeep(data.artistCredit) : {names: []});
        this.artistCredit.track = this;

        this.formattedLength = ko.observable(formatTrackLength(data.length, ''));
        this.position = ko.observable(data.position);
        this.number = ko.observable(data.number);
        this.isDataTrack = ko.observable(!!data.isDataTrack);
        this.hasNewRecording = ko.observable(true);

        this.updateRecordingTitle = ko.observable(releaseEditor.copyTrackTitlesToRecordings());
        this.updateRecordingArtist = ko.observable(releaseEditor.copyTrackArtistsToRecordings());

        releaseEditor.copyTrackTitlesToRecordings.subscribe(this.updateRecordingTitle);
        releaseEditor.copyTrackArtistsToRecordings.subscribe(this.updateRecordingArtist);

        this.recordingValue = ko.observable(
            new MB_entity.Recording({name: data.name}),
        );

        // Custom write function is needed around recordingValue because
        // when it's written to there's certain values we need to save
        // beforehand (see methods below).
        this.recording = ko.computed({
            read: this.recordingValue,
            write: this.setRecordingValue,
            owner: this,
        });

        this.recording.original = ko.observable();
        this.suggestedRecordings = ko.observableArray([]);
        this.loadingSuggestedRecordings = ko.observable(false);

        var recordingData = data.recording;
        if (recordingData) {
            if (_.isEmpty(recordingData.artistCredit)) {
                recordingData.artistCredit = this.artistCredit();
            }
            this.recording(MB_entity(recordingData, "recording"));
            this.recording.original(MB_edit.fields.recording(this.recording.peek()));
            this.hasNewRecording(false);
        }

        recordingAssociation.track(this);

        this.uniqueID = this.id || _.uniqueId("new-");
        this.elementID = "track-row-" + this.uniqueID;

        this.formattedLength.subscribe(this.formattedLengthChanged, this);
        this.hasNewRecording.subscribe(this.hasNewRecordingChanged, this);
    }

    recordingGID() {
        var recording = this.recording();
        return recording ? recording.gid : null;
    }

    nameChanged(name) {
        if (!this.hasExistingRecording()) {
            var recording = this.recording.peek();

            recording.name = this.name();
            this.recording.notifySubscribers(recording);
        }
    }

    formattedLengthChanged(length) {
        var lengthLength = length.length;

        // Convert stuff like 111 into 1:11

        if (/^\d+$/.test(length) && lengthLength >= 3 && lengthLength <= 6) {
            var hoursLength = Math.max(0, lengthLength - 4);

            var hours = length.slice(0, hoursLength);
            var minutes = length.slice(hoursLength, lengthLength - 2);
            var seconds = length.slice(-2);

            if (parseInt(seconds, 10) < 60) {
                if (parseInt(minutes, 10) < 60) {
                    length = (hours ? hours + ":" : "") + minutes + ":" + seconds;
                    this.formattedLength(length);
                } else if (lengthLength == 4) {
                    minutes -= 60;
                    hours = 1;
                    length = hours + ":" + minutes + ":" + seconds;
                    this.formattedLength(length);
                }
            }
        }

        var oldLength = this.length();
        var newLength = utils.unformatTrackLength(length);

        if (_.isNaN(newLength)) {
            this.formattedLength('');
            return;
        }

        this.length(newLength);

        var newFormattedLength = formatTrackLength(newLength, '');
        if (length !== newFormattedLength) {
            this.formattedLength(newFormattedLength);
        }

        if (typeof document === 'undefined') {
            // XXX Skip during tests
            return;
        }

        // If the length being changed is for a pregap track and the medium
        // has cdtocs attached, make sure the new length doesn't exceed the
        // maximum possible allowed by any of the tocs.
        const $ = require('jquery');

        var $lengthInput = $("input.track-length", "#track-row-" + this.uniqueID);
        $lengthInput.attr("title", "");

        var hasTooltip = !!$lengthInput.data("ui-tooltip");

        if (this.medium.hasInvalidPregapLength()) {
            $lengthInput.attr("title", l('None of the attached disc IDs can fit a pregap track of the given length.'));

            if (!hasTooltip) {
                $lengthInput.tooltip();
            }

            $lengthInput.tooltip("open");
        } else if (hasTooltip) {
            $lengthInput.tooltip("close").tooltip("destroy");
        }
    }

    previous() {
        var tracks = this.medium.tracks();
        var index = _.indexOf(tracks, this);

        return index > 0 ? tracks[index - 1] : null;
    }

    next() {
        var tracks = this.medium.tracks();
        var index = _.indexOf(tracks, this);

        return index < tracks.length - 1 ? tracks[index + 1] : null;
    }

    titleDiffersFromRecording() {
        return this.name() !== this.recording().name;
    }

    artistDiffersFromRecording() {
        const recording = this.recording();

        // This function is used to determine whether we can update the
        // recording AC, so if there's no recording, then there's nothing
        // to compare against.
        if (!recording || !recording.gid) {
            return false;
        }

        return !artistCreditsAreEqual(this.artistCredit(), recording.artistCredit);
    }

    hasExistingRecording() {
        return !!this.recording().gid;
    }

    needsRecording() {
        return !(this.hasExistingRecording() || this.hasNewRecording());
    }

    hasNewRecordingChanged(value) {
        value && this.recording(null);
    }

    setRecordingValue(value) {
        value = value || new MB_entity.Recording({name: this.name()});

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
            this.recording.savedEditData = MB_edit.fields.recording(value);
            this.hasNewRecording(false);
        }

        if (currentValue.gid) {
            var suggestions = this.suggestedRecordings.peek();

            if (!_.includes(suggestions, currentValue)) {
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
    }

    hasNameAndArtist() {
        return !isBlank(this.name()) && isCompleteArtistCredit(this.artistCredit());
    }

    hasVariousArtists() {
        return hasVariousArtists(this.artistCredit());
    }

    relatedArtists() {
        return this.medium.release.relatedArtists;
    }

    isProbablyClassical() {
        return this.medium.release.isProbablyClassical;
    }
}

Object.assign(Track.prototype, {
    entityType: 'track',
    renderArtistCredit: MB_entity.Entity.prototype.renderArtistCredit,
    isCompleteArtistCredit: MB_entity.Entity.prototype.isCompleteArtistCredit,
})

fields.Track = Track;

class Medium {
    constructor(data, release) {
        this.release = release;
        this.name = ko.observable(data.name);
        this.position = ko.observable(data.position || 1);
        this.formatID = ko.observable(data.formatID);
        this.formatUnknownToUser = ko.observable(Boolean(data.id && !data.formatID));

        var tracks = data.tracks;
        this.tracks = ko.observableArray(utils.mapChild(this, tracks, Track));

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
                    const tracks = self.tracks.peek();
                    const pregap = tracks[0];

                    if (pregap.id) {
                        releaseEditor.resetTrackPositions(tracks, 0, 1, -1);
                    } else {
                        self.tracks.shift();
                    }
                } else if (newValue && !oldValue) {
                    self.tracks.unshift(new Track({position: 0, number: 0}, self));
                }
            },
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
                    self.pushTrack({isDataTrack: true});
                }
            },
        });

        this.needsRecordings = this.tracks.any("needsRecording");
        this.hasTrackInfo = this.tracks.all("hasNameAndArtist");
        this.hasVariousArtistTracks = this.tracks.any("hasVariousArtists");
        this.needsTrackInfo = ko.computed(function () { return !self.hasTrackInfo() });

        if (data.id != null) {
            this.id = data.id;
        }

        if (data.originalID != null) {
            this.originalID = data.originalID;
        }

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
        this.original = ko.observable(this.id ? MB_edit.fields.medium(this) : {});
        this.uniqueID = this.id || _.uniqueId("new-");

        this.needsTracks = ko.computed(function () {
            return self.loaded() && self.tracks().length === 0;
        });

        this.needsFormat = ko.computed(function () {
            return !(self.formatID() || self.formatUnknownToUser());
        });

        this.formatID.subscribe(function (value) {
            if (value) {
                self.formatUnknownToUser(false);
            }
        });
    }

    pushTrack(data) {
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

        this.tracks.push(new Track(data, this));
    }

    hasExistingTocs() {
        return !!(this.id && this.cdtocs && this.cdtocs.length);
    }

    hasToc() {
        return this.hasExistingTocs() || (!!this.toc());
    }

    tocChanged(toc) {
        if (!_.isString(toc)) return;

        toc = toc.split(/\s+/);

        var tocTrackCount = toc.length - 3;
        var tracks = this.tracks();
        var tocTracks = _.reject(tracks, function (t) { return t.position() == 0 || t.isDataTrack() });
        var trackCount = tocTracks.length;
        var pregapOffset = this.hasPregap() ? 0 : 1;

        var wasConsecutivelyNumbered = _.every(tracks, function (t, index) {
            return t.number() == (index + pregapOffset);
        });

        if (trackCount > tocTrackCount) {
            tocTracks = tocTracks.slice(0, tocTrackCount);
        } else if (trackCount < tocTrackCount) {
            var self = this;

            _.times(tocTrackCount - trackCount, function () {
                tocTracks.push(new Track({}, self));
            });
        }

        this.tracks(
            Array.prototype.concat(
                this.hasPregap() ? tracks[0] : [],
                tocTracks,
                this.dataTracks(),
            ),
        );

        _.each(tocTracks, function (track, index) {
            track.formattedLength(
                formatTrackLength(
                    (((toc[index + 4] || toc[2]) - toc[index + 3]) / 75 * 1000), '',
                ),
            );
        });

        _.each(this.tracks(), function (track, index) {
            track.position(pregapOffset + index);

            if (wasConsecutivelyNumbered) {
                track.number(pregapOffset + index);
            }
        });
    }

    hasInvalidPregapLength() {
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
    }

    collapsedChanged(collapsed) {
        if (!collapsed && !this.loaded() && !this.loading()) {
            this.loadTracks(true);
        }
    }

    loadTracks() {
        var id = this.id || this.originalID;
        if (!id) return;

        this.loading(true);

        var args = {
            url: "/ws/js/medium/" + id,
            data: {inc: "recordings+rels"},
        };

        request(args, this).done(this.tracksLoaded);
    }

    tracksLoaded(data) {
        var tracks = data.tracks;

        var pp = this.id ? // no ID means this medium is being reused
            Track :
            function (track, parent) { return new Track(_.omit(track, 'id'), parent); };
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
        var currentEditData = MB_edit.fields.medium(this);
        var originalEditData = this.original();

        originalEditData.tracklist = currentEditData.tracklist;
        this.original.notifySubscribers(originalEditData);

        this.loaded(true);
        this.loading(false);
        this.collapsed(false);
    }

    hasTracks() { return this.tracks().length > 0 }

    formattedName() {
        var name = this.name(),
            position = this.position(),
            multidisc = this.release.mediums().length > 1 || position > 1;

        if (name) {
            if (multidisc) {
                return texp.l("Medium {position}: {title}", {position: position, title: name});
            }
            return name;
        }
        else if (multidisc) {
            return texp.l("Medium {position}", {position: position});
        }
        return l("Tracklist");
    }

    canHaveDiscID() {
        var formatID = parseInt(this.formatID(), 10);

        return !formatID || _.includes(MB.formatsWithDiscIDs, formatID);
    }
}

fields.Medium = Medium;

class ReleaseGroup extends MB_entity.ReleaseGroup {
    constructor(data) {
        data = data || {};

        super(data);

        this.typeID = ko.observable(data.typeID)
        this.secondaryTypeIDs = ko.observableArray(data.secondaryTypeIDs);
    }
}

fields.ReleaseGroup = ReleaseGroup;

class ReleaseEvent {
    constructor(data, release) {
        var date = data.date || {};

        if (nonEmpty(date.year)) {
            date.year = _.padStart(String(date.year), 4, '0');
        }

        this.date = {
            year:   ko.observable(date.year == null ? null : date.year),
            month:  ko.observable(date.month == null ? null : date.month),
            day:    ko.observable(date.day == null ? null : date.day),
        };

        this.countryID = ko.observable(data.country ? data.country.id : null);
        this.release = release;
        this.isDuplicate = ko.observable(false);

        var self = this;

        this.hasInvalidDate = ko.computed(function () {
            var date = self.unwrapDate();
            return !dates.isDateValid(date.year, date.month, date.day);
        });

        this.hasTooShortYear = debounce(function () {
            var date = self.unwrapDate();
            return !dates.isYearFourDigits(date.year);
        });
    }

    unwrapDate() {
        return {
            year: this.date.year(),
            month: this.date.month(),
            day: this.date.day(),
        };
    }

    hasAmazonDate() {
        var date = this.unwrapDate();
        return date.year == 1990 && date.month == 10 && date.day == 25;
    }

    hasJanuaryFirstDate() {
        var date = this.unwrapDate();
        return date.month == 1 && date.day == 1;
    }
}

fields.ReleaseEvent = ReleaseEvent;

class ReleaseLabel {
    constructor(data, release) {
        if (data.id) this.id = data.id;

        this.label = ko.observable(MB_entity(data.label || {}, "label"));
        this.catalogNumber = ko.observable(data.catalogNumber);
        this.release = release;
        this.isDuplicate = ko.observable(false);

        var self = this;

        this.needsLabel = ko.computed(function () {
            var label = self.label() || {};
            return !!(label.name && !label.gid);
        });
    }

    labelHTML() {
        return this.label().html({target: "_blank"});
    }

    needsLabelMessage() {
        return texp.l('You haven’t selected a label for “{name}”.', {name: this.label().name});
    }
}

fields.ReleaseLabel = ReleaseLabel;

class Barcode {
    constructor(data) {
        this.original = data;
        this.barcode = ko.observable(data);
        this.message = ko.observable("");
        this.confirmed = ko.observable(false);
        this.error = validation.errorField(ko.observable(""));

        this.value = ko.computed({
            read: this.barcode,
            write: this.writeBarcode,
            owner: this,
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
            owner: this,
        });
    }

    checkDigit(barcode) {
        if (barcode.length !== 12) return false;

        for (var i = 0, calc = 0; i < 12; i++) {
            calc += parseInt(barcode[i], 10) * this.weights[i];
        }

        var digit = 10 - (calc % 10);
        return digit === 10 ? 0 : digit;
    }

    validateCheckDigit(barcode) {
        return this.checkDigit(barcode.slice(0, 12)) === parseInt(barcode[12], 10);
    }

    writeBarcode(barcode) {
        this.barcode((barcode || "").replace(/[^\d]/g, "") || null);
        this.confirmed(false);
    }
}

Barcode.prototype.weights = [1, 3, 1, 3, 1, 3, 1, 3, 1, 3, 1, 3];

fields.Barcode = Barcode;

class Release extends MB_entity.Release {
    constructor(data) {
        super(data);

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

        this.artistCredit = ko.observable(data.artistCredit ? _.cloneDeep(data.artistCredit) : {names: []});
        this.artistCredit.saved = this.artistCredit.peek();

        this.needsArtistCredit = errorField(function () {
            return !isCompleteArtistCredit(self.artistCredit());
        });

        this.statusID = ko.observable(data.statusID);
        this.languageID = ko.observable(data.languageID);
        this.scriptID = ko.observable(data.scriptID);
        this.packagingID = ko.observable(data.packagingID);
        this.barcode = new Barcode(data.barcode);
        this.comment = ko.observable(data.comment);
        const annotationText = data.latest_annotation
            ? data.latest_annotation.text
            : '';
        this.annotation = ko.observable(annotationText);
        this.annotation.original = ko.observable(annotationText);

        this.events = ko.observableArray(
            utils.mapChild(this, data.events, ReleaseEvent),
        );

        function countryID(event) { return event.countryID() }

        function nonEmptyEvent(event) {
            var date = event.unwrapDate();
            return event.countryID() || date.year || date.month || date.day;
        }

        ko.computed(function () {
            _(self.events()).groupBy(countryID).each(function (events) {
                const isDuplicate = _.filter(events, nonEmptyEvent).length > 1;
                events.forEach(e => e.isDuplicate(isDuplicate));
            });
        });

        this.hasDuplicateCountries = errorField(this.events.any("isDuplicate"));
        this.hasInvalidDates = errorField(this.events.any("hasInvalidDate"));
        this.hasTooShortYears = errorField(this.events.any("hasTooShortYear"));

        this.labels = ko.observableArray(
            utils.mapChild(this, data.labels, ReleaseLabel),
        );

        this.labels.original = ko.observable(
            _.map(this.labels.peek(), MB_edit.fields.releaseLabel),
        );

        function nonEmptyReleaseLabel(releaseLabel) {
            return releaseLabelKey(releaseLabel) !== '\0';
        }

        ko.computed(function () {
            _(self.labels()).groupBy(releaseLabelKey).each(function (labels) {
                const isDuplicate = _.filter(labels, nonEmptyReleaseLabel).length > 1;
                labels.forEach(l => l.isDuplicate(isDuplicate));
            });
        });

        this.needsLabels = errorField(this.labels.any("needsLabel"));
        this.hasDuplicateLabels = errorField(this.labels.any("isDuplicate"));

        this.releaseGroup = ko.observable(
            new ReleaseGroup(data.releaseGroup || {}),
        );

        this.releaseGroup.subscribe(function (releaseGroup) {
            if (releaseGroup.artistCredit && !reduceArtistCredit(self.artistCredit())) {
                self.artistCredit(_.cloneDeep(releaseGroup.artistCredit));
            }
        });

        this.willCreateReleaseGroup = function () {
            return releaseEditor.action === "add" && !self.releaseGroup().gid;
        };

        this.needsReleaseGroup = errorField(function () {
            return releaseEditor.action === "edit" && !self.releaseGroup().gid;
        });

        this.mediums = ko.observableArray(
            utils.mapChild(this, data.mediums, Medium),
        );

        this.formats = data.combined_format_name;
        this.mediums.original = ko.observableArray([]);
        this.mediums.original(this.existingMediumData());
        this.original = ko.observable(MB_edit.fields.release(this));

        this.loadedMediums = this.mediums.filter("loaded");
        this.hasTrackInfo = this.loadedMediums.all("hasTrackInfo");
        this.hasTracks = this.mediums.any("hasTracks");
        this.hasUnknownTracklist = ko.observable(!this.mediums().length && releaseEditor.action === "edit");
        this.needsRecordings = errorField(this.mediums.any("needsRecordings"));
        this.hasInvalidFormats = errorField(this.mediums.any("hasInvalidFormat"));
        this.needsMediums = errorField(function () { return !(self.mediums().length || self.hasUnknownTracklist()) });
        this.needsFormat = errorField(this.mediums.any("needsFormat"));
        this.needsTracks = errorField(this.mediums.any("needsTracks"));
        this.needsTrackInfo = errorField(function () { return !self.hasTrackInfo() });
        this.hasInvalidPregapLength = errorField(this.mediums.any("hasInvalidPregapLength"));

        // Ensure there's at least one event, label, and medium to edit.

        if (!this.events().length) {
            this.events.push(new ReleaseEvent({}, this));
        }

        if (!this.labels().length) {
            this.labels.push(new ReleaseLabel({}, this));
        }

        if (!this.mediums().length && !this.hasUnknownTracklist()) {
            this.mediums.push(new Medium({}, this));
        }
    }

    loadMedia() {
        var mediums = this.mediums();

        if (mediums.length <= 3) {
            mediums.forEach(m => m.loadTracks());
        }
    }

    hasOneEmptyMedium() {
        var mediums = this.mediums();
        return mediums.length === 1 && !mediums[0].hasTracks();
    }

    tracksWithUnsetPreviousRecordings() {
        return _.transform(this.mediums(), function (result, medium) {
            _.each(medium.tracks(), function (track) {
                if (track.recording.saved && track.needsRecording()) {
                    result.push(track);
                }
            });
        });
    }

    existingMediumData() {
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
}

fields.Release = Release;

export default fields;
