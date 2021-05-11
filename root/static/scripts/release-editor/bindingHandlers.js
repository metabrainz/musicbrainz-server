/*
 * Copyright (C) 2014 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import $ from 'jquery';
import ko from 'knockout';
import * as ReactDOM from 'react-dom';

import {reduceArtistCredit} from '../common/immutable-entities';
import ArtistCreditEditor from '../edit/components/ArtistCreditEditor';

import fields from './fields';

ko.bindingHandlers.disableBecauseDiscIDs = {

  update: function (element, valueAccessor, allBindings, viewModel) {
    var disabled = ko.unwrap(valueAccessor()) && viewModel.medium.hasToc();

    $(element)
      .prop('disabled', disabled)
      .toggleClass('disabled-hint', disabled)
      .attr(
        'title',
        disabled
          ? l(`This medium has one or more discids
               which prevent this information from being changed.`)
          : element.title,
      );
  },
};

const TrackButtons = ({nextTrack, previousTrack}) => (
  <>
    <button onClick={nextTrack} style={{float: 'right'}} type="button">
      {l('Next')}
    </button>
    <button onClick={previousTrack} style={{float: 'right'}} type="button">
      {l('Previous')}
    </button>
  </>
);

ko.bindingHandlers.artistCreditEditor = {
  currentTarget: function () {
    return $('#artist-credit-bubble').data('target');
  },

  uncheckChangeMatchingArtists: function () {
    const input = document.getElementById('change-matching-artists');
    if (input) {
      input.checked = false;
    }
  },

  previousTrack: function () {
    const entity = this.currentTarget();
    const prev = entity.medium.tracks()[entity.position() - 2];
    if (prev) {
      entity.artistCreditEditorInst.runDoneCallback();
      /*
       * Defer until the setState calls in doneCallback finish,
       * since initialArtistText (which is set in updateBubble)
       * depends on the artist credit state.
       */
      setTimeout(() => {
        prev.artistCreditEditorInst.updateBubble(
          true,
          this.uncheckChangeMatchingArtists,
        );
      }, 1);
    }
  },

  nextTrack: function () {
    const entity = this.currentTarget();
    const next = entity.medium.tracks()[entity.position()];
    if (next) {
      entity.artistCreditEditorInst.runDoneCallback();
      setTimeout(() => {
        next.artistCreditEditorInst.updateBubble(
          true,
          this.uncheckChangeMatchingArtists,
        );
      }, 1);
    }
  },

  doneCallback: function (initialArtistText) {
    const input = document.getElementById('change-matching-artists');
    if (!input || !input.checked) {
      return;
    }

    const track = this.currentTarget();
    const artistCredit = track.artistCredit.peek();

    track.medium.release.mediums()
      .flatMap(m => m.tracks())
      .forEach(function (t) {
        if (t === track) {
          return;
        }
        if (initialArtistText === reduceArtistCredit(t.artistCredit.peek())) {
          t.artistCredit(artistCredit);
          t.artistCreditEditorInst.setState({artistCredit});
        }
      });
  },

  update: function (element, valueAccessor) {
    const entity = valueAccessor();
    /*
     * Subscribe to the artistCredit observable so that we
     * re-render the ArtistCreditEditor when it changes.
     */
    entity.artistCredit();
    const props = {
      entity: entity,
      hiddenInputs: false,
      onChange: entity.artistCredit,
    };
    if (entity instanceof fields.Track) {
      props.doneCallback = this.doneCallback;
      props.extraButtons = (
        <TrackButtons
          nextTrack={this.nextTrack}
          previousTrack={this.previousTrack}
        />
      );
      props.orientation = 'left';
    }
    entity.artistCreditEditorInst =
      ReactDOM.render(<ArtistCreditEditor {...props} />, element);
  },
};

{
  const self = ko.bindingHandlers.artistCreditEditor;
  self.doneCallback = self.doneCallback.bind(self);
  self.nextTrack = self.nextTrack.bind(self);
  self.previousTrack = self.previousTrack.bind(self);
  self.uncheckChangeMatchingArtists =
    self.uncheckChangeMatchingArtists.bind(self);
  self.update = self.update.bind(self);
}
