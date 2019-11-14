// This file is part of MusicBrainz, the open internet music database.
// Copyright (C) 2014 MetaBrainz Foundation
// Licensed under the GPL version 2, or (at your option) any later version:
// http://www.gnu.org/licenses/gpl-2.0.txt

import $ from 'jquery';
import ko from 'knockout';
import _ from 'lodash';

import {
  hasVariousArtists,
  isComplexArtistCredit,
  reduceArtistCredit,
} from '../common/immutable-entities';
import MB from '../common/MB';
import deferFocus from '../edit/utility/deferFocus';
import guessFeat from '../edit/utility/guessFeat';

import fields from './fields';
import releaseEditor from './viewModel';

const actions = {

    cancelPage: function () { window.location = this.returnTo },

    nextTab: function () { this.adjacentTab(1) },

    previousTab: function () { this.adjacentTab(-1) },

    lastTab: function () {
        this.uiTabs._setOption('active', this.tabCount - 1);
        this.uiTabs.tabs.eq(this.tabCount - 1).focus();
        return;
     },

    adjacentTab: function (direction) {
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

    copyTitleToReleaseGroup: ko.observable(false),
    copyArtistToReleaseGroup: ko.observable(false),

    addReleaseEvent: function (release) {
        release.events.push(new fields.ReleaseEvent({}, release));
    },

    removeReleaseEvent: function (releaseEvent) {
        releaseEvent.release.events.remove(releaseEvent);
    },

    addReleaseLabel: function (release) {
        release.labels.push(new fields.ReleaseLabel({}, release));
    },

    removeReleaseLabel: function (releaseLabel) {
        releaseLabel.release.labels.remove(releaseLabel);
    },

    // Tracklist tab

    moveMediumUp: function (medium) {
        this.changeMediumPosition(medium, -1);
    },

    moveMediumDown: function (medium) {
        this.changeMediumPosition(medium, 1);
    },

    changeMediumPosition: function (medium, offset) {
        var oldPosition = medium.position.peek();
        var newPosition = oldPosition + offset;

        if (newPosition <= 0) return;

        medium.position(newPosition);

        var mediums = medium.release.mediums.peek();
        var index = _.indexOf(mediums, medium);
        var possibleNewIndex = index + offset;
        var neighbor = mediums[possibleNewIndex];

        if (neighbor && newPosition === neighbor.position.peek()) {
            neighbor.position(oldPosition);
            mediums[index] = neighbor;
            mediums[possibleNewIndex] = medium;
            medium.release.mediums.notifySubscribers(mediums);
        }
    },

    removeMedium: function (medium) {
        var mediums = medium.release.mediums;
        var index = mediums.indexOf(medium);
        var position = medium.position();

        medium.removed = true;
        mediums.remove(medium);
        mediums = mediums.peek();

        for (var i = index; medium = mediums[i]; i++) {
            if (medium.position() === position + 1) {
                medium.position(position);
            }
            ++position;
        }
    },

    guessCaseMediaNames: function () {
        _.each(this.mediums.peek(), function (medium) {
            releaseEditor.guessCaseMediumName(medium);
            releaseEditor.guessCaseTrackNames(medium);
        });
    },

    guessCaseMediumName: function (medium) {
        var name = medium.name.peek();

        if (name) {
            medium.name(MB.GuessCase.release.guess(name));
        }
    },

    moveTrackUp: function (track, event) {
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

    moveTrackDown: function (track) {
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

        return true
    },

    swapTracks: function (track1, track2, medium) {
        var tracks = medium.tracks,
            underlyingTracks = tracks.peek(),
            offset = medium.hasPregap() ? 0 : 1,
            // Use _.indexOf instead of .position()
            // http://tickets.metabrainz.org/browse/MBS-7227
            position1 = _.indexOf(underlyingTracks, track1) + offset,
            position2 = _.indexOf(underlyingTracks, track2) + offset,
            number1 = track1.number(),
            number2 = track2.number(),
            dataTrack1 = track1.isDataTrack(),
            dataTrack2 = track2.isDataTrack();

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

    resetTrackPositions: function (tracks, start, offset, removed) {
        let track;
        for (let i = start; track = tracks[i]; i++) {
            track.position(i + offset);

            if (track.number.peek() == (i + offset + removed)) {
                track.number(i + offset);
            }
        }
    },

    removeTrack: function (track) {
        var focus = track.next() || track.previous();
        var $medium = $('#' + track.elementID).parents('.advanced-disc');
        var medium = track.medium;
        var tracks = medium.tracks;
        var index = tracks.indexOf(track);
        var offset = medium.hasPregap() ? 0 : 1;

        tracks.remove(track)
        releaseEditor.resetTrackPositions(tracks.peek(), index, offset, 1);

        if (focus) {
            deferFocus('button.remove-item', '#' + focus.elementID);
        } else {
            deferFocus('.add-tracks button.add-item', $medium);
        }

        medium.toc(null);
    },

    guessCaseTrackName: function (track) {
        track.name(MB.GuessCase.track.guess(track.name.peek()));
    },

    guessCaseTrackNames: function (medium) {
        _.each(medium.tracks.peek(), function (track) {
            releaseEditor.guessCaseTrackName(track);
        });
    },

    toggleMedium: function (medium) { medium.collapsed(!medium.collapsed()) },

    openTrackParser: function (medium) { this.trackParserDialog.open(medium) },

    resetTrackNumbers: function (medium) {
        var offset = medium.hasPregap() ? 0 : 1;

        _.each(medium.tracks(), function (track, i) {
            track.position(i + offset);
            track.number(i + offset);
        });
    },

    swapTitlesWithArtists: function (medium) {
        var tracks = medium.tracks();

        var requireConf = _.some(tracks, function (track) {
            return isComplexArtistCredit(track.artistCredit());
        });

        var question = l(
            'This tracklist has artist credits with information that ' +
            'will be lost if you swap artist credits with track titles. ' +
            'This cannot be undone. Do you wish to continue?',
        );

        if (!requireConf || confirm(question)) {
            _.each(tracks, function (track) {
                var oldTitle = track.name();

                track.name(reduceArtistCredit(track.artistCredit()));
                track.artistCredit({names: [{name: oldTitle}]});
                track.artistCreditEditorInst.setState({
                    artistCredit: track.artistCredit.peek(),
                });
            });
        }
    },

    addNewTracks: function (medium) {
        var releaseAC = medium.release.artistCredit();
        var defaultAC = hasVariousArtists(releaseAC) ? null : releaseAC;
        var addTrackCount = parseInt(medium.addTrackCount(), 10) || 1;

        _.times(addTrackCount, function () {
            medium.pushTrack({artistCredit: defaultAC});
        });
    },

    guessReleaseFeatArtists: function (release) {
        guessFeat(release);
    },

    guessTrackFeatArtists: function (track) {
        guessFeat(track);
    },

    guessMediumFeatArtists: function (medium) {
        _.each(medium.tracks(), guessFeat);
    },

    // Recordings tab

    reuseUnsetPreviousRecordings: function (release) {
        _.each(release.tracksWithUnsetPreviousRecordings(), function (track) {
            var previous = track.previousTrackAtThisPosition;
            if (previous) {
                track.id = previous.id;
                track.gid = previous.gid;
                delete track.previousTrackAtThisPosition;
            }
            track.recording(track.recording.saved);
        });
    },

    copyTrackTitlesToRecordings: ko.observable(false),
    copyTrackArtistsToRecordings: ko.observable(false),
};

Object.assign(releaseEditor, actions);

export default actions;
