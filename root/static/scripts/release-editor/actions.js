/*
 * Copyright (C) 2014 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import $ from 'jquery';
import ko from 'knockout';

import commaOnlyList from '../common/i18n/commaOnlyList.js';
import {
  hasVariousArtists,
  isComplexArtistCredit,
  reduceArtistCredit,
} from '../common/immutable-entities.js';
import {bracketedText} from '../common/utility/bracketed.js';
import request from '../common/utility/request.js';
import deferFocus from '../edit/utility/deferFocus.js';
import guessFeat from '../edit/utility/guessFeat.js';
import GuessCase from '../guess-case/MB/GuessCase/Main.js';

import fields from './fields.js';
import utils from './utils.js';
import releaseEditor from './viewModel.js';

const maxDuplicateReleaseGroups = 5;

const actions = {

  cancelPage() {
    window.location = this.returnTo;
  },

  nextTab() {
    this.adjacentTab(1);
  },

  previousTab() {
    this.adjacentTab(-1);
  },

  lastTab() {
    this.uiTabs._setOption('active', this.tabCount - 1);
    this.uiTabs.tabs.eq(this.tabCount - 1).focus();
  },

  adjacentTab(direction) {
    var index = this.activeTabIndex();
    var disabled = this.uiTabs.options.disabled;

    while (index >= 0 && index < this.tabCount) {
      index += direction;

      if (!disabled || disabled.indexOf(index) < 0) {
        this.uiTabs._setOption('active', index);
        this.uiTabs.tabs.eq(index).focus();
        return;
      }
    }
  },

  // Information tab

  selectReleaseGroup(releaseGroup) {
    const release = this.rootField.release.peek();
    release.releaseGroup(releaseGroup);
  },

  clearReleaseGroup() {
    const release = this.rootField.release.peek();
    release.releaseGroup(new fields.ReleaseGroup({
      name: release.name.peek(),
    }));
  },

  duplicateReleaseGroups: ko.observableArray([]),
  loadingDuplicateReleaseGroups: ko.observable(false),
  failedLoadingDuplicateReleaseGroups: ko.observable(false),
  duplicateReleaseGroupsRequest: null,
  duplicateReleaseGroupsQuery: null,

  /**
   * Query for existing release groups that are credited to any of the
   * currently-credited artists and have similar names to the release.
   */
  loadDuplicateReleaseGroups() {
    const release = this.rootField.release.peek();
    const query = utils.constructLuceneFieldConjunction({
      arid: release.artistCredit().names
        .map((a) => a.artist?.gid)
        .filter(Boolean),
      releasegroup: [utils.escapeLuceneValue(release.name() ?? '')],
    });
    if (query === this.duplicateReleaseGroupsQuery) {
      return;
    }

    // Cancel any in-progress lookup and clear existing results.
    this.duplicateReleaseGroupsRequest?.abort();
    this.duplicateReleaseGroupsRequest = null;
    this.loadingDuplicateReleaseGroups(false);
    this.failedLoadingDuplicateReleaseGroups(false);
    this.duplicateReleaseGroupsQuery = query;
    this.duplicateReleaseGroups.removeAll();

    /*
     * Make sure that an existing release group isn't selected
     * and that there's a title and artist to use for searching.
     */
    if (
      release.releaseGroup().gid ||
      (release.name() ?? '') === '' ||
      !release.artistCredit().names.some((a) => a.artist?.gid)
    ) {
      return;
    }

    this.loadingDuplicateReleaseGroups(true);
    this.duplicateReleaseGroupsRequest = request({
      url: '/ws/js/release-group' +
        '?direct=false' +
        '&advanced=true' +
        '&limit=' + encodeURIComponent(maxDuplicateReleaseGroups) +
        '&q=' + encodeURIComponent(query),
    })
      .always(() => {
        this.duplicateReleaseGroupsRequest = null;
        this.loadingDuplicateReleaseGroups(false);
      })
      .fail(() => {
        this.failedLoadingDuplicateReleaseGroups(true);
        this.duplicateReleaseGroupsQuery = null;
      })
      .done((data) => {
        const results = data.slice(0, -1).map((rg) => {
          rg.details = bracketedText(
            commaOnlyList([
              rg.l_type_name,
              texp.ln(
                '{num} release',
                '{num} releases',
                rg.release_count,
                {num: rg.release_count},
              ),
            ].filter(Boolean)),
          );
          return new fields.ReleaseGroup(rg);
        });
        ko.utils.arrayPushAll(this.duplicateReleaseGroups, results);
      });
  },

  copyTitleToReleaseGroup: ko.observable(false),
  copyArtistToReleaseGroup: ko.observable(false),

  addReleaseEvent(release) {
    release.events.push(new fields.ReleaseEvent({}, release));
  },

  removeReleaseEvent(releaseEvent) {
    releaseEvent.release.events.remove(releaseEvent);
  },

  addReleaseLabel(release) {
    release.labels.push(new fields.ReleaseLabel({}, release));
  },

  removeReleaseLabel(releaseLabel) {
    releaseLabel.release.labels.remove(releaseLabel);
  },

  // Tracklist tab

  moveMediumUp(medium) {
    this.changeMediumPosition(medium, -1);
  },

  moveMediumDown(medium) {
    this.changeMediumPosition(medium, 1);
  },

  changeMediumPosition(medium, offset) {
    var oldPosition = medium.position.peek();
    var newPosition = oldPosition + offset;

    if (newPosition <= 0) {
      return;
    }

    medium.position(newPosition);

    var mediums = medium.release.mediums.peek();
    var index = mediums.indexOf(medium);
    var possibleNewIndex = index + offset;
    var neighbor = mediums[possibleNewIndex];

    if (neighbor && newPosition === neighbor.position.peek()) {
      neighbor.position(oldPosition);
      mediums[index] = neighbor;
      mediums[possibleNewIndex] = medium;
      medium.release.mediums.notifySubscribers(mediums);
    }
  },

  removeMedium(medium) {
    var mediums = medium.release.mediums;
    var index = mediums.indexOf(medium);
    var position = medium.position();

    medium.removed = true;
    mediums.remove(medium);
    mediums = mediums.peek();

    for (var i = index; (medium = mediums[i]); i++) {
      if (medium.position() === position + 1) {
        medium.position(position);
      }
      ++position;
    }
  },

  focusMediumName(medium) {
    medium.nameModified(false);
  },

  guessCaseAllMedia(data, event) {
    for (const medium of this.mediums.peek()) {
      releaseEditor.guessCaseMediumName(medium, event);
      if (!medium.collapsed.peek()) {
        releaseEditor.guessCaseTrackNames(medium, event);
      }
    }
  },

  /*
   * Shows or hides a preview if event.type is 'mouseenter' or 'mouseleave'.
   * Otherwise, updates the current name.
   */
  guessCaseMediumName(medium, event) {
    const name = medium.name.peek();
    if (!name) {
      return;
    }

    switch (event.type) {
      case 'mouseenter':
        // Don't change the value while the user is dragging to select text.
        if (event.buttons === 0) {
          medium.previewName(GuessCase.entities.release.guess(name));
        }
        break;
      case 'mouseleave':
        medium.previewName(null);
        break;
      default:
        medium.name(
          medium.previewName() ??
            GuessCase.entities.release.guess(name),
        );
        medium.nameModified(medium.name() !== name);
        medium.previewName(null);
    }
  },

  moveTrackUp(track) {
    var previous = track.previous();

    if (track.isDataTrack() && (!previous || !previous.isDataTrack())) {
      track.isDataTrack(false);
    } else if (previous) {
      this.swapTracks(track, previous, track.medium);
    }

    deferFocus('button.track-up', '#' + track.elementID);

    // If the medium had a TOC attached, it's no longer valid.
    track.medium.toc(null);

    return true;
  },

  moveTrackDown(track) {
    var next = track.next();

    if (!next || track.position() == 0) {
      return false;
    }

    if (next && next.isDataTrack() && !track.isDataTrack()) {
      track.isDataTrack(true);
    } else {
      this.swapTracks(track, next, track.medium);
    }

    deferFocus('button.track-down', '#' + track.elementID);

    // If the medium had a TOC attached, it's no longer valid.
    track.medium.toc(null);

    return true;
  },

  swapTracks(track1, track2, medium) {
    const tracks = medium.tracks;
    const underlyingTracks = tracks.peek();
    const offset = medium.hasPregap() ? 0 : 1;
    /*
     * Use indexOf instead of .position()
     * http://tickets.metabrainz.org/browse/MBS-7227
     */
    const position1 = underlyingTracks.indexOf(track1) + offset;
    const position2 = underlyingTracks.indexOf(track2) + offset;
    const number1 = track1.number();
    const number2 = track2.number();
    const dataTrack1 = track1.isDataTrack();
    const dataTrack2 = track2.isDataTrack();

    track1.position(position2);
    track1.number(number2);
    track1.isDataTrack(dataTrack2);

    track2.position(position1);
    track2.number(number1);
    track2.isDataTrack(dataTrack1);

    underlyingTracks[position1 - offset] = track2;
    underlyingTracks[position2 - offset] = track1;
    tracks.notifySubscribers(underlyingTracks);
  },

  resetTrackPositions(tracks, start, offset, removed) {
    let track;
    for (let i = start; (track = tracks[i]); i++) {
      track.position(i + offset);

      if (track.number.peek() == (i + offset + removed)) {
        track.number(i + offset);
      }
    }
  },

  removeTrack(track) {
    var focus = track.next() || track.previous();
    var $medium = $('#' + track.elementID).parents('.advanced-medium');
    var medium = track.medium;
    var tracks = medium.tracks;
    var index = tracks.indexOf(track);
    var offset = medium.hasPregap() ? 0 : 1;

    tracks.remove(track);
    releaseEditor.resetTrackPositions(tracks.peek(), index, offset, 1);

    if (focus) {
      deferFocus('button.remove-item', '#' + focus.elementID);
    } else {
      deferFocus('.add-tracks button.add-item', $medium);
    }

    medium.toc(null);
  },

  focusTrackName(track) {
    track.nameModified(false);
  },

  onTrackInputKeyDown(track, event) {
    /*
     * If a bare up or down arrow key event occurs while the cursor is
     * at the beginning or end of the input, move the focus up or down.
     */
    if (
      (event.key === 'ArrowUp' || event.key === 'ArrowDown') &&
      !event.altKey && !event.ctrlKey && !event.metaKey &&
      !event.shiftKey
    ) {
      const up = event.key === 'ArrowUp';
      const input = event.target;
      if (input.selectionStart === input.selectionEnd && (
        (up && input.selectionStart === 0) ||
        (!up && input.selectionStart === input.value.length)
      )) {
        const row = input.closest('tr');
        const rows = [...row.parentNode.children];
        const rowIndex = rows.indexOf(row);
        const newRowIndex = rowIndex + (up ? -1 : 1);
        if (newRowIndex >= 0 && newRowIndex < rows.length) {
          const cell = input.closest('td');
          const cellIndex = [...cell.parentNode.children].indexOf(cell);
          const newCell = [...rows[newRowIndex].children][cellIndex];
          const newInput = newCell.querySelector('input');
          deferFocus(newInput);
          newInput.selectionStart = newInput.selectionEnd =
            (up ? 0 : newInput.value.length);
          event.stopPropagation();
          return false;
        }
      }
    }
    // If we made it here, let the event be handled like usual.
    return true;
  },

  /*
   * Shows or hides a preview if event.type is 'mouseenter' or 'mouseleave'.
   * Otherwise, updates the current name.
   */
  guessCaseTrackName(track, event) {
    switch (event.type) {
      case 'mouseenter':
        // Don't change the value while the user is dragging to select text.
        if (event.buttons === 0) {
          track.previewName(
            GuessCase.entities.track.guess(track.name.peek()),
          );
        }
        break;
      case 'mouseleave':
        track.previewName(null);
        break;
      default: {
        const origName = track.name.peek();
        track.name(
          track.previewName() ?? GuessCase.entities.track.guess(origName),
        );
        track.nameModified(track.name() !== origName);
        track.previewName(null);
        break;
      }
    }
  },

  guessCaseTrackNames(medium, event) {
    for (const track of medium.tracks.peek()) {
      releaseEditor.guessCaseTrackName(track, event);
    }
  },

  toggleMedium(medium) {
    medium.collapsed(!medium.collapsed());
  },

  openTrackParser(medium) {
    this.trackParserDialog.open(medium);
  },

  resetTrackNumbers(medium) {
    var offset = medium.hasPregap() ? 0 : 1;

    medium.tracks().forEach(function (track, i) {
      track.position(i + offset);
      track.number(i + offset);
    });
  },

  swapTitlesWithArtists(medium) {
    var tracks = medium.tracks();

    var requireConf = tracks.some(function (track) {
      return isComplexArtistCredit(track.artistCredit());
    });

    var question = l(
      'This tracklist has artist credits with information that ' +
      'will be lost if you swap artist credits with track titles. ' +
      'This cannot be undone. Do you wish to continue?',
    );

    if (!requireConf || confirm(question)) {
      for (const track of tracks) {
        const oldTitle = track.name();

        track.name(reduceArtistCredit(track.artistCredit()));
        track.artistCredit({names: [{name: oldTitle}]});
      }
    }
  },

  addNewTracks(medium) {
    var releaseAC = medium.release.artistCredit();
    var defaultAC = hasVariousArtists(releaseAC) ? null : releaseAC;
    var addTrackCount = parseInt(medium.addTrackCount(), 10) || 1;

    for (let i = 0; i < addTrackCount; i++) {
      medium.pushTrack({artistCredit: defaultAC});
    }
  },

  guessReleaseFeatArtists(release) {
    guessFeat(release);
  },

  guessTrackFeatArtists(track) {
    guessFeat(track);
  },

  guessMediumCase(medium, event) {
    releaseEditor.guessCaseMediumName(medium, event);
    releaseEditor.guessCaseTrackNames(medium, event);
  },

  guessMediumFeatArtists(medium) {
    medium.tracks().forEach(guessFeat);
  },

  // Recordings tab

  reuseUnsetPreviousRecordings(release) {
    for (const track of release.tracksWithUnsetPreviousRecordings()) {
      const previous = track.previousTrackAtThisPosition;
      if (previous) {
        track.id = previous.id;
        track.gid = previous.gid;
        delete track.previousTrackAtThisPosition;
      }
      track.recording(track.recording.saved);
    }
  },

  copyTrackTitlesToRecordings: ko.observable(false),
  copyTrackArtistsToRecordings: ko.observable(false),
};

Object.assign(releaseEditor, actions);

export default actions;
