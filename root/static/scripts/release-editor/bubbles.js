/*
 * Copyright (C) 2014 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import ko from 'knockout';

import MB from '../common/MB.js';

import releaseEditor from './viewModel.js';

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
  canBeShown: function (release) {
    return release.statusID() == 4;
  },
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
    // Please keep in sync with CatNoLooksLikeASIN report
    return /^B0(?=.*[A-Z])([0-9A-Z]{8})$/.test(catNo);
  },
});

releaseEditor.barcodeBubble = bubbleDoc({
  canBeShown: function (release) {
    return !release.barcode.none();
  },
});

releaseEditor.annotationBubble = bubbleDoc();

releaseEditor.commentBubble = bubbleDoc();

class RecordingBubble extends MB.Control.BubbleDoc {
  previousTrack(data, event, stealFocus) {
    event && event.stopPropagation();

    var track = this.currentTrack().previous();

    if (track) {
      /*
       * If the user initiates this action from the UI by explicitly
       * pressing the previous button, stealFocus will be undefined,
       * so default to not stealing the focus unless it's true.
       */

      this.moveToTrack(track, stealFocus === true);
      return true;
    }

    return false;
  }

  nextTrack(data, event, stealFocus) {
    event && event.stopPropagation();

    var track = this.currentTrack().next();

    if (track) {
      this.moveToTrack(track, stealFocus === true);
      return true;
    }

    return false;
  }

  submit() {
    /*
     * stealFocus set to true causes the bubble to move focus to the
     * first input in the bubble. This is useful here, but not if the
     * user explicitly presses a next/previous button.
     */

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

  currentTrack() {
    return this.target();
  }

  moveToTrack(track, stealFocus) {
    this.show(track.bubbleControlRecording, stealFocus);
  }

  keydownEvent(data, event) {
    /*
     * Manually advance the focus to the first recording radio button if the
     * Tab key is pressed in the recording name text input. By default, only
     * the currently-checked radio button (which defaults to "Add a new
     * recording" at the end of the list when entering a new tracklist) is
     * keyboard-focusable. See MBS-13207.
     *
     * TODO: This only makes it possible to select the first radio button.
     * Consider doing something similar to support tabbing to other unchecked
     * radio buttons.
     */
    const noMods = !event.altKey && !event.ctrlKey && !event.metaKey &&
      !event.shiftKey;
    if (event.key === 'Tab' && noMods && !event.isDefaultPrevented()) {
      const radio = document.querySelector(
        '#recording-assoc-bubble input[name="recording-selection"]',
      );
      if (radio) {
        radio.focus();
        return false;
      }
    }

    // Instruct Knockout to not call preventDefault.
    return true;
  }
}

releaseEditor.recordingBubble = new RecordingBubble('Recording');
