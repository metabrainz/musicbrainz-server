// This file is part of MusicBrainz, the open internet music database.
// Copyright (C) 2014 MetaBrainz Foundation
// Licensed under the GPL version 2, or (at your option) any later version:
// http://www.gnu.org/licenses/gpl-2.0.txt

import _ from 'lodash';
import ko from 'knockout';

import MB from '../common/MB';

import releaseEditor from './viewModel';

function bubbleDoc(options) {
    var bubble = new MB.Control.BubbleDoc('Information');
    Object.assign(bubble, options);
    return bubble;
}

releaseEditor.releaseGroupBubble = bubbleDoc({
    canBeShown: function (release) {
        var releaseGroup = release.releaseGroup();
        return releaseGroup && releaseGroup.gid;
    },
});

releaseEditor.statusBubble = bubbleDoc({
    canBeShown: function (release) { return release.statusID() == 4 },
});

releaseEditor.dateBubble = bubbleDoc({
    canBeShown: function (event) {
        return event.hasAmazonDate() || event.hasJanuaryFirstDate();
    },
});

releaseEditor.packagingBubble = bubbleDoc();

releaseEditor.labelBubble = bubbleDoc({
    canBeShown: function (releaseLabel) {
        return (releaseLabel.label().gid ||
                this.catNoLooksLikeASIN(releaseLabel.catalogNumber()));
    },

    catNoLooksLikeASIN: function (catNo) {
        return /^B00[0-9A-Z]{7}$/.test(catNo);
    },
});

releaseEditor.barcodeBubble = bubbleDoc({
    canBeShown: function (release) { return !release.barcode.none() },
});

releaseEditor.annotationBubble = bubbleDoc();

releaseEditor.commentBubble = bubbleDoc();

class RecordingBubble extends MB.Control.BubbleDoc {
    previousTrack(data, event, stealFocus) {
        event && event.stopPropagation();

        var track = this.currentTrack().previous();

        if (track) {
            // If the user initiates this action from the UI by explicitly
            // pressing the previous button, stealFocus will be undefined,
            // so default to not stealing the focus unless it's true.

            this.moveToTrack(track, stealFocus === true);
            return true;
        }
    }

    nextTrack(data, event, stealFocus) {
        event && event.stopPropagation();

        var track = this.currentTrack().next();

        if (track) {
            this.moveToTrack(track, stealFocus === true);
            return true;
        }
    }

    submit() {
        // stealFocus set to true causes the bubble to move focus to the
        // first input in the bubble. This is useful here, but not if the
        // user explicitly presses a next/previous button.

        if (!this.nextTrack(null, null, true /* stealFocus */)) {
            this.hide();
        }
    }

    show(control) {
        var track = ko.dataFor(control);

        if (track && !track.hasExistingRecording()) {
            releaseEditor.recordingAssociation.findRecordingSuggestions(track);
        }

        super.show(control);
    }

    currentTrack() { return this.target() }

    moveToTrack(track, stealFocus) {
        this.show(track.bubbleControlRecording, stealFocus);
    }
}

releaseEditor.recordingBubble = new RecordingBubble('Recording');
