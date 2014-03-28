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
            return (releaseLabel.label().gid ||
                    this.catNoLooksLikeASIN(releaseLabel.catalogNumber()));
        },

        catNoLooksLikeASIN: function (catNo) {
            return /^B00[0-9A-Z]{7}$/.test(catNo);
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

        around$show: function (supr, control, stealFocus, isRedraw) {
            if (this.visible() && !isRedraw) {
                this.makeAllChanges();
            }

            supr(control, stealFocus, isRedraw);

            // If the bubble is redrawn to reposition it, we don't want to
            // change initialArtistText.
            if (!isRedraw) {
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

            var target = this.target();
            var track = target.track;
            var matchWith = this.initialArtistText();
            var names = target.toJSON();

            _(track.medium.release.mediums())
                .invoke("tracks").flatten().without(track).pluck("artistCredit")
                .each(function (ac) {
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

}(MB.releaseEditor = MB.releaseEditor || {}));
