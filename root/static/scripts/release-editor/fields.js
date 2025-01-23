/*
 * Copyright (C) 2014 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import ko from 'knockout';
import * as ReactDOMServer from 'react-dom/server';

import 'knockout-arraytransforms';
import '../../lib/jquery-ui.js';

import {
  BRACKET_PAIRS,
  COUNTRY_JA_AREA_ID,
  LANGUAGE_ENG_ID,
} from '../common/constants.js';
import mbEntity from '../common/entity.js';
import {
  artistCreditsAreEqual,
  hasVariousArtists,
  isCompleteArtistCredit,
  reduceArtistCredit,
} from '../common/immutable-entities.js';
import MB from '../common/MB.js';
import {groupBy} from '../common/utility/arrays.js';
import {cloneObjectDeep} from '../common/utility/cloneDeep.mjs';
import {debounceComputed} from '../common/utility/debounce.js';
import escapeRegExp from '../common/utility/escapeRegExp.mjs';
import formatTrackLength from '../common/utility/formatTrackLength.js';
import isBlank from '../common/utility/isBlank.js';
import isDatabaseRowId from '../common/utility/isDatabaseRowId.js';
import releaseLabelKey from '../common/utility/releaseLabelKey.js';
import request from '../common/utility/request.js';
import {fixedWidthInteger, uniqueId} from '../common/utility/strings.js';
import mbEdit from '../edit/MB/edit.js';
import * as dates from '../edit/utility/dates.js';
import {featRegex} from '../edit/utility/guessFeat.js';
import isUselessMediumTitle from '../edit/utility/isUselessMediumTitle.js';
import * as validation from '../edit/validation.js';

import recordingAssociation from './recordingAssociation.js';
import utils from './utils.js';
import releaseEditor from './viewModel.js';

const fields = {};

const bracketRegex = new RegExp(
  '[' + escapeRegExp(BRACKET_PAIRS.flat().join('')) + ']',
  'g',
);

/*
 * This matches an intentionally-conservative subset of words from
 * preBracketSingleWordsList in ../guess-case/utils/wordCheckers.js that
 * tend to appear at the end of extra title information.
 */
const capitalizedETIRegex =
  /\s+\(.*\b(?:Instrumental|Live|Mix|Remix|Version)\)\s*$/;

/*
 * This matches a subset of words from LOWER_CASE_WORDS in
 * ../guess-case/modes.js.
 */
const miscapitalizedEnglishRegex =
  /[a-zA-Z0-9,]\s+(?:And|Of|Or|The|To)\s+[a-zA-Z]/;

const debounceTrackTitleDelayMs = 250;

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

    data.name ||= '';
    this.name = ko.observable(data.name);
    this.name.original = data.name;
    this.name.subscribe(this.nameChanged, this);

    /*
     * Check that the track has a valid ID to avoid treating a newly-added
     * title as original when seeding a new release (see MBS-13920).
     */
    this.hasFeatInOrigTitle =
      isDatabaseRowId(this.id) &&
      featRegex.test(data.name.replace(bracketRegex, ' '));
    this.hasCapitalizedETIInOrigTitle =
      isDatabaseRowId(this.id) &&
      capitalizedETIRegex.test(data.name);
    this.hasMiscapitalizedOrigTitle =
      isDatabaseRowId(this.id) &&
      medium.release.shouldUseEnglishCapitalization() &&
      miscapitalizedEnglishRegex.test(data.name);

    this.previewName = ko.observable(null);
    this.previewNameDiffers = ko.computed(() => {
      const preview = this.previewName();
      return preview !== null && preview !== this.name();
    });

    this.inputName = ko.computed({
      read: ko.computed(() => this.previewName() ?? this.name()),
      write: this.name,
      owner: this,
    });

    // True after the name has been modified by the "guess case" button.
    this.nameModified = ko.observable(false);

    this.length = ko.observable(data.length);
    this.length.original = data.length;

    var release = medium && medium.release;

    if (release &&
        !data.artistCredit &&
        !hasVariousArtists(release.artistCredit.peek())) {
      data.artistCredit = release.artistCredit.peek();
    }

    this.artistCredit = ko.observable(data.artistCredit
      ? cloneObjectDeep(data.artistCredit)
      : {names: []});
    this.artistCredit.track = this;

    this.formattedLength = ko.observable(formatTrackLength(data.length, ''));
    this.position = ko.observable(data.position);
    this.number = ko.observable(data.number);
    this.isDataTrack = ko.observable(Boolean(data.isDataTrack));
    this.hasNewRecording = ko.observable(true);

    this.updateRecordingTitle = ko.observable(
      releaseEditor.copyTrackTitlesToRecordings(),
    );
    this.updateRecordingArtist = ko.observable(
      releaseEditor.copyTrackArtistsToRecordings(),
    );

    /*
     * When a "copy all" checkbox is unchecked, uncheck our corresponding
     * checkbox if it isn't currently shown.
     */
    releaseEditor.copyTrackTitlesToRecordings.subscribe((checked) => {
      if (!checked && !this.titleDiffersFromRecording()) {
        this.updateRecordingTitle(false);
      }
    });
    releaseEditor.copyTrackArtistsToRecordings.subscribe((checked) => {
      if (!checked && !this.artistDiffersFromRecording()) {
        this.updateRecordingArtist(false);
      }
    });

    this.recordingValue = ko.observable(
      new mbEntity.Recording({name: data.name}),
    );

    /*
     * Custom write function is needed around recordingValue because
     * when it's written to there's certain values we need to save
     * beforehand (see methods below).
     */
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
      if (!recordingData.artistCredit) {
        recordingData.artistCredit = this.artistCredit();
      }
      this.recording(mbEntity(recordingData, 'recording'));
      this.recording.original(mbEdit.fields.recording(this.recording.peek()));
      this.hasNewRecording(false);
    }

    recordingAssociation.track(this);

    this.uniqueID = this.id || uniqueId('new-');
    this.elementID = 'track-row-' + this.uniqueID;

    this.formattedLength.subscribe(this.formattedLengthChanged, this);
    this.hasNewRecording.subscribe(this.hasNewRecordingChanged, this);

    this.hasFeatInTitle = debounceComputed(
      () => featRegex.test(this.name().replace(bracketRegex, ' ')),
      debounceTrackTitleDelayMs,
    );
    this.hasCapitalizedETI = debounceComputed(
      () => capitalizedETIRegex.test(this.name()),
      debounceTrackTitleDelayMs,
    );
    this.hasMiscapitalizedTitle = debounceComputed(
      () => this.medium.release.shouldUseEnglishCapitalization() &&
            miscapitalizedEnglishRegex.test(this.name()),
      debounceTrackTitleDelayMs,
    );
  }

  recordingGID() {
    var recording = this.recording();
    return recording ? recording.gid : null;
  }

  nameChanged() {
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
          length = (hours ? hours + ':' : '') + minutes + ':' + seconds;
          this.formattedLength(length);
        } else if (lengthLength == 4) {
          minutes -= 60;
          hours = 1;
          length = hours + ':' + minutes + ':' + seconds;
          this.formattedLength(length);
        }
      }
    }

    var newLength = utils.unformatTrackLength(length);

    /*
     * The result of `unformatTrackLength` is NaN when the length entered
     * by the user can't be parsed. If they've *cleared* the length, it's
     * null.
     */
    if (Number.isNaN(newLength)) {
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

    /*
     * If the length being changed is for a pregap track and the medium
     * has cdtocs attached, make sure the new length doesn't exceed the
     * maximum possible allowed by any of the tocs.
     */
    const $ = require('jquery');

    var $lengthInput = $('input.track-length', '#track-row-' + this.uniqueID);
    $lengthInput.attr('title', '');

    var hasTooltip = Boolean($lengthInput.data('ui-tooltip'));

    if (this.medium.hasInvalidPregapLength()) {
      $lengthInput.attr(
        'title',
        l(`None of the attached disc IDs can fit a pregap track
           of the given length.`),
      );

      if (!hasTooltip) {
        $lengthInput.tooltip();
      }

      $lengthInput.tooltip('open');
    } else if (hasTooltip) {
      $lengthInput.tooltip('close').tooltip('destroy');
    }
  }

  previous() {
    var tracks = this.medium.tracks();
    var index = tracks.indexOf(this);

    return index > 0 ? tracks[index - 1] : null;
  }

  next() {
    var tracks = this.medium.tracks();
    var index = tracks.indexOf(this);

    return index < tracks.length - 1 ? tracks[index + 1] : null;
  }

  titleDiffersFromRecording() {
    return this.hasExistingRecording() &&
      this.name() !== this.recording().name;
  }

  artistDiffersFromRecording() {
    /*
     * This function is used to determine whether we can update the
     * recording AC, so if there's no recording, then there's nothing
     * to compare against.
     */
    if (!this.hasExistingRecording()) {
      return false;
    }

    return !artistCreditsAreEqual(
      this.artistCredit(),
      this.recording().artistCredit,
    );
  }

  hasExistingRecording() {
    return Boolean(this.recording().gid);
  }

  needsRecording() {
    return !(this.hasExistingRecording() || this.hasNewRecording());
  }

  hasNewRecordingChanged(value) {
    value && this.recording(null);
  }

  setRecordingValue(value) {
    value ||= new mbEntity.Recording({name: this.name()});

    var currentValue = this.recording.peek();
    if (value.gid === currentValue.gid) {
      return;
    }

    /*
     * Save the current track values to allow for comparison when they
     * change. If they change too much, we unset the recording and find
     * a new suggestion. Only save these if there's a recording to
     * revert back to - it doesn't make sense to save these values for
     * comparison if there's no recording.
     */
    if (value.gid) {
      this.name.saved = this.name.peek();
      this.length.saved = this.length.peek();
      this.recording.saved = value;
      this.recording.savedEditData = mbEdit.fields.recording(value);
      this.hasNewRecording(false);
    }

    if (currentValue.gid) {
      var suggestions = this.suggestedRecordings.peek();

      if (!suggestions.includes(currentValue)) {
        this.suggestedRecordings.unshift(currentValue);
      }
    }

    // Hints for guess-feat. functionality.
    var release = this.medium.release;
    if (release) {
      release.relatedArtists =
        [...new Set(release.relatedArtists.concat(value.relatedArtists))];
      release.isProbablyClassical ||= value.isProbablyClassical;
    }

    this.recordingValue(value);
  }

  hasArtist() {
    return isCompleteArtistCredit(this.artistCredit());
  }

  hasTitle() {
    return !isBlank(this.name());
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
  renderArtistCredit: mbEntity.Entity.prototype.renderArtistCredit,
  isCompleteArtistCredit: mbEntity.Entity.prototype.isCompleteArtistCredit,
});

fields.Track = Track;

class Medium {
  constructor(data, release) {
    this.release = release;
    this.name = ko.observable(data.name);
    this.originalName = data.name;
    this.previewName = ko.observable(null);
    this.previewNameDiffers = ko.computed(() => {
      const preview = this.previewName();
      return preview !== null && preview !== this.name();
    });
    this.inputName = ko.computed({
      read: ko.computed(() => this.previewName() ?? this.name()),
      write: this.name,
      owner: this,
    });
    // True after the name has been modified by the "guess case" button.
    this.nameModified = ko.observable(false);
    this.position = ko.observable(data.position || 1);
    this.formatID = ko.observable(data.format_id);
    this.originalFormatID = data.format_id
      ? data.format_id.toString()
      : undefined;
    this.formatUnknownToUser = ko.observable(
      Boolean(data.id && !data.format_id),
    );
    this.showPregapTrackHelp = ko.observable(false);
    this.showDataTracksHelp = ko.observable(false);

    var tracks = data.tracks;
    this.tracks = ko.observableArray(utils.mapChild(this, tracks, Track));
    this.tracksUnknownToUser = ko.observable(false);
    this.tracksWereUnknownToUser = false;

    var self = this;

    var hasPregap = ko.computed(function () {
      var tracks = self.tracks();
      return tracks.length > 0 && tracks[0].position() == 0;
    });

    this.hasPregap = ko.computed({
      read: hasPregap,
      write(newValue) {
        var oldValue = hasPregap();

        if (oldValue && !newValue) {
          const tracks = self.tracks.peek();
          const pregap = tracks[0];

          /*
           * If we have a discID, adding a new track 1 is
           * problematic, since the normal tracklist is
           * supposed to be frozen by the discID.
           */
          if (pregap.id && !self.hasToc()) {
            releaseEditor.resetTrackPositions(tracks, 0, 1, -1);
          } else {
            self.tracks.shift();
          }
        } else if (newValue && !oldValue) {
          self.tracks.unshift(new Track({position: 0, number: 0}, self));
        }
      },
    });

    this.audioTracks = this.tracks.reject('isDataTrack');
    this.dataTracks = this.tracks.filter('isDataTrack');

    var hasDataTracks = ko.computed(function () {
      return self.dataTracks().length > 0;
    });

    this.hasDataTracks = ko.computed({
      read: hasDataTracks,
      write(newValue) {
        var oldValue = hasDataTracks();

        if (oldValue && !newValue) {
          var dataTracks = self.dataTracks();

          /*
           * If we have a discID, adding new normal tracks
           * at the end of the tracklist is problematic,
           * since the normal tracklist is supposed to be
           * frozen by the discID.
           */
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

    this.needsRecordings = ko.computed(function () {
      return !self.tracksUnknownToUser() &&
             self.tracks().some(t => t.needsRecording());
    });
    this.hasTrackArtists = ko.computed(function () {
      return self.tracksUnknownToUser() ||
             self.tracks().every(t => t.hasArtist());
    });
    this.hasTrackTitles = ko.computed(function () {
      return self.tracksUnknownToUser() ||
             self.tracks().every(t => t.hasTitle());
    });

    this.hasVariousArtistsTracks = ko.computed(function () {
      return !self.tracksUnknownToUser() &&
             self.tracks().some(t => t.hasVariousArtists());
    });
    this.confirmedVariousArtists = ko.observable(false);

    this.hasFeatInTrackTitles = ko.computed(function () {
      return !self.tracksUnknownToUser() &&
             self.tracks().some(t => t.hasFeatInTitle());
    });
    this.hasAddedFeatInTrackTitles = ko.computed(function () {
      return self.hasFeatInTrackTitles() &&
             self.tracks().some(
               t => !t.hasFeatInOrigTitle && t.hasFeatInTitle(),
             );
    });
    this.confirmedFeatInTrackTitles = ko.observable(false);

    this.hasCapitalizedETI = ko.computed(function () {
      return !self.tracksUnknownToUser() &&
             self.tracks().some(t => t.hasCapitalizedETI());
    });
    this.hasAddedCapitalizedETI = ko.computed(function () {
      return self.hasCapitalizedETI() &&
             self.tracks().some(
               t => !t.hasCapitalizedETIInOrigTitle && t.hasCapitalizedETI(),
             );
    });
    this.confirmedCapitalizedETI = ko.observable(false);

    this.hasMiscapitalizedTitles = ko.computed(function () {
      return !self.tracksUnknownToUser() &&
             self.tracks().some(t => t.hasMiscapitalizedTitle());
    });
    this.hasAddedMiscapitalizedTitles = ko.computed(function () {
      return self.hasMiscapitalizedTitles() &&
             self.tracks().some(
               t => !t.hasMiscapitalizedOrigTitle &&
                    t.hasMiscapitalizedTitle(),
             );
    });
    this.confirmedMiscapitalizedTitles = ko.observable(false);

    this.hasTooEarlyFormat = ko.computed(function () {
      const mediumFormatDate = MB.mediumFormatDates[self.formatID()];
      return Boolean(mediumFormatDate && self.release.earliestYear() &&
                self.release.earliestYear() < mediumFormatDate);
    });
    this.confirmedEarlyFormat = ko.observable(this.hasTooEarlyFormat());
    this.hasStrangeDigitalPackaging = ko.computed(function () {
      const isFormatDigital = self.formatID() &&
                              // "Digital Media"
                              self.formatID().toString() === '12';
      return Boolean(isFormatDigital &&
                nonEmpty(self.release.packagingID()) &&
                self.release.packagingID().toString() !== '7'); // "None"
    });
    this.confirmedStrangeDigitalPackaging = ko.observable(
      this.hasStrangeDigitalPackaging(),
    );
    this.hasUselessMediumTitle = ko.computed(function () {
      return isUselessMediumTitle(self.name());
    });
    this.confirmedMediumTitle = ko.observable(this.hasUselessMediumTitle());
    this.needsTrackArtists = ko.computed(function () {
      return !self.hasTrackArtists();
    });
    this.needsTrackTitles = ko.computed(function () {
      return !self.hasTrackTitles();
    });

    if (data.id != null) {
      this.id = data.id;
    }

    if (data.originalID != null) {
      this.originalID = data.originalID;
    }

    /*
     * The medium is considered to be loaded if it has tracks, or if
     * there's no ID to load tracks from.
     */
    const loaded = Boolean(
      this.tracks().length ||
      this.tracksUnknownToUser() ||
      !(this.id || this.originalID),
    );

    if (data.cdtocs) {
      this.cdtocs = data.cdtocs;
    }

    this.toc = ko.observable(data.toc || null);
    this.toc.subscribe(this.tocChanged, this);

    this.hasInvalidFormat = ko.computed(function () {
      return !self.canHaveDiscID() &&
              (self.hasExistingTocs() || hasPregap() || hasDataTracks());
    });

    this.loaded = ko.observable(loaded);
    this.loading = ko.observable(false);
    this.collapsed = ko.observable(!loaded);
    this.collapsed.subscribe(this.collapsedChanged, this);
    this.addTrackCount = ko.observable('');
    this.original = ko.observable(this.id ? mbEdit.fields.medium(this) : {});
    this.uniqueID = this.id || uniqueId('new-');

    this.needsTracks = ko.computed(function () {
      return self.loaded() &&
             self.tracks().length === 0 &&
             !self.tracksUnknownToUser();
    });

    this.tracks.subscribe(function (value) {
      if (value.length > 0) {
        self.tracksUnknownToUser(false);
      }
    });

    this.needsFormat = ko.computed(function () {
      return !(self.formatID() || self.formatUnknownToUser());
    });

    this.hasUnconfirmedEarlyFormat = ko.computed(function () {
      return (self.hasTooEarlyFormat() && !self.confirmedEarlyFormat());
    });

    this.hasUnconfirmedStrangeDigitalPackaging = ko.computed(function () {
      return (self.hasStrangeDigitalPackaging() &&
              !self.confirmedStrangeDigitalPackaging());
    });

    this.hasUnconfirmedUselessMediumTitle = ko.computed(function () {
      return (self.hasUselessMediumTitle() && !self.confirmedMediumTitle());
    });

    this.hasUnconfirmedVariousArtists = ko.computed(function () {
      return (self.hasVariousArtistsTracks() &&
              !self.confirmedVariousArtists());
    });

    this.hasUnconfirmedFeatInTrackTitles = ko.computed(function () {
      return (self.hasAddedFeatInTrackTitles() &&
              !self.confirmedFeatInTrackTitles());
    });

    this.hasUnconfirmedCapitalizedETI = ko.computed(function () {
      return (self.hasAddedCapitalizedETI() &&
              !self.confirmedCapitalizedETI());
    });

    this.hasUnconfirmedMiscapitalizedTitles = ko.computed(function () {
      return (self.hasAddedMiscapitalizedTitles() &&
              !self.confirmedMiscapitalizedTitles());
    });

    this.hasVariousArtistsTracks.subscribe(function (value) {
      if (!value) {
        self.confirmedVariousArtists(false);
      }
    });

    this.hasFeatInTrackTitles.subscribe(function (value) {
      if (!value) {
        self.confirmedFeatInTrackTitles(false);
      }
    });

    this.formatID.subscribe(function (value) {
      if (value === self.originalFormatID) {
        self.confirmedEarlyFormat(true);
      } else {
        self.confirmedEarlyFormat(false);
      }
    });

    this.formatID.subscribe(function (value) {
      if (value) {
        self.formatUnknownToUser(false);
      }
    });

    this.name.subscribe(function (value) {
      if (value === self.originalName) {
        self.confirmedMediumTitle(true);
      } else {
        self.confirmedMediumTitle(false);
      }
    });
  }

  pushTrack(data) {
    data ||= {};

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

  togglePregapTrackHelp() {
    this.showPregapTrackHelp(!this.showPregapTrackHelp.peek());
  }

  toggleDataTracksHelp() {
    this.showDataTracksHelp(!this.showDataTracksHelp.peek());
  }

  hasExistingTocs() {
    return Boolean(this.id && this.cdtocs && this.cdtocs.length);
  }

  hasToc() {
    return this.hasExistingTocs() || (Boolean(this.toc()));
  }

  tocChanged(toc) {
    if (typeof toc !== 'string') {
      return;
    }

    toc = toc.split(/\s+/);

    var tocTrackCount = toc.length - 3;
    var tracks = this.tracks();
    var tocTracks = tracks.filter(function (t) {
      return !(t.position() == 0 || t.isDataTrack());
    });
    var trackCount = tocTracks.length;
    var pregapOffset = this.hasPregap() ? 0 : 1;

    var wasConsecutivelyNumbered = tracks.every(function (t, index) {
      return t.number() == (index + pregapOffset);
    });

    if (trackCount > tocTrackCount) {
      tocTracks = tocTracks.slice(0, tocTrackCount);
    } else if (trackCount < tocTrackCount) {
      const newTrackCount = tocTrackCount - trackCount;

      for (let i = 0; i < newTrackCount; i++) {
        tocTracks.push(new Track({}, this));
      }
    }

    this.tracks(
      Array.prototype.concat(
        this.hasPregap() ? tracks[0] : [],
        tocTracks,
        this.dataTracks(),
      ),
    );

    tocTracks.forEach(function (track, index) {
      track.formattedLength(
        formatTrackLength(
          (((toc[index + 4] || toc[2]) - toc[index + 3]) / 75 * 1000), '',
        ),
      );
    });

    this.tracks().forEach(function (track, index) {
      track.position(pregapOffset + index);

      if (wasConsecutivelyNumbered) {
        track.number(pregapOffset + index);
      }
    });
  }

  hasInvalidPregapLength() {
    if (!this.hasPregap() || !this.hasToc()) {
      return false;
    }

    var maxLength = -Infinity;
    var cdtocs = (this.cdtocs || []).concat(this.toc() || []);

    for (let toc of cdtocs) {
      toc = toc.split(/\s+/);
      maxLength = Math.max(maxLength, toc[3] / 75 * 1000);
    }

    return this.tracks()[0].length() > maxLength;
  }

  collapsedChanged(collapsed) {
    if (!collapsed && !this.loaded() && !this.loading()) {
      this.loadTracks(true);
    }
  }

  loadTracks() {
    var id = this.id || this.originalID;
    if (!id) {
      return;
    }

    this.loading(true);

    var args = {
      url: '/ws/js/medium/' + id,
      data: {inc: 'recordings+rels'},
    };

    request(args, this).done(this.tracksLoaded);
  }

  tracksLoaded(data) {
    var tracks = data.tracks;

    var pp = this.id // no ID means this medium is being reused
      ? Track
      : function (track, parent) {
        const copy = {...track};
        delete copy.id;
        return new Track(copy, parent);
      };
    this.tracks(utils.mapChild(this, data.tracks, pp));

    if (this.release.seededTocs) {
      var toc = this.release.seededTocs[this.position()];

      if (toc && (toc.split(/\s+/).length - 3) === tracks.length) {
        this.toc(toc);
      }
    }

    /*
     * We already have the original name, format, and position data,
     * which we don't want to overwrite - it could have been changed
     * by the user before they loaded the medium. We just need the
     * tracklist data, now that it's loaded.
     */
    var currentEditData = mbEdit.fields.medium(this);
    var originalEditData = this.original();

    originalEditData.tracklist = currentEditData.tracklist;
    this.original.notifySubscribers(originalEditData);

    if (this.tracks().length === 0) {
      this.tracksUnknownToUser(true);
      this.tracksWereUnknownToUser = true;
    }
    this.loaded(true);
    this.loading(false);
    this.collapsed(false);
    this.confirmedVariousArtists(this.hasVariousArtistsTracks());
    this.confirmedFeatInTrackTitles(this.hasFeatInTrackTitles());
  }

  hasTracks() {
    return this.tracks().length > 0;
  }

  formattedName() {
    const name = this.name();
    const position = this.position();
    const multidisc = this.release.mediums().length > 1 || position > 1;

    if (name) {
      if (multidisc) {
        return texp.l(
          'Medium {position}: {title}',
          {position, title: name},
        );
      }
      return name;
    } else if (multidisc) {
      return texp.l('Medium {position}', {position});
    }
    return l('Tracklist');
  }

  confirmMediumTitleMessage() {
    const name = this.name();

    return texp.l(
      'I confirm this medium is actually titled “{medium_title}”.',
      {medium_title: name},
    );
  }

  canHaveDiscID() {
    var formatID = parseInt(this.formatID(), 10);

    return !formatID || MB.formatsWithDiscIDs.includes(formatID);
  }

  uselessMediumTitleWarning() {
    const name = this.name();

    return ReactDOMServer.renderToString(exp.l(
      `“{matched_text}” seems to indicate medium ordering rather than
       a medium title. If this is the case, please use the up/down arrows
       on the right side to set the medium position instead of adding a title
       (see {release_style|the guidelines}). Otherwise, please confirm
       that this is the actual title using the checkbox below.`,
      {matched_text: name, release_style: '/doc/Style/Release#Medium_title'},
    ));
  }
}

fields.Medium = Medium;

class ReleaseGroup extends mbEntity.ReleaseGroup {
  constructor(data) {
    data ||= {};

    super(data);

    this.typeID = ko.observable(data.typeID);
    this.secondaryTypeIDs = ko.observableArray(data.secondaryTypeIDs);
  }
}

fields.ReleaseGroup = ReleaseGroup;

class ReleaseEvent {
  constructor(data, release) {
    var date = data.date || {};

    if (nonEmpty(date.year)) {
      date.year = fixedWidthInteger(date.year, 4);
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
      return !dates.isDateValid(date);
    });

    this.hasTooShortYear = debounceComputed(function () {
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
    if (data.id) {
      this.id = data.id;
    }

    this.label = ko.observable(mbEntity(data.label || {}, 'label'));
    this.catalogNumber = ko.observable(data.catalogNumber);
    this.release = release;
    this.isDuplicate = ko.observable(false);

    var self = this;

    this.needsLabel = ko.computed(function () {
      var label = self.label() || {};
      return Boolean(label.name && !label.gid);
    });
  }

  labelHTML() {
    return this.label().html({target: '_blank'});
  }

  needsLabelMessage() {
    return texp.l(
      'You haven’t selected a label for “{name}”.',
      {name: this.label().name},
    );
  }
}

fields.ReleaseLabel = ReleaseLabel;

class Barcode {
  constructor(data) {
    this.original = data;
    this.barcode = ko.observable(data);
    this.message = ko.observable('');
    this.existing = ko.observable('');
    this.confirmed = ko.observable(false);
    this.error = validation.errorField(ko.observable(''));

    this.value = ko.computed({
      read: this.barcode,
      write: this.writeBarcode,
      owner: this,
    });

    /*
     * Always notify of changes, so that when non-digits are stripped,
     * the text in the input element will update even if the stripped
     * value is identical to the old value.
     */
    this.barcode.equalityComparer = null;
    this.value.equalityComparer = null;

    this.none = ko.computed({
      read() {
        return this.barcode() === '';
      },
      write(bool) {
        this.barcode(bool ? '' : null);
      },
      owner: this,
    });
  }

  checkDigit(barcodeTrunk) {
    const iMax = barcodeTrunk.length - 1;
    let calc = 0;
    for (let i = 0; i <= iMax; i++) {
      calc += parseInt(barcodeTrunk[iMax - i], 10) * (i % 2 === 1 ? 1 : 3);
    }
    return (10 - (calc % 10)) % 10;
  }

  validateCheckDigit(barcode) {
    return this.checkDigit(barcode.slice(0, -1)) ===
            parseInt(barcode.slice(-1), 10);
  }

  writeBarcode(barcode) {
    this.barcode((barcode || '').replace(/[^\d]/g, '') || null);
    this.confirmed(false);
  }
}

fields.Barcode = Barcode;

class Release extends mbEntity.Release {
  constructor(data) {
    super(data);

    if (data.gid) {
      MB.entityCache[data.gid] = this; // XXX HACK
    }

    var self = this;
    var errorField = validation.errorField;
    var currentName = data.name;

    // used by ko.bindingHandlers.artistCreditEditor
    this.uniqueID = 'source';

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

    this.artistCredit = ko.observable(data.artistCredit
      ? cloneObjectDeep(data.artistCredit)
      : {names: []});
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
    const annotationText = data.latest_annotation?.text ?? '';
    this.annotation = ko.observable(annotationText);
    this.annotation.original = ko.observable(annotationText);

    this.events = ko.observableArray(
      utils.mapChild(this, data.events, ReleaseEvent),
    );

    function countryID(event) {
      return String(event.countryID());
    }

    function nonEmptyEvent(event) {
      var date = event.unwrapDate();
      return event.countryID() || date.year || date.month || date.day;
    }

    ko.computed(function () {
      for (const events of groupBy(self.events(), countryID).values()) {
        const isDuplicate = events.filter(nonEmptyEvent).length > 1;
        events.forEach(e => {
          e.isDuplicate(isDuplicate);
        });
      }
    });

    this.earliestYear = ko.computed(function () {
      return Math.min(...self.events().map(e => e.unwrapDate().year));
    });

    this.hasDuplicateCountries = errorField(this.events.any('isDuplicate'));
    this.hasInvalidDates = errorField(this.events.any('hasInvalidDate'));
    this.hasTooShortYears = errorField(this.events.any('hasTooShortYear'));

    this.labels = ko.observableArray(
      utils.mapChild(this, data.labels, ReleaseLabel),
    );

    this.labels.original = ko.observable(
      this.labels.peek().map(mbEdit.fields.releaseLabel),
    );

    function nonEmptyReleaseLabel(releaseLabel) {
      return releaseLabelKey(releaseLabel) !== '\0';
    }

    ko.computed(function () {
      const labelsByKey = groupBy(self.labels(), releaseLabelKey);
      for (const labels of labelsByKey.values()) {
        const isDuplicate = labels.filter(nonEmptyReleaseLabel).length > 1;
        labels.forEach(l => {
          l.isDuplicate(isDuplicate);
        });
      }
    });

    this.needsLabels = errorField(this.labels.any('needsLabel'));
    this.hasDuplicateLabels = errorField(this.labels.any('isDuplicate'));

    this.releaseGroup = ko.observable(
      new ReleaseGroup(data.releaseGroup || {}),
    );

    this.releaseGroup.subscribe(function (releaseGroup) {
      if (releaseGroup.artistCredit &&
          !reduceArtistCredit(self.artistCredit())) {
        self.artistCredit(cloneObjectDeep(releaseGroup.artistCredit));
      }
    });

    this.willCreateReleaseGroup = function () {
      return releaseEditor.action === 'add' && !self.releaseGroup().gid;
    };

    this.needsReleaseGroup = errorField(function () {
      return releaseEditor.action === 'edit' && !self.releaseGroup().gid;
    });

    this.mediums = ko.observableArray(
      utils.mapChild(this, data.mediums, Medium),
    );

    this.formats = data.combined_format_name;
    this.mediums.original = ko.observableArray([]);
    this.mediums.original(this.existingMediumData());
    this.original = ko.observable(mbEdit.fields.release(this));

    this.loadedMediums = this.mediums.filter('loaded');
    this.hasTrackArtists = this.loadedMediums.all('hasTrackArtists');
    this.hasTrackTitles = this.loadedMediums.all('hasTrackTitles');
    this.hasTracks = this.mediums.any('hasTracks');
    this.hasUnknownTracklist = ko.observable(
      !this.mediums().length && releaseEditor.action === 'edit',
    );
    this.needsRecordings = errorField(this.mediums.any('needsRecordings'));
    this.hasInvalidFormats = errorField(this.mediums.any('hasInvalidFormat'));
    this.hasUnconfirmedEarlyFormat =
      errorField(this.mediums.any('hasUnconfirmedEarlyFormat'));
    this.hasUnconfirmedStrangeDigitalPackaging =
      errorField(this.mediums.any('hasUnconfirmedStrangeDigitalPackaging'));
    this.hasUnconfirmedVariousArtists = errorField(
      this.mediums.any('hasUnconfirmedVariousArtists'),
    );
    this.hasUnconfirmedFeatInTrackTitles = errorField(
      this.mediums.any('hasUnconfirmedFeatInTrackTitles'),
    );
    this.hasUnconfirmedCapitalizedETI = errorField(function () {
      return releaseEditor.isBeginner &&
        self.shouldUseEnglishCapitalization() &&
        self.mediums().some(m => m.hasUnconfirmedCapitalizedETI());
    });
    this.hasMiscapitalizedTitles = errorField(function () {
      return releaseEditor.isBeginner &&
        self.mediums().some(m => m.hasUnconfirmedMiscapitalizedTitles());
    });
    this.needsMediums = errorField(function () {
      return !(self.mediums().length || self.hasUnknownTracklist());
    });
    this.hasUnconfirmedUselessMediumTitle =
      errorField(this.mediums.any('hasUnconfirmedUselessMediumTitle'));
    this.needsFormat = errorField(this.mediums.any('needsFormat'));
    this.needsTracks = errorField(this.mediums.any('needsTracks'));
    this.needsTrackArtists = errorField(function () {
      return !self.hasTrackArtists();
    });
    this.needsTrackTitles = errorField(function () {
      return !self.hasTrackTitles();
    });
    this.hasInvalidPregapLength = errorField(
      this.mediums.any('hasInvalidPregapLength'),
    );

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
      mediums.forEach(m => {
        m.loadTracks();
      });
    }
  }

  hasOneEmptyMedium() {
    var mediums = this.mediums();
    return mediums.length === 1 &&
           !mediums[0].hasTracks() &&
           !mediums[0].tracksUnknownToUser();
  }

  shouldUseEnglishCapitalization() {
    const langID = this.languageID();
    if (langID && parseInt(langID, 10) !== LANGUAGE_ENG_ID) {
      return false;
    }
    if (this.events().length === 1 &&
        parseInt(this.events()[0].countryID(), 10) === COUNTRY_JA_AREA_ID) {
      return false;
    }
    return true;
  }

  tracksWithUnsetPreviousRecordings() {
    return this.mediums().reduce(function (result, medium) {
      for (const track of medium.tracks()) {
        if (track.recording.saved && track.needsRecording()) {
          result.push(track);
        }
      }
      return result;
    }, []);
  }

  // Returns a generator for iterating over all tracks.
  * allTracks() {
    for (const medium of this.mediums()) {
      for (const track of medium.tracks()) {
        yield track;
      }
    }
  }

  // Returns the number of tracks for which trackFunc returns true.
  countTracks(trackFunc) {
    let count = 0;
    for (const track of this.allTracks()) {
      if (trackFunc(track)) {
        count++;
      }
    }
    return count;
  }

  existingMediumData() {
    /*
     * This function should return the mediums on the release as they
     * hopefully exist in the DB, so including ones removed from the
     * page (as long as they have an id, i.e. were attached before).
     */
    return [...new Set(
      this.mediums().concat(this.mediums.original()),
    )].filter(x => x.id);
  }
}

fields.Release = Release;

export default fields;
