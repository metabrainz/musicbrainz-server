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

    releaseEditor.recordingBubble = MB.Control.BubbleDoc("Recording").extend({

        before$show: function (control) {
            var track = ko.dataFor(control);

            if (track && !track.hasExistingRecording()) {
                releaseEditor.recordingAssociation.findRecordingSuggestions(track);
            }
        }
    });

    releaseEditor.trackArtistBubble =
        MB.Control.BubbleBase("TrackArtist")
            .extend(MB.Control.ArtistCreditBubbleBase)
            .extend({

        closeWhenFocusIsLost: true,
        changeMatchingArtists: ko.observable(false),
        initialArtistText: ko.observable(""),

        around$show: function (supr, control) {
            // If the bubble is redrawn to reposition it, it'll already be
            // visible, and we don't want to change initialArtistText.
            var wasAlreadyVisible = this.visible();

            supr(control);

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

        previousTrack: function (data, event) {
            event.stopPropagation();
            var previous = this.target().track.previous();

            if (previous) {
                this.makeAllChanges();
                this.show(previous.artistCredit.bubbleControlTrackArtist);
                MB.utility.deferFocus("#track-ac-previous");
            }
        },

        nextTrack: function (data, event) {
            event.stopPropagation();
            var next = this.target().track.next();

            if (next) {
                this.makeAllChanges();
                this.show(next.artistCredit.bubbleControlTrackArtist);
                MB.utility.deferFocus("#track-ac-next");
            }
        },

        closeTrackArtistBubble: function (artistCredit, event) {
            if (event.isDefaultPrevented()) return;

            var $target = $(event.target);

            if ((event.keyCode === 13 && $target.is("input[type=text]")) ||
                 event.keyCode === 27) {

                $target.trigger("change");

                artistCredit.bubbleControlTrackArtist.bubbleDoc.hide();
                event.preventDefault();
            }
            return true;
        }
    });

}(MB.releaseEditor = MB.releaseEditor || {}));
