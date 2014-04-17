// This file is part of MusicBrainz, the open internet music database.
// Copyright (C) 2014 MetaBrainz Foundation
// Licensed under the GPL version 2, or (at your option) any later version:
// http://www.gnu.org/licenses/gpl-2.0.txt

(function (releaseEditor) {

    _.extend(releaseEditor, {

        cancelPage: function () { window.location = this.returnTo },

        nextTab: function () { this.adjacentTab(1) },

        previousTab: function () { this.adjacentTab(-1) },

        adjacentTab: function (direction) {
            var index = this.activeTabIndex();
            var disabled = this.uiTabs.options.disabled;

            while (index >= 0 && index < this.tabCount) {
                index += direction;

                if (!disabled || disabled.indexOf(index) < 0) {
                    this.uiTabs._setOption("active", index);
                    this.uiTabs.tabs.eq(index).focus();
                    return;
                }
            }
        },

        // Information tab

        addReleaseEvent: function (release) {
            release.events.push(this.fields.ReleaseEvent({}, release));
        },

        removeReleaseEvent: function (releaseEvent) {
            releaseEvent.release.events.remove(releaseEvent);
        },

        addReleaseLabel: function (release) {
            release.labels.push(this.fields.ReleaseLabel({}, release));
        },

        removeReleaseLabel: function (releaseLabel) {
            releaseLabel.release.labels.remove(releaseLabel);
        },

        guessCaseReleaseName: function () {
            var release = releaseEditor.rootField.release();
            release.name(MB.GuessCase.release.guess(release.name.peek()));
        },

        // Tracklist tab

        moveMediumUp: function (medium) {
            this.changeMediumPosition(medium, function (i) { return i - 1 });
        },

        moveMediumDown: function (medium) {
            this.changeMediumPosition(medium, function (i) { return i + 1 });
        },

        changeMediumPosition: function (medium, getNewPosition) {
            var oldPosition = medium.position();
            var newPosition = getNewPosition(oldPosition);

            if (newPosition <= 0) return;

            medium.position(newPosition);

            var mediums = medium.release.mediums;
            var index = mediums.indexOf(medium);
            var possibleNewIndex = getNewPosition(index);
            var neighbor = mediums.peek()[possibleNewIndex];

            if (neighbor && newPosition === neighbor.position()) {
                neighbor.position(oldPosition);
                MB.utility.moveArrayItem(mediums, index, possibleNewIndex);
            }
        },

        removeMedium: function (medium) {
            var mediums = medium.release.mediums;
            var index = mediums.indexOf(medium);
            var position = medium.position();

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

        moveTrackUp: function (track, event, keepFocus) {
            var previous = track.previous();
            if (!previous) return false;

            var tracks = track.medium.tracks;
            var index = _.indexOf(tracks.peek(), track);
            var oldNumber = track.number.peek();

            track.position(index);
            track.number(previous.number.peek());

            previous.position(index + 1);
            previous.number(oldNumber);

            MB.utility.moveArrayItem(tracks, index, index - 1);

            if (keepFocus !== false) {
                MB.utility.deferFocus("button.track-up", "#" + track.elementID);
            }

            // If the medium had a TOC attached, it's no longer valid.
            track.medium.toc(null);

            return true;
        },

        moveTrackDown: function (track) {
            var nextTrack = track.next();

            if (nextTrack && this.moveTrackUp(nextTrack, null, false)) {
                MB.utility.deferFocus("button.track-down", "#" + track.elementID);
            }
        },

        removeTrack: function (track) {
            var focus = track.next() || track.previous();
            var $medium = $("#" + track.elementID).parents(".advanced-disc");
            var medium = track.medium;
            var tracks = medium.tracks;
            var index = tracks.indexOf(track);

            tracks.remove(track)
            tracks = tracks.peek();

            for (var i = index; track = tracks[i]; i++) {
                track.position(i + 1);

                if (track.number.peek() == i + 2) {
                    track.number(i + 1);
                }
            }

            if (focus) {
                MB.utility.deferFocus("button.remove-item", "#" + focus.elementID);
            } else {
                MB.utility.deferFocus(".add-tracks button.add-item", $medium);
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
            _.each(medium.tracks(), function (track, i) {
                track.position(i + 1);
                track.number(i + 1);
            });
        },

        swapTitlesWithArtists: function (medium) {
            var tracks = medium.tracks();

            var requireConf = _.some(tracks, function (track) {
                return track.artistCredit.isComplex();
            });

            if (!requireConf || confirm(MB.text.ConfirmSwap)) {
                _.each(tracks, function (track) {
                    var oldTitle = track.name();

                    track.name(track.artistCredit.text());
                    track.artistCredit.setNames([{ name: oldTitle }]);
                });
            }
        },

        addNewTracks: function (medium) {
            var tracks = medium.tracks;
            var trackCount = tracks.peek().length;
            var releaseAC = medium.release.artistCredit;
            var defaultAC = releaseAC.isVariousArtists() ? null : releaseAC.toJSON();
            var addTrackCount = parseInt(medium.addTrackCount(), 10) || 1;

            var newTracks = _(addTrackCount).times(function (i) {
                var position = trackCount + i + 1;

                var args = {
                    position: position,
                    number: position,
                    artistCredit: defaultAC
                };

                return releaseEditor.fields.Track(args, medium);
            }).value();

            tracks.push.apply(tracks, newTracks);
        },

        // Recordings tab

        reuseUnsetPreviousRecordings: function (release) {
            _.each(release.tracksWithUnsetPreviousRecordings(), function (track) {
                track.recording(track.recording.saved);
            });
        },

        inferTrackDurationsFromRecordings: ko.observable(false),

        copyTrackChangesToRecordings: ko.observable(false).publishOn(
            "updateRecordings", true
        )
    });

}(MB.releaseEditor = MB.releaseEditor || {}));
