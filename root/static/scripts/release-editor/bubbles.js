// This file is part of MusicBrainz, the open internet music database.
// Copyright (C) 2014 MetaBrainz Foundation
// Licensed under the GPL version 2, or (at your option) any later version:
// http://www.gnu.org/licenses/gpl-2.0.txt

(function (releaseEditor) {

    function bubbleDoc(options) {
        return MB.Control.BubbleDoc("Information").extend(options || {});
    }

    releaseEditor.guessCaseBubble = bubbleDoc();

    releaseEditor.artistBubble = MB.Control.ArtistCreditBubbleDoc("Information");

    releaseEditor.releaseGroupBubble = bubbleDoc({
        canBeShown: function (release) {
            var releaseGroup = release.releaseGroup();
            return releaseGroup && releaseGroup.gid;
        }
    });

    releaseEditor.statusBubble = bubbleDoc({
        canBeShown: function (release) { return release.statusID() == 4 }
    });

    releaseEditor.dateBubble = bubbleDoc({
        canBeShown: function (event) {
            return event.hasAmazonDate() || event.hasJanuaryFirstDate();
        }
    });

    releaseEditor.packagingBubble = bubbleDoc();

    releaseEditor.labelBubble = bubbleDoc({
        canBeShown: function (releaseLabel) {
            return releaseLabel.label().gid;
        }
    });

    releaseEditor.catNoBubble = bubbleDoc({
        canBeShown: function (releaseLabel) {
            return /^B00[0-9A-Z]{7}$/.test(releaseLabel.catalogNumber());
        }
    });

    releaseEditor.barcodeBubble = bubbleDoc({
        canBeShown: function (release) { return !release.barcode.none() }
    });

    releaseEditor.annotationBubble = bubbleDoc();

    releaseEditor.commentBubble = bubbleDoc();


    var trackBubble = {

        after$init: function () {
            this.prevButtonHasFocus = ko.observable(false);
            this.nextButtonHasFocus = ko.observable(false);
        },

        previousTrack: function (data, event, stealFocus) {
            event && event.stopPropagation();

            var track = this.currentTrack().previous();

            if (track) {
                // If the user initiates this action from the UI by explicitly
                // pressing the previous button, stealFocus will be undefined,
                // so default to not stealing the focus unless it's true.

                this.moveToTrack(track, stealFocus === true);
                return true;
            }
        },

        nextTrack: function (data, event, stealFocus) {
            event && event.stopPropagation();

            var track = this.currentTrack().next();

            if (track) {
                this.moveToTrack(track, stealFocus === true);
                return true;
            }
        },

        submit: function () {
            // stealFocus set to true causes the bubble to move focus to the
            // first input in the bubble. This is useful here, but not if the
            // user explicitly presses a next/previous button.

            if (!this.nextTrack(null, null, true /* stealFocus */)) {
                this.hide();
            }
        }
    };


    var RecordingBubble = aclass(MB.Control.BubbleDoc, trackBubble)
    .extend({
        before$show: function (control) {
            var track = ko.dataFor(control);

            if (track && !track.hasExistingRecording()) {
                releaseEditor.recordingAssociation.findRecordingSuggestions(track);
            }
        },

        currentTrack: function () { return this.target() },

        moveToTrack: function (track, stealFocus) {
            this.show(track.bubbleControlRecording, stealFocus);
        }
    });

    releaseEditor.recordingBubble = RecordingBubble("Recording");


    var TrackArtistBubble = aclass(MB.Control.BubbleBase, trackBubble)
    .extend(MB.Control.ArtistCreditBubbleBase)
    .extend({
        closeWhenFocusIsLost: true,
        changeMatchingArtists: ko.observable(false),
        initialArtistText: ko.observable(""),

        around$show: function (supr, control, stealFocus) {
            // If the bubble is redrawn to reposition it, it'll already be
            // visible, and we don't want to change initialArtistText.
            var wasAlreadyVisible = this.visible();

            supr(control, stealFocus);

            // this.target is set in supr, so we do this after.
            if (!wasAlreadyVisible) {
                this.initialArtistText(this.target().text());
            }

            this.$bubble.position({
                my: "right center",
                at: "left-10 center",
                of: control,
                collision: "none none"
            })
            .addClass("right-tail");
        },

        before$hide: function () {
            this.makeAllChanges();
        },

        makeAllChanges: function () {
            if (!this.changeMatchingArtists()) return;

            var ac = this.target(),
                track = ac.track,
                otherTracks = _.without(track.medium.tracks(), track),
                matchWith = this.initialArtistText(),
                names = ac.toJSON();

            _.each(otherTracks, function (other) {
                var ac = other.artistCredit;

                if (matchWith === ac.text()) ac.setNames(names);
            });

            this.initialArtistText("");
        },

        currentTrack: function () { return this.target().track },

        moveToTrack: function (track, stealFocus) {
            this.makeAllChanges();
            this.show(track.artistCredit.bubbleControlTrackArtist, stealFocus);
        }
    });

    releaseEditor.trackArtistBubble = TrackArtistBubble("TrackArtist");


    // Used to watch for DOM changes, so that doc bubbles stay pointed at the
    // correct position.
    //
    // See https://developer.mozilla.org/en-US/docs/Web/API/MutationObserver
    // for browser support.

    ko.bindingHandlers.affectsBubble = {

        init: function (element, valueAccessor) {
            if (!window.MutationObserver) {
                return;
            }

            var observer = new MutationObserver(_.throttle(function () {
                _.delay(function () { valueAccessor().redraw() }, 100);
            }, 100));

            observer.observe(element, { childList: true, subtree: true });

            ko.utils.domNodeDisposal.addDisposeCallback(element, function () {
                observer.disconnect();
            });
        }
    };

}(MB.releaseEditor = MB.releaseEditor || {}));
